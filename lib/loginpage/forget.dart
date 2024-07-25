import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:p/loginpage/login3.dart';

class forget extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<forget> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _errorMessage = '';
  final _formkey = GlobalKey<FormState>();
  Future<void> _resetPassword() async {
    if (_formkey.currentState!.validate()) {
      try {
        await _firebaseAuth.sendPasswordResetEmail(
            email: _emailController.text);
        setState(() {
          _errorMessage = 'Password reset email sent!';
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => login3()));
      } on FirebaseException catch (e) {
        // More specific catch
        setState(() {
          _errorMessage = e.message ?? 'A Firebase exception occurred.';
        });
      } catch (e) {
        // Catch any other exception
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
        });
        print(e); // For debugging purposes
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formkey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Column(
                      children: <Widget>[
                        Text(
                          'RESET PASSWORD', // Changed text to "Create a new account"
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please enter email ';
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
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0,
                                0), // Change this to your desired color
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetPassword();
                          },
                          child: Text(
                            'Reset Password?',
                            style: TextStyle(
                              color: Colors.purple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
