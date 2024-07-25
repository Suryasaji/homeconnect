import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p/components/bottomnavigation.dart';

class Userdetails extends StatefulWidget {
  const Userdetails({super.key, required this.title});
  final String title;

  @override
  State<Userdetails> createState() => _Userdetails();
}

class _Userdetails extends State<Userdetails> {
  List<Map<String, dynamic>> users = [];
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
      var collection = FirebaseFirestore.instance.collection('users');
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
          users = fetchedBookings;
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
        title: Text('ALL USERS', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (BuildContext context, int index) {
                var booking = users[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'User id : ${booking['id'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Email : ${booking['email'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'User Name : ${booking['name'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'User Type : ${booking['userType'] ?? 'N/A'}',
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
