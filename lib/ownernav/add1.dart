import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:p/components/navigation.dart';
import 'package:p/ownernav/add2.dart';
import 'package:p/ownernav/location.dart';

class add1 extends StatefulWidget {
  const add1({Key? key}) : super(key: key);

  @override
  _add1State createState() => _add1State();
}

class _add1State extends State<add1> {
  final _formKey = GlobalKey<FormState>();
  final _accnameController = TextEditingController();
  final _stateNameController = TextEditingController();
  final _districtNameController = TextEditingController();
  final _cityNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _rulesController = TextEditingController();
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('accommodation');

  List<String> genderOptions = ['Male', 'Female', 'Any'];
  List<String> amenities = [];

  String? genderPreference;
  double? latitude;
  double? longitude;

  List<String> imageUrls = [];

  Future<void> _pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    List<XFile>? files = await imagePicker.pickMultiImage();

    if (files == null) return;

    try {
      for (var file in files) {
        String uniqueFileName =
            DateTime.now().millisecondsSinceEpoch.toString();
        Reference referenceRoot = FirebaseStorage.instance.ref();
        Reference referenceDirImages = referenceRoot.child('images');
        Reference referenceImageToUpload =
            referenceDirImages.child(uniqueFileName);

        if (kIsWeb) {
          Uint8List? data = await file.readAsBytes();
          await referenceImageToUpload.putData(data);
        } else {
          File imageFile = File(file.path);
          await referenceImageToUpload.putFile(imageFile);
        }

        String imageUrl = await referenceImageToUpload.getDownloadURL();
        imageUrls.add(imageUrl);
      }
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  Future<void> _submitDetails() async {
    if (_formKey.currentState!.validate()) {
      if (imageUrls.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Please upload an image')));
        return;
      }
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User not logged in')));
        return;
      }
      Map<String, dynamic> dataToSend = {
        'accommodationName': _accnameController.text,
        'stateName': _stateNameController.text,
        'districtName': _districtNameController.text,
        'cityName': _cityNameController.text,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'rules': _rulesController.text,
        'gender': genderPreference,
        'amenities': amenities,
        'userId': userId,
        'imageUrls': imageUrls,
        'latitude': latitude,
        'longitude': longitude,
      };

      await _reference.add(dataToSend);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => add2()),
      );
    }
  }

  Future<void> _pickLocation() async {
    final Position? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => location(),
      ),
    );

    if (result != null) {
      setState(() {
        latitude = result.latitude;
        longitude = result.longitude;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share living space'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _accnameController,
              decoration: InputDecoration(
                labelText: 'ACCOMODATION NAME',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter accomodation name';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'OWNER NAME',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'ACCOMODATION ADDRESS',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              maxLines: null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _stateNameController,
              decoration: InputDecoration(
                labelText: 'ACCOMODATION STATE',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              maxLines: null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter state';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _districtNameController,
              decoration: InputDecoration(
                labelText: 'ACCOMODATION DISTRICT',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter district';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _cityNameController,
              decoration: InputDecoration(
                labelText: 'ACCOMODATION CITY',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter city/town';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'PHONE NUMBER',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                } else if (value.length != 10 ||
                    !RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Phone number should contain exactly 10 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _rulesController,
              decoration: InputDecoration(
                labelText: ' Rules and Regulations',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter rules and regulations';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: genderPreference,
              onChanged: (value) {
                setState(() {
                  genderPreference = value;
                });
              },
              items: genderOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Gender Preference',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: amenities.map((amenity) {
                return Chip(
                  label: Text(amenity),
                  avatar: amenity == 'Washer'
                      ? Icon(Icons.local_laundry_service)
                      : amenity == 'Water'
                          ? Icon(Icons.opacity)
                          : amenity == 'Wifi'
                              ? Icon(Icons.wifi)
                              : amenity == 'Air conditioning'
                                  ? Icon(Icons.ac_unit)
                                  : null,
                  onDeleted: () {
                    setState(() {
                      amenities.remove(amenity);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Select Amenities'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('Washer'),
                          onTap: () {
                            setState(() {
                              amenities.add('Washer');
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Food'),
                          onTap: () {
                            setState(() {
                              amenities.add('Food');
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Wifi'),
                          onTap: () {
                            setState(() {
                              amenities.add('Wifi');
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          title: Text('Air conditioning'),
                          onTap: () {
                            setState(() {
                              amenities.add('Air conditioning');
                            });
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Text('Add Amenities'),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location),
              label: const Text('ADD LOCATION'),
              onPressed: _pickLocation,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Upload Image'),
              onPressed: _pickImage,
            ),
            Wrap(
              spacing: 8.0,
              children: imageUrls.asMap().entries.map((entry) {
                int index = entry.key;
                String imageUrl = entry.value;

                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: () {
                        setState(() {
                          imageUrls.removeAt(index);
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitDetails,
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 194, 71, 175),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
