import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

const String apiKey = 'AIzaSyAEEUXuKW_-DcYw9_YZCiwvt1fiSnqEjF8';

class mapscreen extends StatefulWidget {
  final String accommodationId;

  const mapscreen({required this.accommodationId});

  @override
  _mapscreenState createState() => _mapscreenState();
}

class _mapscreenState extends State<mapscreen> {
  late GoogleMapController mapController;
  LatLng? _origin;
  LatLng? _destination;
  List<LatLng> _route = [];
  bool _loading = true;
  late StreamSubscription<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  void _checkPermissions() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }

    if (status.isGranted) {
      _startLocationUpdates();
      _fetchDestination();
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _startLocationUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update the location every 10 meters.
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      setState(() {
        _origin = LatLng(position.latitude, position.longitude);
      });
      _fetchRoute();
    });
  }

  Future<void> _fetchDestination() async {
    try {
      DocumentSnapshot accommodationSnapshot = await FirebaseFirestore.instance
          .collection('accommodation')
          .doc(widget.accommodationId)
          .get();

      if (accommodationSnapshot.exists) {
        double destinationLat = accommodationSnapshot['latitude'];
        double destinationLng = accommodationSnapshot['longitude'];

        print("Destination: $destinationLat, $destinationLng");

        setState(() {
          _destination = LatLng(destinationLat, destinationLng);
        });

        if (_origin != null) {
          _fetchRoute();
        }
      } else {
        throw Exception('Accommodation not found');
      }
    } catch (e) {
      print('Error fetching destination: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchRoute() async {
    if (_origin != null && _destination != null) {
      try {
        List<LatLng> route = await _getDirections(_origin!, _destination!);
        setState(() {
          _route = route;
          print("Route: $_route"); // Debug statement
        });
      } catch (e) {
        print('Error fetching route: $e');
      }
    }
  }

  Future<List<LatLng>> _getDirections(LatLng origin, LatLng destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];
      return _convertToLatLng(_decodePolyline(points));
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> _convertToLatLng(List<List<double>> points) {
    return points.map((point) => LatLng(point[0], point[1])).toList();
  }

  List<List<double>> _decodePolyline(String polyline) {
    List<int> bytes = polyline.codeUnits;
    List<int> buffer = [];
    List<List<double>> coords = [];
    int index = 0;

    int shift = 0;
    int result = 0;

    while (index < bytes.length) {
      int byte;
      do {
        byte = bytes[index++] - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int coord = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      buffer.add(coord);

      if (buffer.length == 2) {
        double lat = buffer[0].toDouble();
        double lng = buffer[1].toDouble();
        coords.add([lat / 1e5, lng / 1e5]);
        buffer.clear();
      }

      result = 0;
      shift = 0;
    }

    return coords;
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Move the camera to the origin once the map is created
    if (_origin != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(_origin!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Directions'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _origin == null || _destination == null
              ? Center(child: Text('Error loading map'))
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _origin!,
                    zoom: 14.0,
                  ),
                  polylines: {
                    if (_route.isNotEmpty)
                      Polyline(
                        polylineId: PolylineId('route'),
                        points: _route,
                        color: Colors.blue,
                        width: 5,
                      ),
                  },
                  markers: {
                    Marker(
                      markerId: MarkerId('origin'),
                      position: _origin!,
                    ),
                    Marker(
                      markerId: MarkerId('destination'),
                      position: _destination!,
                      infoWindow: InfoWindow(
                        title: 'Destination',
                        snippet: 'Click for directions',
                        onTap: () {
                          // Open Google Maps with directions
                          final url =
                              'https://www.google.com/maps/dir/?api=1&origin=${_origin!.latitude},${_origin!.longitude}&destination=${_destination!.latitude},${_destination!.longitude}&travelmode=driving';
                          _launchURL(url);
                        },
                      ),
                    ),
                  },
                ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
