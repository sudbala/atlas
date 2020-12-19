import 'package:atlas/screens/CheckIn/AddDescription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class AddPhotos extends StatefulWidget {
  String title;
  String spotId;
  String zone;
  String area;
  String checkInId;
  AddPhotos(String title, String spotId) {
    this.title = title;
    var split = (spotId.split("/"));

    this.zone = split[0];
    this.spotId = split[1];
    var areaSplit = this.spotId.split(";");
    this.area =
        "${areaSplit[0].substring(0, 3)};${areaSplit[1].substring(0, 2)}";
    this.checkInId = DateTime.now().toString();
  }

  @override
  _AddPhotosState createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  void createCheckIn() {
    CollectionReference zones = FirebaseFirestore.instance.collection("Zones");

    DocumentReference checkInDoc = zones
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
      "Date": DateTime.now().toString(),
      "message": "",
      "title": "Check In",
      "PhotoUrls": null
    });
  }

  @override
  Widget build(BuildContext context) {
    createCheckIn();
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("${widget.title}"),
          Text("${widget.spotId}"),
          Text("Lets Add some Photos to this Check In"),
          ElevatedButton(
              child: Text("Skip"),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return AddDescription();
                }));
              }),
        ],
      )),
    );
  }
}
