import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File _image;
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
    return Scaffold(
      appBar: AppBar(title: Text('Settings Pages')),
      // Might want to add a way to log out here.
      body: Center(
        child: _image == null ? Text('Select an Image.') : Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
