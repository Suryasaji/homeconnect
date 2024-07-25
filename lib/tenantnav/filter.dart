import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String selectedRoomType = '';
  String selectedRent = '';
  String selectedGenderType = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Find your choice...',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop({
              'selectedRoomType': selectedRoomType,
              'selectedRent': selectedRent,
              'selectedGenderType': selectedGenderType,
            });
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Divider(),
            Text(
              'ROOM TYPE',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10.0,
              runSpacing: 20.0,
              children: [
                'Single Room',
                'Double Room',
                'Triple Room',
                'Multi Room',
              ].map((title) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedRoomType = title;
                    });
                  },
                  child: Text(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedRoomType == title
                        ? Colors.black
                        : Colors.grey[200],
                    foregroundColor:
                        selectedRoomType == title ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Divider(),
            Text(
              'GENDER ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10.0,
              runSpacing: 20.0,
              children: [
                'Any',
                'Male',
                'Female',
              ].map((title) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedGenderType = title;
                    });
                  },
                  child: Text(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedGenderType == title
                        ? Colors.black
                        : Colors.grey[200],
                    foregroundColor: selectedGenderType == title
                        ? Colors.white
                        : Colors.black,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Divider(),
            Text(
              'RENT',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 10.0,
              runSpacing: 20.0,
              children: [
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
              ].map((title) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedRent = title;
                    });
                  },
                  child: Text(title),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedRent == title ? Colors.black : Colors.grey[200],
                    foregroundColor:
                        selectedRent == title ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'selectedRoomType': selectedRoomType,
                  'selectedRent': selectedRent,
                  'selectedGenderType': selectedGenderType,
                });
              },
              child: Text('Apply Filter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 194, 71, 175),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
