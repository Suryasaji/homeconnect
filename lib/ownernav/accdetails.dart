import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:p/ownernav/update.dart';
import 'package:p/ownernav/update1.dart';

class accdetails extends StatelessWidget {
  final String accommodationId;
  accdetails({required this.accommodationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Your Accomodation'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            update1(accommodationId: accommodationId),
                      ),
                    );
                  },
                  child: Text('Manage Rooms'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 194, 71, 175),
                    foregroundColor: Colors.black,
                    minimumSize: Size(150, 50),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            update(accommodationId: accommodationId),
                      ),
                    );
                  },
                  child: Text('Edit Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 194, 71, 175),
                    foregroundColor: Colors.black,
                    minimumSize: Size(150, 50),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BookedRoomsList(accommodationId: accommodationId),
          ),
        ],
      ),
    );
  }
}

class BookedRoomsList extends StatelessWidget {
  final String accommodationId;
  BookedRoomsList({required this.accommodationId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('booking')
          .where('accommodationId', isEqualTo: accommodationId)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(height: 0); // Remove the blue line
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data?.docs.isEmpty ?? true) {
          return Text('No booked rooms found.');
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('roomdetails')
                  .doc(data['roomId'])
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> roomSnapshot) {
                if (roomSnapshot.connectionState == ConnectionState.waiting) {
                  return Container(height: 0); // Remove the blue line
                }
                if (roomSnapshot.hasError) {
                  return Text('Error: ${roomSnapshot.error}');
                }
                if (!roomSnapshot.hasData || !roomSnapshot.data!.exists) {
                  return Text(
                      'Room details not found for Room ${data['roomId']}');
                }
                Map<String, dynamic> roomData =
                    roomSnapshot.data!.data() as Map<String, dynamic>;

                // Extracting only day, month, and year from the timestamp
                DateTime startDate = (data['startDate'] as Timestamp).toDate();
                String formattedDate =
                    DateFormat('dd-MM-yyyy').format(startDate);

                // Fetching user details to get email
                return FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(data['userId'])
                      .get(),
                  builder:
                      (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(height: 0); // Remove the blue line
                    }
                    if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    }
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return Text(
                          'User details not found for UserID ${data['userId']}');
                    }
                    String userEmail = userSnapshot.data!['email'];

                    return ListTile(
                      title: Text('Room - ${roomData['name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name of user: ${data['userName']}'),
                          Text(
                              'Date of Joining: $formattedDate'), // Display formatted date
                          Text('User Email: $userEmail'), // Display user email
                          Text('Room Type: ${roomData['type']}'),
                          Text('Gender: ${roomData['gender']}'),
                          Text('Rent: ${roomData['rent']}'),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
