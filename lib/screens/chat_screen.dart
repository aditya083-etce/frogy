import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_Screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final msgTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String msgText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }
  //
  // void getMessages() async{
  //   try {
  //     final messages = await _firestore.collection('messages').getDocuments();
  //     for(var message in messages.documents){
  //       print(message.data.cast());
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  // void getMessageStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var message in snapshot.documents) {
  //       print(message.data);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // getMessageStream();
                  _auth.signOut();
                  Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/bg.png'),
              fit: BoxFit.cover,
            )
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MsgStream(),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        // style: TextStyle(color: Colors.black),
                        controller: msgTextController,
                        onChanged: (value) {
                          msgText = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        msgTextController.clear();
                        _firestore.collection('messages').add({
                          'text': msgText,
                          'sender': loggedInUser.email});
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MsgStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents.reversed;
        List<MsgBubble> messageBubbles = [];
        for (var msg in messages) {
          final msgText = msg.data['text'];
          final msgSender = msg.data['sender'];

          final currentUser = loggedInUser.email;

          final messageBubble = MsgBubble(
              text: msgText,
              sender: msgSender,
              isMe: currentUser == msgSender, //the logged person is typing
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messageBubbles,
            ));
      },
    );
  }
}


class MsgBubble extends StatelessWidget {
  const MsgBubble({this.text, this.sender,this.isMe});
  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender, style: TextStyle(fontSize: 12.0, color: Colors.black54)),
          Material(
            borderRadius: isMe? BorderRadius.only(topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)) :
            BorderRadius.only(topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent: Colors.lightGreen,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$text',
                style: TextStyle(
                    color: isMe ? Colors.white: Colors.black54,
                    fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
