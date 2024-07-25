import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p/components/navigation.dart';
import 'package:p/loginpage/login3.dart';
import 'package:p/ownernav/profile2.dart';

class profile1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile ',
      theme: ThemeData.light().copyWith(
        textTheme: TextTheme(
          bodyLarge:
              TextStyle(color: Colors.purple), // Change text color to purple
          bodyMedium:
              TextStyle(color: Colors.purple), // Change text color to purple
          labelLarge: TextStyle(
              color: Colors.purple), // Change button text color to purple
        ),
      ),
      home: person(),
    );
  }
}

class person extends StatefulWidget {
  @override
  _personState createState() => _personState();
}

class _personState extends State<person> {
  final User? user = FirebaseAuth.instance.currentUser;
  String _imageUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              Map<String, dynamic>? userData =
                  snapshot.data!.data() as Map<String, dynamic>?;
              if (userData != null) {
                String name = userData['name'] ?? '';
                _imageUrl = userData['imageUrl'] ?? '';
                return buildProfileView(context, name);
              } else {
                return Center(child: Text('No user data found'));
              }
            } else {
              return Center(child: Text('No data found'));
            }
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }

  Widget buildProfileView(BuildContext context, String name) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _uploadImage();
            },
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue, // Placeholder background color
                  ),
                  child: _imageUrl.isEmpty
                      ? Container() // No image placeholder
                      : ClipOval(
                          child: Image.network(
                            _imageUrl,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add_a_photo,
                    color: Colors.black, // Icon color
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            'Name:',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          Text(
            '$name',
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 10.0),
          Text(
            'Email:',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          Text(
            '${user?.email ?? "No email available"}',
            style: TextStyle(fontSize: 20.0),
          ),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => profile2()),
                  );
                },
                child: Text('Change Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Button background color
                  foregroundColor: Colors.black, // Button text color
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => login3()),
                    );
                  });
                },
                child: Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple, // Button background color
                  foregroundColor: Colors.black, // Button text color
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('images');
      Reference referenceImageToUpload =
          referenceDirImages.child(uniqueFileName);

      try {
        Uint8List data = await image.readAsBytes();
        await referenceImageToUpload.putData(data);
        String imageUrl = await referenceImageToUpload.getDownloadURL();

        // Save the imageUrl to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'imageUrl': imageUrl}); // Corrected this line

        setState(() {
          _imageUrl = imageUrl;
        });
      } catch (error) {
        print(error);
      }
    }
  }
}
