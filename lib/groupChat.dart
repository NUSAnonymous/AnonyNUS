import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/const.dart';
import 'package:flutter_chat_demo/fullPhoto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupChat extends StatelessWidget {
  final String groupID;
  final String groupAvatar;

  GroupChat({Key key, @required this.groupID, @required this.groupAvatar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new GroupChatScreen(
        groupId: groupID,
        groupAvatar: groupAvatar,
      ),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupAvatar;

  @override
  State createState() => new GroupChatScreenState(groupId: groupId, groupAvatar: groupAvatar);
}