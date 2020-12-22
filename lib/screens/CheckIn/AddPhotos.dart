import 'package:atlas/screens/CheckIn/AddDescription.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    this.checkInId = DateTime.now().toString();

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
  void createCheckIn() {
    DocumentReference checkInDoc = widget.zones
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
      "PhotoUrls": null,
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
          Text("${widget.message}"),
          Text("${widget.spotName}"),
          Text("Lets Add some Photos to this Check In"),
          ElevatedButton(
              child: Text("Skip"),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return AddDescription(widget.creationId, widget.fullId);
                }));
              }),
        ],
      )),
    );
  }
}
