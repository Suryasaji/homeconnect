import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class bookslot extends StatefulWidget {
  final String accommodationId;
  final String roomId;

  const bookslot(
      {Key? key, required this.accommodationId, required this.roomId})
      : super(key: key);

  @override
  _bookslotState createState() => _bookslotState();
}

class _bookslotState extends State<bookslot> {
  DateTime? selectedDate;
  late String userName = "";
  late String userId = "";
  String ownerName = "";
  String type = "";
  int rent = 0;
  int newcount = 1;
  late int originalCount;
  late String originalAvailability;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    fetchAccommodationData();
    fetchRoomDetails();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      fetchUserName();
    }
  }

  void fetchUserName() async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      setState(() {
        userName = userSnapshot.get('name');
      });
    }
  }

  void fetchAccommodationData() async {
    DocumentSnapshot accommodationSnapshot = await FirebaseFirestore.instance
        .collection('accommodation')
        .doc(widget.accommodationId)
        .get();

    if (accommodationSnapshot.exists) {
      setState(() {
        ownerName = accommodationSnapshot.get('name');
        userId = accommodationSnapshot.get('userId');
      });
    }
  }

  void fetchRoomDetails() async {
    DocumentSnapshot roomSnapshot = await FirebaseFirestore.instance
        .collection('roomdetails')
        .doc(widget.roomId)
        .get();

    if (roomSnapshot.exists) {
      setState(() {
        rent = int.parse(roomSnapshot.get('rent'));
        type = roomSnapshot.get('type');
        newcount = roomSnapshot.get('count');
      });
    }
  }

  void saveBookingDetails() {
    int orgcount = newcount - 1;
    String newAvailability = 'Available';
    if (orgcount == 0) {
      newAvailability = 'Accommodated';
    }

    FirebaseFirestore.instance
        .collection('roomdetails')
        .doc(widget.roomId)
        .update({
      'count': orgcount,
      'availability': newAvailability,
    }).then((_) {
      // Show confirmation dialog
    }).catchError((error) {
      print("Failed to update room details: $error");
      // Show error message or take appropriate action
    });
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Booking'),
          content: Text('Are you sure you want to confirm booking?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                saveBookingDetails();
                saveBookingToFirestore();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void saveBookingToFirestore() {
    FirebaseFirestore.instance.collection('booking').add({
      'startDate': selectedDate,
      'roomId': widget.roomId,
      'accommodationId': widget.accommodationId,
      'userId': userId,
      'userName': userName
    }).then((value) {
      print('Booking added successfully');
    }).catchError((error) {
      print('Failed to add booking: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Slot'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accommodation Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Name: $ownerName',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Type: $type',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Rent: $rent',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Select Date',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 1),
                );
                if (picked != null && picked != selectedDate) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  selectedDate != null
                      ? 'Selected Date: ${selectedDate!.toString().split(' ')[0]}'
                      : 'Select Date',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  showConfirmationDialog();
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(
                          255, 236, 77, 213)), // Change background color
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.black), // Change text color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Book Now',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
