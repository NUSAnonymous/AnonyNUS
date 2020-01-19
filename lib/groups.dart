
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/groupChat.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'const.dart';

class Groups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Group Chats',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new GroupChatList(),
    );
  }
}

class GroupChatList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return GroupChatState();
  }
}

class GroupChatState extends State<GroupChatList> {

  var values = Map();

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: Firestore.instance.collection('groups').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return new Text('Loading...');
        return new ListView(
          children: snapshot.data.documents.map((document) {
            return new ListTile(
              title: new Text(document['title']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  String groupTitle = document['title'];
                  Firestore
                  .instance
                  .collection('groups')
                  .document(document.documentID)
                  .delete();
                  Fluttertoast.showToast(msg: "Group $groupTitle deleted!");
                  },

                ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) 
              => GroupChat(groupID: document.documentID)));
              }
            );
          }).toList(),
        );
      },
    );
  }
}
