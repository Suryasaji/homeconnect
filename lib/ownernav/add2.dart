import 'package:flutter/material.dart';
import 'package:p/components/navigation.dart';
import 'package:p/ownernav/home1.dart';

class add2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(
          255, 255, 255, 255), // Adjust the color to match the background
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green, // Adjust the color to match the icon
            ),
            SizedBox(
                height: 20), // Provides space between the icon and the text
            Text(
              'Accommodation Added',
              style: TextStyle(
                color: Colors.purple, // Text color inside the TextField
              ),
            ),
            SizedBox(height: 10), // Provides space between the text elements
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Thank you..for sharing your living space',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.purple, // Text color inside the TextField
                ),
              ),
            ),
            SizedBox(height: 30), // Space before the button
            ElevatedButton(
              onPressed: () {
                // Handle the button press
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => home1()),
                );
              },
              child: Text('BACK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // Button background color
                foregroundColor: Colors.black, // Button text color
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
