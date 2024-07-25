import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p/components/bottomnavigation.dart';

class Bookingdetails extends StatefulWidget {
  const Bookingdetails({super.key, required this.title});
  final String title;

  @override
  State<Bookingdetails> createState() => _Bookingdetails();
}

class _Bookingdetails extends State<Bookingdetails> {
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchbookings();
  }

  void fetchbookings() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No user logged in');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    try {
      var collection = FirebaseFirestore.instance.collection('booking');
      var querySnapshot = await collection.get();

      var fetchedBookings = [
        for (var doc in querySnapshot.docs)
          {
            ...doc.data(),
            'id': doc.id,
          }
      ];

      if (mounted) {
        setState(() {
          bookings = fetchedBookings;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ALL BOOKINGS', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (BuildContext context, int index) {
                var booking = bookings[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Booking id : ${booking['id'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'User id : ${booking['userId'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Accommodation id : ${booking['accommodationId'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Room id : ${booking['roomId'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Starting Date: ${booking['startDate'] != null ? DateFormat('yyyy-MM-dd ').format((booking['startDate'] as Timestamp).toDate()) : 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: AdminBottomNavigation(),
    );
  }
}
