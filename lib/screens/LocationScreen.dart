import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class LocationScreen extends StatefulWidget {
  String id;
  String zone;
  String spotId;
  String area;
  LocationScreen(String id) {
    // Repetetive ... need a library for this hahahah.. but just taking in the full id and then splitting it into the chunks we need like normal.
    this.id = id;
    var split = id.split("/");
    this.zone = split[0];
    this.spotId = split[1];
    var areaSplit = this.spotId.split(";");

    this.area =
        "${areaSplit[0].substring(0, 3)};${areaSplit[1].substring(0, 2)}";
  }

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Future<DocumentSnapshot> getSpotData() async {
    return FirebaseFirestore.instance
        .collection("Zones")
        .doc(widget.zone)
        .collection("Area")
        .doc(widget.area)
        .collection("Spots")
        .doc(widget.spotId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSpotData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
                appBar: AppBar(title: Text(snapshot.data["Name"])),
                body: Center(
                  child: Text("This spot is a ${snapshot.data["Genre"]}"),
                ));
          } else {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
