//import 'package:p/admindashboard/adminnavigation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p/components/bottomnavigation.dart';

class StationDetails extends StatefulWidget {
  const StationDetails({Key? key, required this.title});
  final String title;

  @override
  State<StationDetails> createState() => _StationDetailsState();
}

class _StationDetailsState extends State<StationDetails> {
  late FirebaseFirestore firestore;
  late CollectionReference collection;
  List<Map<String, dynamic>> stations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    collection = firestore.collection('accommodation');
    fetchStations();
  }

  void fetchStations() async {
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
      var querySnapshot = await collection.get();

      List<Map<String, dynamic>> fetchedStations = [
        for (var doc in querySnapshot.docs)
          {
            ...doc.data() as Map<String,
                dynamic>, // Explicitly cast to Map<String, dynamic>
            'id': doc.id,
          }
      ];

      if (mounted) {
        setState(() {
          stations = fetchedStations;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching accommodations: $e');
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
        title: Text('Accommodations', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: stations.length,
              itemBuilder: (BuildContext context, int index) {
                var station = stations[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Accommodation id : ${station['id']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Owner id : ${station['userId']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Accommodation name : ${station['accommodationName']}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Address :  ${station['cityName']}, ${station['districtName']}, ${station['stateName']},',
                          style: TextStyle(
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
