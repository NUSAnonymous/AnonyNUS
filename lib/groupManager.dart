

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  void handleSubmit(String title, String description) {
    Firestore.instance.collection('groups').document()
    .setData({ 'title': title, 'description': description });
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
            Column(
              children: [
                Text("Group Title"),
                // The first text field is focused on as soon as the app starts.
                TextField(
                  autofocus: true,
                  controller: titleController
                ),

              ]

            ),
            Column(
              children: [
                Text("Group Description"),
                // The second text field is focused on when a user taps the
                // FloatingActionButton.
                TextField(
                  focusNode: myFocusNode,
                  controller: descriptionController,
                ),
              ]
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // When the button is pressed,
        // give focus to the text field using myFocusNode.
        onPressed: () => handleSubmit(titleController.text, 
         descriptionController.text),
        tooltip: 'Focus Second Text Field',
        child: Icon(Icons.edit),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}