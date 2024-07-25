import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p/chatting/chatowner.dart';
import 'package:p/components/navigation.dart';
import 'package:p/ownernav/accdetails.dart';

class home1 extends StatefulWidget {
  @override
  _Home1State createState() => _Home1State();
}

class _Home1State extends State<home1> {
  String userName = '';
  List<Map<String, dynamic>> accommodations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchStations();
  }

  void fetchUserData() async {
    try {
      String name = await fetchUserName();
      setState(() {
        userName = name;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<String> fetchUserName() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        return userDoc['name'] ?? '';
      } catch (e) {
        throw Exception('Error fetching user data: $e');
      }
    }
    throw Exception('Current user is null');
  }

  void fetchStations() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No user logged in');
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      var collection = FirebaseFirestore.instance.collection('accommodation');
      var querySnapshot =
          await collection.where('userId', isEqualTo: currentUser.uid).get();

      var fetchedAccommodations = querySnapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();

      setState(() {
        accommodations = fetchedAccommodations;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching accommodations: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Welcome  $userName', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          Image.network(
            'https://media.istockphoto.com/id/1322945089/photo/concrete-interior-room-with-blue-armchair-on-empty-dark-wall-background.jpg?s=612x612&w=0&k=20&c=2lzwXKjHk8dLRb2kS2s6n_HgXQMVzyDrLQo_ZbGeMII=',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            color: Colors.black.withOpacity(0.4), // Grey shade overlay
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Share your living space here
              Text(
                'Share your living space here...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Pacifico', // Use a custom cursive font
                ),
              ),
              // Sub-paragraph
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'You can easily share your accommodations with the needy here. Have a nice day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              // Your existing code for accommodations
              accommodations.isEmpty
                  ? Text(
                      '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: accommodations.length,
                        itemBuilder: (BuildContext context, int index) {
                          var acco = accommodations[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.home),
                              title: Text(
                                acco['accommodationName'] ??
                                    'Unknown Accommodation',
                              ),
                              subtitle: Text(acco['name'] ?? 'No name Info'),
                              trailing: IconButton(
                                icon: Icon(Icons.chevron_right),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => accdetails(
                                        accommodationId: acco['id'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your action here for the chat functionality
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatOwnerPage(),
            ),
          );
        },
        child: Icon(Icons.chat), // Change the icon as required
        backgroundColor: Colors.purple, // Change color as required
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
