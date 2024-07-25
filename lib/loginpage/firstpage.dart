import 'dart:async'; // Import async library for Future and Timer

import 'package:flutter/material.dart';
import 'package:p/loginpage/login3.dart'; // Import login1 page

class firstpage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<firstpage> {
  bool _displayText = false;

  @override
  void initState() {
    super.initState();
    // Use Future.delayed to set _displayText to true after 5 seconds
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _displayText = true;
      });
    });

    // se Future.delayed to navigate to login1.dart after 10 seconds
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => login3()), // Navigate to LoginPage
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_outlined,
                  color: Colors.purple,
                  size: 96), // Changed icon color to purple
              SizedBox(height: 16), // Increased spacer height
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: _displayText
                    ? Text(
                        'HomeConnect'.toUpperCase(),
                        key: ValueKey<String>('text'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.white, // Changed text color back to white
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 28.0, // Increased font size
                        ),
                      )
                    : SizedBox(), // Display nothing if _displayText is false
              ),
            ],
          ),
        ),
      ),
    );
  }
}
