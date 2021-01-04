import 'package:atlas/screens/CustomAppBar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class SettingsScreen extends StatefulWidget {
  String currentBio;
  SettingsScreen(this.currentBio);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File _image;
  String bioEditMessage = "Edit Bio";
  final picker = ImagePicker();

  DocumentReference profileRef =
      FirebaseFirestore.instance.collection("Users").doc(myId);
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        // Once we picked a file set it to _image
        _image = File(pickedFile.path);
        // then go ahead an upload the image by calling saveImage
        saveImage(_image, profileRef);
      } else {
        print('No image selected.');
      }
    });
  }

  void updateBio(String newBio) async {
    await profileRef.update({"Bio": newBio});
    setState(() {
      bioEditMessage = "Successfuly Updated Bio";
    });
  }

  Future<void> saveImage(File _image, DocumentReference ref) async {
    // Grab the URL that the photo was saved to in cloud storage and save the image
    String imageURL = await uploadFile(_image);

    // Update the document's profileURL field to be this imageURL
    // make sure we got back a non null imageURL
    if (imageURL != null) {}
    ref.update({"profileURL": imageURL});
  }

  Future<String> uploadFile(File _image) async {
    try {
      // grab a reference to where we want to store these photos
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("profilePhotos/$myId.png");
      // await the upload of the image

      await ref.putFile(_image);
      // then await getting the download URL
      String downloadURL = await ref.getDownloadURL();
      // return the url
      return downloadURL;
    } on firebase_core.FirebaseException catch (e) {
      print("Firebase exception");
      print(e);
    }
    // if we were unable to get a url or the future hasn't finished we can return null

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final _bioController = TextEditingController();
    _bioController.text = widget.currentBio;

    return Scaffold(
      appBar: CustomAppBar("Settings", null, context, null),
      // Might want to add a way to log out here.
      body: ListView(children: <Widget>[
        Container(
            height: 60,
            child: Column(children: [
              InkWell(
                  onTap: getImage,
                  child: Column(children: [
                    Text('Change Profile Image'),
                    Icon(Icons.add_a_photo,
                        color: Theme.of(context).primaryColor)
                  ])),
              if (_image != null) Image.file(_image)
            ])),
        Column(children: [
          Text(bioEditMessage),
          Container(
              width: MediaQuery.of(context).size.width * .9,
              child: TextField(
                inputFormatters: [LengthLimitingTextInputFormatter(70)],
                controller: _bioController,
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(20.0),
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white70),
              )),
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Theme.of(context).primaryColor)),
            color: Colors.white,
            textColor: Colors.blue,
            padding: EdgeInsets.all(8.0),
            onPressed: () {
              updateBio(_bioController.text);
            },
            child: Text(
              "Save".toUpperCase(),
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          ),
        ])
      ]),
    );
  }
}
