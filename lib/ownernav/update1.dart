import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class update1 extends StatefulWidget {
  final String accommodationId;

  const update1({Key? key, required this.accommodationId}) : super(key: key);

  @override
  _update1State createState() => _update1State();
}

class _update1State extends State<update1> {
  late FirebaseFirestore firestore;
  late CollectionReference roomdetailsCollection;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    roomdetailsCollection = firestore.collection('roomdetails');
  }

  Future<void> _updateRoomType(String documentId, String newValue) async {
    try {
      int count;
      if (newValue == 'Single Room') {
        count = 1;
      } else if (newValue == 'Double Room') {
        count = 2;
      } else if (newValue == 'Triple Room') {
        count = 3;
      } else if (newValue == 'Multi Room') {
        count = 3;
      } else if (newValue == 'Accommodated') {
        count = 0;
      } else {
        // Default to Single Room if the type is not recognized
        count = 1;
      }

      await roomdetailsCollection.doc(documentId).update({'type': newValue});
      await roomdetailsCollection.doc(documentId).update({'count': count});
    } catch (e) {
      print('Error updating room type: $e');
    }
  }

  Future<void> _updateRoomRent(String documentId, String newValue) async {
    try {
      await roomdetailsCollection.doc(documentId).update({'rent': newValue});
    } catch (e) {
      print('Error updating room rent: $e');
    }
  }

  Future<void> _updateRoomAvailability(
      String documentId, String newValue) async {
    try {
      await roomdetailsCollection
          .doc(documentId)
          .update({'availability': newValue});
    } catch (e) {
      print('Error updating room availability: $e');
    }
  }

  Future<void> _addNewRoom() async {
    try {
      // Fetch the accommodation document
      var accommodationDoc = await FirebaseFirestore.instance
          .collection('accommodation')
          .doc(widget.accommodationId)
          .get();

      // Get the gender from the accommodation document
      String gender = accommodationDoc['gender'];

      int length = (await roomdetailsCollection.get()).docs.length;
      await roomdetailsCollection.add({
        'name': 'ROOMS ${length + 1}',
        'type': 'Single Room',
        'rent': '2000',
        'availability': 'Unavailable',
        'accommodation_id': widget.accommodationId,
        'gender': gender, // Add gender to the room details
        'count': 1, // Initialize count field to 1 for new rooms
      });
    } catch (e) {
      print('Error adding room: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Details'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: roomdetailsCollection
            .where('accommodation_id', isEqualTo: widget.accommodationId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No rooms found.'),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> roomDetails =
                  document.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text(roomDetails['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        value: roomDetails['type'],
                        items: <String>[
                          'Single Room',
                          'Double Room',
                          'Triple Room',
                          'Multi Room'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateRoomType(document.id, newValue);
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: roomDetails['availability'],
                        items: <String>[
                          'Available',
                          'Unavailable',
                          'Accommodated'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateRoomAvailability(document.id, newValue);
                          }
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: roomDetails['rent'],
                        items: <String>[
                          '2000',
                          '2500',
                          '3000',
                          '3500',
                          '4000',
                          '4500',
                          '5000',
                          '5500',
                          '6000',
                          '6500',
                          '7000',
                          '7500',
                          '8000',
                          '8500',
                          '9000',
                          '9500',
                          '10000'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateRoomRent(document.id, newValue);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRoom,
        tooltip: 'Add new room',
        child: Icon(Icons.add),
      ),
    );
  }
}
