import 'dart:io';

import 'package:atlas/screens/CheckIn/AddDescription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class AddPhotos extends StatefulWidget {
  CollectionReference zones = FirebaseFirestore.instance.collection("Zones");
  // Creation Id tells us whether this spot is discovered, explored, or returned to for later reference
  String creationId;
  // Title for now is the text that is displayed on this widget
  String spotName;

// Full id has the zone and the full northing and easting
  String fullId;
  // Spot id is just the northing and easting separated by ;
  String spotId;

  String zone;

  String area;

  String checkInId;
  String message;
  AddPhotos(String creationId, String spotName, String fullId) {
    this.creationId = creationId;
    this.fullId = fullId;

    var split = (fullId.split("/"));

    this.zone = split[0];
    this.spotId = split[1];
    var areaSplit = this.spotId.split(";");
    this.area =
        "${areaSplit[0].substring(0, 3)};${areaSplit[1].substring(0, 2)}";
    this.checkInId =
        zone + ";" + spotId + ";" + spotName + ";" + DateTime.now().toString();

    this.spotName = spotName;
    if (creationId == "0") {
      this.message = "Congratulations on discovering";
    } else if (creationId == "1") {
      this.message = "Congratulations on exploring";
    } else if (creationId == "2") {
      this.message = "Welcome back to";
    }
  }

  @override
  _AddPhotosState createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  List<Asset> _images = [];
  List files = [];
  List<Asset> resultList;
  double widgetHeight;
  DocumentReference checkInDoc;
// Load the images
  Future<void> loadAssets() async {
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 6, selectedAssets: _images);
    } on Exception catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _images = resultList;
      mainWidget = listOfPhotos();
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

      Reference ref = FirebaseStorage.instance
          .ref()
          .child('checkInPhotos/$myId;${DateTime.now().toString()}.jpg');

      UploadTask uploadTask = ref.putData(imageData);

      await uploadTask.whenComplete(() async {
        photoUrls.add(await ref.getDownloadURL());
      });
    }

    /// Now we just update our storage in [Firestore]
    ///

    await checkInDoc.update({'PhotoUrls': photoUrls});
  }

// Create a list of the photos that we will see as a preview of our post!
  Widget listOfPhotos() {
    return SizedBox(
        width: double.infinity,
        height: widgetHeight - 200,
        child: ListView.builder(
            itemCount: _images.length,
            itemBuilder: (BuildContext context, int index) {
              Asset asset = _images[index];
              return Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                      child: AssetThumb(
                          width: asset.originalWidth,
                          height: asset.originalWidth,
                          asset: asset)));
            }));
  }

  Widget mainWidget;

  void createCheckIn() {
    checkInDoc = widget.zones
        .doc(widget.zone)
        .collection("Area")
        .doc(widget.area)
        .collection("Spots")
        .doc(widget.spotId)
        .collection("VisitedUsers")
        .doc(myId)
        .collection("CheckIns")
        .doc(widget.checkInId);

    // Create a check in. The user can then update photos, title, and message should they choose, but they can also skip.
    checkInDoc.set({
      "TimeStamp": Timestamp.now(),
      "Date": DateTime.now().toString(),
      "message": "",
      "title": "Check In on iphone",
      "PhotoUrls": [],
    });
  }

  Widget addPhotosPage(Widget mainWidget) {
    final widgetWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: widgetWidth / 1.05,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10),
              Center(child: Text("${widget.message} ${widget.spotName}")),
              SizedBox(
                height: 10.0,
              ),
              Center(
                child: Text("A check in needs some photos!"),
              ),
              SizedBox(
                height: 15.0,
              ),
              mainWidget ?? SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    widgetHeight = MediaQuery.of(context).size.height;
    // Initial call if we want it here. Kinda jarring for users to just have photo selector open, but it does reduce clicks in post.
    loadAssets();
    createCheckIn();
    return Scaffold(
        appBar: AppBar(
          title: Text("Add Photos"),
          leading: IconButton(
              onPressed: () {
                loadAssets();
              },
              icon: Icon(Icons.add_a_photo_rounded)),
          actions: [
            Container(
                child: InkWell(
                    onTap: () {
                      _savePhotos();
                      if (_images.length != 0) {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                          return AddDescription(widget.creationId,
                              widget.fullId, widget.checkInId);
                        }));
                      }
                    },
                    child: Center(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Next"),
                    ))))
          ],
        ),
        body: addPhotosPage(mainWidget));
    //body: Center(child: mainWidget));
  }
}
