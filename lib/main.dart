import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/addContact.dart';
import 'package:flutter_chat_demo/chat.dart';
import 'package:flutter_chat_demo/const.dart';
import 'package:flutter_chat_demo/login.dart';
import 'package:flutter_chat_demo/settings.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'groupManager.dart';
import 'groups.dart';

void main() => runApp(MyApp());

class MainScreen extends StatefulWidget {
  final String currentUserId;
  final bool inByGoogle;

  MainScreen({Key key, @required this.currentUserId, this.inByGoogle}) : super(key: key);

  @override
  State createState() => MainScreenState(currentUserId: currentUserId, inByGoogle: inByGoogle);
}

class MainScreenState extends State<MainScreen> {
  MainScreenState({Key key, @required this.currentUserId, this.inByGoogle});

  final String currentUserId;
  final bool inByGoogle;
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Add Contact', icon: Icons.contacts),
    const Choice(title: 'Groups', icon: Icons.group),
    const Choice(title: 'Create Group', icon: Icons.create),
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      // print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      // print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      // print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      // print('token: $token');
      Firestore.instance.collection('users').document(currentUserId).updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void onItemMenuPress(Choice choice) {
    switch (choice.title) {
      case 'Add Contact': {
      Navigator.push(context, MaterialPageRoute(builder: (context) => AddContact()));
      break;
      }
      case 'Add Group':
      {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GroupManager()));
      break;
      }
      case 'My Groups':
      {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Groups()));
      break;
      }
      case 'Settings':
      {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
      break;
      }
      case 'Log out':
      {
      handleSignOut();
      break;
      } 
    }
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.NUSAnonymous.NUSAnonymous': 'com.hacknroll.example.anonymousappios',
      'AnonyNUS Chat',
      'A message has arrived!',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
      channelShowBadge: true, 
      enableLights: true
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );
    var platformChannelSpecifics =
        new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['title'].toString(), message['body'].toString(), platformChannelSpecifics,
        payload: 'Alert');
        //json.encode(message)
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 9.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    if (inByGoogle) {
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
    }

    this.setState(() {
      isLoading = false;
    });

    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FRIENDS',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: primaryColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // List
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                      ),
                    );
                  } else {
                    final int userIndex = snapshot.data.documents.indexWhere((doc) => doc.data['id'] == currentUserId);
                    var userContacts = snapshot.data.documents[userIndex].data['contacts'];
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => buildItem(context, User(
                        aboutMe: userContacts[index]['aboutMe'],
                        photoUrl: userContacts[index]['photoUrl'],
                        nickname: userContacts[index]['nickname'],
                        id: userContacts[index]['id'],
                        chattingWith: userContacts[index]['chattingWith'],
                        createdAt: userContacts[index]['createdAt'],
                        pushToken: userContacts[index]['pushToken']
                      )),
                      itemCount: userContacts != null ? userContacts.length : 0,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }

  Widget buildItem(BuildContext context, User contact) {
    if (contact == null) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: contact.photoUrl != ''
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                        imageUrl: contact.photoUrl,
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: greyColor,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Nickname: ${contact.nickname}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'About me: ${contact.aboutMe ?? ':)'}',
                          style: TextStyle(color: primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: contact.id,
                          peerAvatar: contact.photoUrl,
                        )));
          },
          color: greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

class User {
  const User({
      this.aboutMe, this.photoUrl, this.nickname, this.id, this.chattingWith, 
      this.pushToken, this.createdAt, this.contacts
    });

  final String aboutMe;
  final String photoUrl;
  final String nickname;
  final String id;
  final String chattingWith;
  final String createdAt;
  final String pushToken;
  final List<User> contacts;
}
