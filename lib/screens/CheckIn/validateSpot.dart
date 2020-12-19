import 'dart:math';

import 'package:atlas/screens/CheckIn/AddPhotos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utm/utm.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

// After picking a spot on the map we will check the database to see how to handle this spot
// The three cases are:
// User has never been to spot and in fact spot has never been vistied by any atlas user
// User has never been to spot but spot indeed has been visted by another atlas user.
// User has been to spot before and is just checking in again
// ignore: must_be_immutable
class ValidateSpot extends StatefulWidget {
  UtmCoordinate spotUTM;
  ValidateSpot(spotUTM) {
    this.spotUTM = spotUTM;
  }

  @override
  _ValidateSpotState createState() => _ValidateSpotState();
}

class _ValidateSpotState extends State<ValidateSpot> {
  bool userHasBeen = false;
  double minDistance =
      200; // meters about 2 football fields. can be played with

  CollectionReference zones = FirebaseFirestore.instance.collection("Zones");

  String zone;
  String area;
  String spotId;
  DocumentReference areaDoc;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

// This method checks if a spot has been discovered before and handles accordingly
  Future<List<String>> validateSpot() async {
    // The first step is to make sure we have created a zone for this spot
    // the utm will tell us the zone
    double closestDistance = double.infinity;
    String closestId;

    zone = "${widget.spotUTM.zone}";
    String message;
    // We create the area of a spot by taking the first 3 digits of the Northing and the first two of the Easting and seperating them by a semicolon
    area =
        "${widget.spotUTM.northing.toString().substring(0, 3)};${widget.spotUTM.easting.toString().substring(0, 2)}";
    // The spotId is the same format as the area but the entire Northing and Easting
    spotId =
        "${widget.spotUTM.northing.toString()};${widget.spotUTM.easting.toString()}";

    // Check if this area has any spots.
    DocumentSnapshot areaSnap =
        await zones.doc(zone).collection("Area").doc(area).get();

    areaDoc = zones.doc(zone).collection("Area").doc(area);

    if (areaSnap.exists) {
      // There have been spots in this area. time to query and see if we are too close to any of them.
      // Ill add a spot anyway now just kicks and assume there were no spots close enough so this one actually did get its own!

      QuerySnapshot spotShot = await areaDoc.collection("Spots").get();

      // go through each document in the spots collection of a given area. Ugh linear time :(

      spotShot.docs.forEach((document) {
        Map<String, dynamic> data = document.data();

        double Northing = data["Northing"];

        double Easting = data["Easting"];

        // euclidean distance should work find for points close together (same area) https://math.stackexchange.com/questions/738529/distance-between-two-points-in-utm-coordinates
        double distance = sqrt(pow((Easting - widget.spotUTM.easting), 2) +
            pow(Northing - widget.spotUTM.northing, 2));

        /// Check to see if the distance between two spots is less than set minDistance. Find the closest one.
        if (distance < minDistance) {
          if (distance < closestDistance) {
            closestId = "${document.id}";
            closestDistance = distance;
          }
        }
      });

      // If we have a new closestDistance it means that we don't need to make a new spot

      if (closestDistance < double.infinity) {
        // don't make a new spot USE closestID from here on out!!!
        // Now check if the user has ever discovered this place before.
        DocumentSnapshot checkInSnap = await areaDoc
            .collection("Spots")
            .doc(closestId)
            .collection("VisitedUsers")
            .doc(myId)
            .get();
        // If the user has already been here we will greet them with a welcome back
        if (checkInSnap.exists) {
          message = "Welcome back to";
          return Future.value(["1", message, "$zone/$closestId"]);
        } else {
          // have the document show that the user has visited, it is there first time
          await areaDoc
              .collection("Spots")
              .doc(spotId)
              .collection("VisitedUsers")
              .doc(myId)
              .set({"hasVisited": true});
          // If the user has never checked in here before we will greet them with a Congratulations on exploring (which is different than discovering)
          message = "Congratulations on exploring";
          return Future.value(["1", message, "$zone/$spotId"]);
        }
      } else {
        // if we weren't too close then make a new spot!
        return Future.value(
            ["0", "Congratulations on discovering", "$zone/$spotId"]);
      }
    } else {
      // this area has no spots! lets make one.
      // Grab a document reference.

      // Create a document for the area
      await areaDoc.set({"exist": true});

      // return that this spot is new with a message of congratulations.
      return Future.value(
          ["0", "Congratulations on discovering", "$zone/$spotId"]);
    }
  }

  Future<void> _saveSpot(String title, String genre) async {
    // Set the genre , northing, easting, and title of a spot
    // I need to switch the genre to a selection menu but i'm too lazy right now.
    var split = spotId.split(";");

    double Northing = double.parse(split[0]);
    double Easting = double.parse(split[1]);

    // Mark user has visited this spot
    await areaDoc
        .collection("Spots")
        .doc(spotId)
        .collection("VisitedUsers")
        .doc(myId)
        .set({"hasVisited": true});

    // Create the spot
    return areaDoc.collection("Spots").doc(spotId).set({
      "Northing": Northing,
      "Easting": Easting,
      "Name": title,
      "Genre": genre,
    });
  }
// Pulled this from the onboarding... might want to make an object for it later when we also put this in settings...

  Widget createSpotPage() {
    final widgetWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: widgetWidth / 1.1,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text("Enter a Name and type of spot!"),
              ),
              SizedBox(
                height: 25.0,
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(20.0),
                      ),
                    ),
                    filled: true,
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Pick a good name",
                    fillColor: Colors.white70),
              ),
              SizedBox(
                height: 25.0,
              ),
              Container(
                child: TextField(
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                  controller: _bioController,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(20.0),
                        ),
                      ),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "What type of spot is this?",
                      fillColor: Colors.white70),
                ),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blue)),
                color: Colors.white,
                textColor: Colors.blue,
                padding: EdgeInsets.all(8.0),
                onPressed: () async {
                  await _saveSpot(_nameController.text, _bioController.text);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return AddPhotos(
                        "Congratulations on discovering", "$zone/$spotId");
                  }));
                },
                child: Text(
                  "Save".toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: validateSpot(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child;
          if (snapshot.hasData) {
            if (snapshot.data[0] == "0") {
              // This was a brand new spot. We need the user to name it and give it a genre.
              child = createSpotPage();
            } else if (snapshot.data[0] == "1") {
              // This was a spot that has been discovered but not for this user.
              // Push the user to the add photo pages.
              child = Center(child: CircularProgressIndicator());
              print("${snapshot.data[2]}");
              return AddPhotos(snapshot.data[1], snapshot.data[2]);
            }
          } else if (snapshot.hasError) {
            child = Center(child: Text("error occured"));
          } else {
            child = Center(child: CircularProgressIndicator());
          }

          return Scaffold(appBar: AppBar(), body: child);
        });
  }
}
