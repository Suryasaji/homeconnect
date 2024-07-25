import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:p/ownernav/person.dart';

class profile2 extends StatefulWidget {
  @override
  _profile2State createState() => _profile2State();
}

class _profile2State extends State<profile2> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorMessage;

  bool _isObscureOldPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword(BuildContext context) async {
    try {
      final user = _auth.currentUser;
      final credential = EmailAuthProvider.credential(
          email: user!.email!, password: _oldPasswordController.text);
      await user.reauthenticateWithCredential(credential);

      if (_newPasswordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = "New passwords do not match";
        });
        return;
      }

      await user.updatePassword(_newPasswordController.text);

      // Update password in Firestore if needed
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        await userDoc.reference
            .update({'password': _newPasswordController.text});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      // Delay for a short duration to display the SnackBar
      await Future.delayed(Duration(seconds: 2));

      // Navigate back to the Profile1 page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => person()),
      );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText,
      bool isObscure, Function() onPressed) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
          onPressed: onPressed,
        ),
      ),
      obscureText: isObscure,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => person()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPasswordField(
              _oldPasswordController,
              'Old Password',
              _isObscureOldPassword,
              () => setState(
                  () => _isObscureOldPassword = !_isObscureOldPassword),
            ),
            SizedBox(height: 20.0),
            _buildPasswordField(
              _newPasswordController,
              'New Password',
              _isObscureNewPassword,
              () => setState(
                  () => _isObscureNewPassword = !_isObscureNewPassword),
            ),
            SizedBox(height: 20.0),
            _buildPasswordField(
              _confirmPasswordController,
              'Confirm New Password',
              _isObscureConfirmPassword,
              () => setState(
                  () => _isObscureConfirmPassword = !_isObscureConfirmPassword),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 194, 71, 175),
                foregroundColor: Colors.black,
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
