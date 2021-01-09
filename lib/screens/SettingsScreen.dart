import 'package:atlas/screens/CustomAppBar.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:multi_image_picker/multi_image_picker.dart';

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
  List<Asset> _images = [];
  List files = [];
  List<Asset> resultList;
  String bioEditMessage = "Edit Bio";

  void updateBio(String newBio) async {
    await profileRef.update({"Bio": newBio});
    setState(() {
      bioEditMessage = "Successfuly Updated Bio";
    });
  }

  DocumentReference profileRef =
      FirebaseFirestore.instance.collection("Users").doc(myId);

  Future<void> loadAssets() async {
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 1, selectedAssets: _images);
    } on Exception catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _images = resultList;
      _savePhotos();
    });
  }

  Future _savePhotos() async {
    /// Need to save a blank profile if we don't have a profile image
    /// First, let's decide what our url will be. If not a blank, we need to
    /// upload to firebase storage and grab that url. Otherwise, hardcoded blank
    /// url.
    ///
    List<String> photoUrls = new List<String>();
// can't use for each here... learned this the hard way.

    for (var image in _images) {
      // Trying a data upload method. hopefully this works better cause of course the other ways we have uploaded images don't work on my iphone for some reason

      // Convert the asset into a file
      ByteData byteData = await image.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();

      Reference ref =
          FirebaseStorage.instance.ref().child('profilePhotos/$myId.png');

      UploadTask uploadTask = ref.putData(imageData);

      await uploadTask.whenComplete(() async {
        photoUrls.add(await ref.getDownloadURL());
      });
    }

    /// Now we just update our storage in [Firestore]
    ///

    await profileRef.update({'profileURL': photoUrls[0]});
  }

  final _bioController = TextEditingController();
  void initState() {
    super.initState();
    _bioController.text = widget.currentBio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar("Settings", null, context, null),
      // Might want to add a way to log out here.
      body: ListView(children: <Widget>[
        Container(
            height: 60,
            child: Column(children: [
              InkWell(
                  onTap: (() {
                    loadAssets();
                  }),
                  child: Column(children: [
                    Text('Change Profile Image'),
                    Icon(Icons.add_a_photo,
                        color: Theme.of(context).primaryColor)
                  ])),
              // if (_images[0] != null) Image.file(_images[0])
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
