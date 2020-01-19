import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'const.dart';

class GroupManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'New Group',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: new GroupCreateScreen(),
    );
  }
}

class GroupCreateScreen extends StatefulWidget {
  @override
  State createState() => new GroupCreateScreenState();
}

// class GroupCreateScreenState extends State<GroupCreateScreen> {

//   bool isLoading = false;
//   String id = '';
//     id = prefs.getString('id') ?? '';

//   void handleUpdateData() {

//     setState(() {
//       isLoading = true;
//     });

//     Firestore.instance
//         .collection('groups')
//         .document(id)
//         .updateData({'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl}).then((data) async {
//       await prefs.setString('nickname', nickname);
//       await prefs.setString('aboutMe', aboutMe);
//       await prefs.setString('photoUrl', photoUrl);

//       setState(() {
//         isLoading = false;
//       });

//       Fluttertoast.showToast(msg: "Update success");
//     }).catchError((err) {
//       setState(() {
//         isLoading = false;
//       });

//       Fluttertoast.showToast(msg: err.toString());
//     });
//   }

// Define a corresponding State class.
// This class holds data related to the form.
class GroupCreateScreenState extends State<GroupCreateScreen> {
  // Define the focus node. To manage the lifecycle, create the FocusNode in
  // the initState method, and clean it up in the dispose method.
  FocusNode myFocusNode;
  String title = '';
  String description = '';

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  bool _validated(title) {
    if (title == '') {
      return false;
    }
    return true;
  }

  void handleSubmit(String title, String description) {
    if (_validated(title)) {
      Firestore.instance.collection('groups').document(title)
      .setData({ 'title': title, 'description': description });
      Fluttertoast.showToast(msg: "Group Created");
      Navigator.pop(context);
    }
    else {
      Fluttertoast.showToast(msg: "Error unable to add group, ensure title is not empty");
    }
  }
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 150.0, 10, 0.0),
              child: TextField(
                decoration: new InputDecoration(
                  labelText: "Group Name",
                  hintText: "CS1101S",
                ),
                autofocus: true,
                controller: titleController
              ),
            ),
            // The second text field is focused on when a user taps the
            // FloatingActionButton.
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 25.0, 10, 0.0),
              child: TextField(
                decoration: new InputDecoration(
                  labelText: "Group Description",
                  hintText: "Programming Methodology",
                ),
                focusNode: myFocusNode,
                controller: descriptionController,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // When the button is pressed,
        // give focus to the text field using myFocusNode.
        onPressed: () => handleUpdateData(titleController.text, 
         descriptionController.text),
        tooltip: 'Focus Second Text Field',
        icon: Icon(Icons.edit),
        label: Text("Add Group")
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  final FocusNode titleFocusNode = new FocusNode();
  final FocusNode descriptionFocusNode = new FocusNode();

   Future handleUpdateData(String title, String description) async {
    final QuerySnapshot result = await Future.value(Firestore.instance
    .collection("groups")
    .where("title", isEqualTo: "$title")
    .limit(1)
    .getDocuments());
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length > 0) {
      Fluttertoast.showToast(msg: "Group title already exists!");
    } else {
      titleFocusNode.unfocus();
      descriptionFocusNode.unfocus();
      Firestore.instance.collection('groups').document(title)
        .setData({ 'title': title, 'description': description })
        .then((data) async {
        Fluttertoast.showToast(msg: "Group creation success!");
      });
      Navigator.pop(context);
    }

    // Firestore.instance
    //     .collection('users')
    //     .document(id)
    //     .updateData({'nickname': nickname, 'aboutMe': aboutMe, 'photoUrl': photoUrl}).then((data) async {

  }
}