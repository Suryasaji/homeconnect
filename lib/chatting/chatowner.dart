import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p/chatting/chatHere.dart';
import 'package:p/chatting/ownerchat.dart';

class ChatOwnerPage extends StatefulWidget {
  @override
  _ChatOwnerPageState createState() => _ChatOwnerPageState();
}

class _ChatOwnerPageState extends State<ChatOwnerPage> {
  late Stream<List<String>> _chatUsersStream;

  @override
  void initState() {
    super.initState();
    _fetchChatUsers();
  }

  void _fetchChatUsers() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _chatUsersStream = FirebaseFirestore.instance
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc['senderId'] as String)
            .toSet()
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: StreamBuilder<List<String>>(
        stream: _chatUsersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          List<String> userIds = snapshot.data ?? [];
          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (context, index) {
              return _buildChatUserItem(userIds[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildChatUserItem(String userId) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // Return an empty widget while loading
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ownerChat(
                          receiverId: userId,
                        )),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200], // Box shade color
              ),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                      Icons.person), // You can replace this with user avatar
                ),
                title: Text(userData[
                    'name']), // Adjust this to display user details as needed
              ),
            ),
          ),
        );
      },
    );
  }
}
