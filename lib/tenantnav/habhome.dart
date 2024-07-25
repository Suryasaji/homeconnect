import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:p/components/tenantnavigation.dart';
import 'package:p/tenantnav/accommodationscreen.dart';
import 'package:p/tenantnav/filter.dart';

class habhome extends StatefulWidget {
  @override
  State<habhome> createState() => _habhomeState();
}

class _habhomeState extends State<habhome> {
  String selectedRoomType = '';
  String selectedRent = '';
  String selectedGenderType = '';

  late final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream;
  final CollectionReference _accommodationReference =
      FirebaseFirestore.instance.collection('accommodation');
  final CollectionReference _roomdetailsReference =
      FirebaseFirestore.instance.collection('roomdetails');

  @override
  void initState() {
    super.initState();
    _stream = _roomdetailsReference
        .where('availability', isEqualTo: 'Available')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => doc as DocumentSnapshot<Map<String, dynamic>>)
            .toList());
  }

  Future<List<Map<String, dynamic>>> fetchDetails() async {
    QuerySnapshot roomdetailsSnapshot;

    if (selectedRoomType.isNotEmpty &&
        selectedRent.isNotEmpty &&
        selectedGenderType.isNotEmpty) {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .where('type', isEqualTo: selectedRoomType)
          .where('rent', isEqualTo: selectedRent)
          .where('gender', isEqualTo: selectedGenderType)
          .get();
    } else if (selectedRoomType.isNotEmpty && selectedGenderType.isNotEmpty) {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .where('type', isEqualTo: selectedRoomType)
          .where('gender', isEqualTo: selectedGenderType)
          .get();
    } else if (selectedRent.isNotEmpty && selectedGenderType.isNotEmpty) {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .where('rent', isEqualTo: selectedRent)
          .where('gender', isEqualTo: selectedGenderType)
          .get();
    } else if (selectedRent.isNotEmpty && selectedRoomType.isNotEmpty) {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .where('rent', isEqualTo: selectedRent)
          .where('type', isEqualTo: selectedRoomType)
          .get();
    } else if (selectedGenderType.isNotEmpty) {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .where('gender', isEqualTo: selectedGenderType)
          .get();
    } else if (selectedRoomType.isNotEmpty) {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .where('type', isEqualTo: selectedRoomType)
          .get();
    } else if (selectedRent.isNotEmpty) {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .where('rent', isEqualTo: selectedRent)
          .get();
    } else {
      roomdetailsSnapshot = await _roomdetailsReference
          .where('availability', isEqualTo: 'Available')
          .get();
    }
    if (roomdetailsSnapshot.docs.isEmpty) {
      // No stations found with the selected connector type
      return Future.value([]);
    }

    List<String> availableAccommodationIds = roomdetailsSnapshot.docs
        .map((doc) => doc['accommodation_id'] as String)
        .toList();

    QuerySnapshot accommodationSnapshot = await _accommodationReference
        .where(FieldPath.documentId, whereIn: availableAccommodationIds)
        .get();

    return accommodationSnapshot.docs.map((doc) {
      // Include the document ID along with the data
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['documentId'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Accommodations',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () async {
                    var filters = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilterPage()),
                    );
                    if (filters != null) {
                      setState(() {
                        selectedRoomType = filters['selectedRoomType'];
                        selectedRent = filters['selectedRent'];
                        selectedGenderType = filters['selectedGenderType'];
                      });
                    }
                  },
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchDetails(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error.toString()}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  List<Map<String, dynamic>> documents = snapshot.data!;
                  return documents.isEmpty
                      ? Center(child: Text('No results found'))
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            var doc = documents[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => accommodationscreen(
                                      accommodationId: doc['documentId'],
                                      Rent: selectedRent,
                                      Gender: selectedGenderType,
                                      Type: selectedRoomType,
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        child: Image.network(
                                          doc['imageUrls'][0],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Text(
                                        doc['accommodationName'] ?? 'N/A',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
