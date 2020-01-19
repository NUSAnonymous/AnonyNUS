import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/const.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddContact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'ADD CONTACT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new AddContactScreen(),
    );
  }
}

class AddContactScreen extends StatefulWidget {
  @override
  State createState() => new AddContactScreenState();
}

class AddContactScreenState extends State<AddContactScreen> {
  TextEditingController controllerNickname;

  SharedPreferences prefs;

  String id = '';
  String nickname = '';

  bool isLoading = false;
  File avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs.getString('id') ?? '';

    controllerNickname = new TextEditingController();

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
  }

  // Future uploadFile() async {
  //   String fileName = id;
  //   StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
  //   StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
  //   StorageTaskSnapshot storageTaskSnapshot;
  //   uploadTask.onComplete.then((value) {
  //     if (value.error == null) {
  //       storageTaskSnapshot = value;
  //       storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
  //         photoUrl = downloadUrl;
  //         Firestore.instance
  //             .collection('users')
  //             .document(id)
  //             .updateData({'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl}).then((data) async {
  //           await prefs.setString('photoUrl', photoUrl);
  //           setState(() {
  //             isLoading = false;
  //           });
  //           Fluttertoast.showToast(msg: "Upload success");
  //         }).catchError((err) {
  //           setState(() {
  //             isLoading = false;
  //           });
  //           Fluttertoast.showToast(msg: err.toString());
  //         });
  //       }, onError: (err) {
  //         setState(() {
  //           isLoading = false;
  //         });
  //         Fluttertoast.showToast(msg: 'This file is not an image');
  //       });
  //     } else {
  //       setState(() {
  //         isLoading = false;
  //       });
  //       Fluttertoast.showToast(msg: 'This file is not an image');
  //     }
  //   }, onError: (err) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Fluttertoast.showToast(msg: err.toString());
  //   });
  // }

  void handleUpdateData() {
    focusNodeNickname.unfocus();

    setState(() {
      isLoading = true;
    });

    // var contact = Firestone.instance.collections('users');


    // Firestore.instance
    //           .collection('users')
    //           .document(id)
    //           .updateData({'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl})

      setState(() {
        isLoading = false;
      });

      Fluttertoast.showToast(msg: "Added success");
    }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Input
              Column(
                children: <Widget>[
                  // Username
                  Container(
                    child: Text(
                      'Nickname',
                      style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Jerald123',
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: greyColor),
                        ),
                        controller: controllerNickname,
                        onChanged: (value) {
                          nickname = value;
                        },
                        focusNode: focusNodeNickname,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Button
              Container(
                child: FlatButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: primaryColor,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
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
        ),
      ],
    );
  }
}
