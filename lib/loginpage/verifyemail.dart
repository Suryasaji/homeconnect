import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p/ownernav/home1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p/tenantnav/habhome.dart';

class VerifyEmail extends StatefulWidget {
  final String email;
  final String userType;
  final String name;

  VerifyEmail({
    Key? key,
    required this.email,
    required this.userType,
    required this.name,
  }) : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  late StreamSubscription<User?> _authSubscription;
  late Timer timer;

  @override
  @override
  void initState() {
    super.initState();
    // Listen to authentication state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // Check email verification status when user is not null
        sendVerificationEmail();
        checkEmailVerification();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    timer.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      setState(() {
        isEmailVerified = currentUser.emailVerified;
      });
      if (isEmailVerified) {
        timer.cancel();
        // Add user details to Firestore collection
        addUserToFirestore();
        navigateToNextPage();
      }
    }
  }

  Future<void> addUserToFirestore() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      try {
        // Access Firestore instance and add user details to "users" collection using UID
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'name': widget.name,
          'email': widget.email,
          'userType': widget.userType,
        });
      } catch (e) {
        print('Error adding user to Firestore: $e');
      }
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        setState(() {
          canResendEmail = false;
        });
        timer = Timer.periodic(
          Duration(seconds: 3),
          (_) => checkEmailVerification(),
        );
      } else {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found.',
        );
      }
    } catch (e) {
      String errorMessage = 'An error occurred';
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? 'Unknown error occurred';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  void navigateToNextPage() {
    String userType = widget.userType.toLowerCase();
    if (userType == "owner") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => home1()),
      );
    } else if (userType == "habitue") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => habhome()),
      );
    }
  }

  @override

  // Method to delete user data from Firestore and Authentication when canceling verification
  Future<void> deleteUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .delete();
        await currentUser.delete();
      }
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Verify Email'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A verification email has been sent to ${widget.email}',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed:
                    canResendEmail ? () => sendVerificationEmail() : null,
                child: Text('Resend Email'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size.fromHeight(40.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  // Delete user data if verification is canceled
                  deleteUserData();
                  // Go back to the previous screen
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size.fromHeight(40.0),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
