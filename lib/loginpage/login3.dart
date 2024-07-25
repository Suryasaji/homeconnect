import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p/admindashboard/bookings.dart';
import 'package:p/loginpage/forget.dart';
import 'package:p/loginpage/login2.dart';
import 'package:p/ownernav/home1.dart';
import 'package:p/tenantnav/habhome.dart';

class login3 extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<login3> {
  // For dropdown button
  bool _isPasswordVisible = false; // To toggle password visibility
  String _email = "", _password = "";
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      try {
        // Attempt sign-in
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userCredential.user!.uid == "dsWpsz0STSf4CQOFdDdm7MpRIQm2") {
          // Direct admin to BookingDetailsPage
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Bookingdetails(
              title: '',
            ),
          ));
        } else if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          String savedUserType = userData['userType'] ?? '';

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in Successfully'),
              backgroundColor: Colors.green,
            ),
          );

          if (savedUserType == 'Owner') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => home1()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => habhome()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User document does not exist or missing userType'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password is incorrect'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email is incorrect'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Handle other authentication errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      Icon(
                        Icons.home,
                        color: Colors.black, // Changed color to white
                        size: 24.0,
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        'HomeConnect',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  Column(
                    children: <Widget>[
                      Text(
                        'WELCOME', // Changed text to "Create a new account"
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Homeconnect is made for you. We make it easy now to find your perfect home within your comfort zone', // New text
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          return null;
                        },
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email', // Changed label to "Email"
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0,
                              0), // Change this to your desired color
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible, // Control visibility
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible =
                                    !_isPasswordVisible; // Toggle visibility
                              });
                            },
                            icon: Icon(
                              // Change the icon based on visibility
                              !_isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color:
                              Colors.black, // Text color inside the TextField
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to login2.dart when "Not a user? Register" is clicked
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => login2()));
                        },
                        child: Text(
                          'Not a user? Register',
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => forget()));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _email = _emailController.text;
                          _password = _passwordController.text;
                        });
                        _login();
                      }
                    },
                    child: Text('Login'),
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
          ),
        ),
      ),
    );
  }
}
