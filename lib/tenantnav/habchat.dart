import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:p/chatting/message.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:p/components/tenantnavigation.dart';

class habchat extends StatefulWidget {
  final String ownerName;
  final String ownerId;

  const habchat({
    Key? key,
    required this.ownerName,
    required this.ownerId,
  }) : super(key: key);

  @override
  _habchatState createState() => _habchatState();
}

class _habchatState extends State<habchat> {
  late TextEditingController _messageController;
  late Stream<List<Message>> _userMessagesStream;
  late Stream<List<Message>> _ownerMessagesStream;
  late StreamController<List<Message>> _combinedMessagesController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _userMessagesStream = _fetchUserMessages();
    _ownerMessagesStream = _fetchOwnerMessages();
    _combinedMessagesController = StreamController<List<Message>>();
    _combineStreams();
  }

  Stream<List<Message>> _fetchUserMessages() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('receiverId', isEqualTo: widget.ownerId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  Stream<List<Message>> _fetchOwnerMessages() {
    return FirebaseFirestore.instance
        .collection('ownermessage')
        .where('senderId', isEqualTo: widget.ownerId)
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  void _combineStreams() {
    List<Message> combinedMessages = [];

    // Listen to user messages stream
    _userMessagesStream.listen((userMessages) {
      combinedMessages.addAll(userMessages);
      _sortAndAddToController(combinedMessages);
    });

    // Listen to owner messages stream
    _ownerMessagesStream.listen((ownerMessages) {
      combinedMessages.addAll(ownerMessages);
      _sortAndAddToController(combinedMessages);
    });
  }

  void _sortAndAddToController(List<Message> messages) {
    // Sort the combined messages by timestamp
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Add sorted messages to the controller
    _combinedMessagesController.add(messages);
  }

  String _formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat.Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ownerName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _combinedMessagesController.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error.toString()}'));
                }
                List<Message> messages = snapshot.data ?? [];
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Message message = messages[index];
                    bool isSender = message.senderId ==
                        FirebaseAuth.instance.currentUser!.uid;
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: isSender
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isSender ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color:
                                        isSender ? Colors.white : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    color: isSender
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        InputDecoration(labelText: 'Enter your message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      sendMessage(_messageController.text);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Navigation(),
    );
  }

  void sendMessage(String messageText) {
    Message message = Message(
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: widget.ownerId,
      text: messageText,
      timestamp: Timestamp.now(),
    );

    // Check if the sender is the owner
    if (message.senderId == widget.ownerId) {
      FirebaseFirestore.instance
          .collection('ownermessages')
          .add(message.toMap());
    } else {
      // For other senders, store messages in the 'messages' collection
      FirebaseFirestore.instance.collection('messages').add(message.toMap());
    }
  }
}
