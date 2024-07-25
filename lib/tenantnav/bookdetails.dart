import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p/chatting/chathere.dart';
import 'package:p/tenantnav/review.dart';

class BookingDetailsPage extends StatelessWidget {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<String?> fetchCurrentUserName() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    return (userDoc.data() as Map<String, dynamic>?)?['name'] as String?;
  }

  void fetchAccommodationData(
      String accommodationId, Function(String, String) callback) async {
    DocumentSnapshot accommodationSnapshot = await FirebaseFirestore.instance
        .collection('accommodation')
        .doc(accommodationId)
        .get();

    if (accommodationSnapshot.exists) {
      String ownerName = accommodationSnapshot.get('name');
      String ownerId = accommodationSnapshot.get('userId');
      callback(ownerName, ownerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: FutureBuilder<String?>(
        future: fetchCurrentUserName(),
        builder: (context, userNameSnapshot) {
          if (userNameSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userNameSnapshot.hasError) {
            return Center(
                child: Text('Error: ${userNameSnapshot.error.toString()}'));
          }
          if (!userNameSnapshot.hasData || userNameSnapshot.data == null) {
            return Center(child: Text('User not found.'));
          }

          String currentUserName = userNameSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('booking')
                .where('userName', isEqualTo: currentUserName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Text('Error: ${snapshot.error.toString()}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No booking details found.'));
              }

              List<QueryDocumentSnapshot> bookings = snapshot.data!.docs;

              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  var bookingDoc = bookings[index];
                  var bookingData = bookingDoc.data() as Map<String, dynamic>;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('accommodation')
                        .doc(bookingData['accommodationId'])
                        .get(),
                    builder: (context, accommodationSnapshot) {
                      if (accommodationSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (accommodationSnapshot.hasError) {
                        return Center(
                            child: Text(
                                'Error: ${accommodationSnapshot.error.toString()}'));
                      }
                      if (!accommodationSnapshot.hasData ||
                          !accommodationSnapshot.data!.exists) {
                        return Center(
                            child: Text('Accommodation details not found.'));
                      }

                      var accommodationData = accommodationSnapshot.data!.data()
                          as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking ID: ${bookingDoc.id}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Accommodation Name: ${accommodationData['name'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Room ID: ${bookingData['roomId'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'User Name: ${bookingData['userName'] ?? 'N/A'}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Start Date: ${bookingData['startDate'] != null ? DateFormat('dd MMMM yyyy').format((bookingData['startDate'] as Timestamp).toDate()) : 'N/A'}',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Fetch accommodation data and navigate to chat screen with relevant data
                                    fetchAccommodationData(
                                        bookingData['accommodationId'],
                                        (ownerName, ownerId) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatHerePage(
                                            ownerName: ownerName,
                                            ownerId: ownerId,
                                          ),
                                        ),
                                      );
                                    });
                                  },
                                  child: Text("Let's Chat!!!"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Navigate to the review screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReviewPage(
                                            accommodationId:
                                                bookingData['accommodationId']),
                                      ),
                                    );
                                  },
                                  child: Text("Review"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Implement vacate functionality
                                    // For example, mark the booking as vacated in Firestore
                                    FirebaseFirestore.instance
                                        .collection('booking')
                                        .doc(bookingDoc.id)
                                        .delete()
                                        .then((value) {
                                      // Update roomdetails and set availability to 'Available'
                                      FirebaseFirestore.instance
                                          .collection('roomdetails')
                                          .doc(bookingData['roomId'])
                                          .update({
                                        'count': FieldValue.increment(1),
                                      }).then((value) {
                                        // Update availability
                                        FirebaseFirestore.instance
                                            .collection('roomdetails')
                                            .doc(bookingData['roomId'])
                                            .update({
                                          'availability': 'Available',
                                        }).then((value) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Booking vacated successfully!')),
                                          );

                                          // Navigate to the next page after deletion
                                        }).catchError((error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Failed to update availability: $error')),
                                          );
                                        });
                                      }).catchError((error) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Failed to update room details: $error')),
                                        );
                                      });
                                    }).catchError((error) {
                                      // Handle error
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to vacate booking: $error')),
                                      );
                                    });
                                  },
                                  child: Text("Vacate"),
                                ),
                              ],
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
