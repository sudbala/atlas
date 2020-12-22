import 'dart:math';

import 'package:atlas/screens/CheckIn/AddPhotos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
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

  double minDistance = 120; // meters

  CollectionReference zones = FirebaseFirestore.instance.collection("Zones");

  String zone;
  String area;
  String spotId;
  DocumentReference areaDoc;
  final _nameController = TextEditingController();

  // Selected Value of dropdown menu for spot genre selection when a spot is created.
  String selectedValue;
  // Possible selection values for the spot genre / type menu selection.

  List<String> possibleSpotTypes = [
    "Swimming Hole",
    "Hot Springs",
    "Viewpoint",
    "Skate Spot",
    "Surf Break",
    "Campsite",
    "Wild Camp",
    "Hidden Gem",
    "Park",
  ];
  List<DropdownMenuItem> items = [];

  @override
  void initState() {
    // When we create the state turn the possible spot types into DropDownMenu Items..
    possibleSpotTypes.forEach((type) {
      items.add(DropdownMenuItem(
        child: Text(type),
        value: type,
      ));
    });
    super.initState();
  }

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

    areaDoc = zones.doc(zone).collection("Area").doc(area);

    // Check if this area has any spots.
    DocumentSnapshot areaSnap = await areaDoc.get();

    if (areaSnap.exists) {
      // There have been spots in this area. time to query and see if we are too close to any of them.
      // Go through all the spots in this area. this way we only have to read 1 document
      print("${areaSnap.data()["spotsInArea"]}");

      areaSnap.data()["spotsInArea"].forEach((id) {
        /// Split the spot id into
        var idSplit = id.split(";");

        double Northing = double.parse(idSplit[0]);

        double Easting = double.parse(idSplit[1]);

        // euclidean distance should work find for points close together (same area) https://math.stackexchange.com/questions/738529/distance-between-two-points-in-utm-coordinates
        double distance = sqrt(pow((Easting - widget.spotUTM.easting), 2) +
            pow(Northing - widget.spotUTM.northing, 2));

        /// Check to see if the distance between two spots is less than set minDistance. Find the closest one.
        if (distance < minDistance) {
          if (distance < closestDistance) {
            closestId = "$id";
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

        // Another read I don't love, won't have to happen if a user does a check in from their map
        String spotName =
            ((await areaDoc.collection("Spots").doc(closestId).get())
                .data())["Name"];
        // If the user has already been here we will greet them with a welcome back
        if (checkInSnap.exists) {
          message = "Welcome back to";
          return Future.value(["2", spotName, "$zone/$closestId"]);
        } else {
          // have the document show that the user has visited, it is there first time
          await areaDoc
              .collection("Spots")
              .doc(closestId)
              .collection("VisitedUsers")
              .doc(myId)
              .set({"hasVisited": true});
          // If the user has never checked in here before we will greet them with a Congratulations on exploring (which is different than discovering)
          message = "Congratulations on exploring";
          return Future.value(["1", spotName, "$zone/$closestId"]);
        }
      } else {
        // if we weren't too close then make a new spot!
        return Future.value(["0", "NeedToMakeName", "$zone/$spotId"]);
      }
    } else {
      // this area has no spots! lets make one.

      //Create a document for the area
      await areaDoc.set({"spotsInArea": new List<String>()});

      // return that this spot is new with a message of congratulations.
      return Future.value(["0", "NeedTOMakename", "$zone/$spotId"]);
    }
  }

  Future<void> _saveSpot(String title, String genre) async {
    // Set the genre , northing, easting, and title of a spot

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

    // add the spot to the list of spots in this area. Will help with future searching
    await areaDoc.update({
      "spotsInArea": FieldValue.arrayUnion(["$spotId"])
    });
    // Create the spot
    return areaDoc.collection("Spots").doc(spotId).set({
      "Northing": Northing,
      "Easting": Easting,
      "Name": title,
      "Genre": genre,
    });
  }
// Pulled this from the onboarding... might want to make an object for it later when we also put this in settings...
// CreateSpot page creates the page that is loaded when I spot needs to be created. ASk the user for a title and genre of the spot

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
                  child: Text(
                      " Wow, you are the very first Atlas user to discover this spot!")),
              SizedBox(
                height: 25.0,
              ),
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
                  // Use a dropdown menu that is search able to let the user pick what type of spot this is.
                  //  I like it but not sure how to customize its color and such
                  // Maybe just put a box around it and color that.
                  child: SearchableDropdown.single(
                items: items,
                value: selectedValue,
                hint: "What Type of Spot is this?",
                searchHint: null,
                onChanged: (value) {
                  // Update value of selectedValue. selectedValue will be sent to save when the user is ready.
                  setState(() {
                    selectedValue = value;
                  });
                },
                // must be false
                //dialogBox: false,
                isExpanded: true,
                // Size of the box when it expands to the search menu
                // menuConstraints: BoxConstraints.expand(
                //height: menuHeight - viewInsets.bottom)),
              )
                  //BoxConstraints.tight(Size.fromHeight(menuHeight)),
                  ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blue)),
                color: Colors.white,
                textColor: Colors.blue,
                padding: EdgeInsets.all(8.0),
                onPressed: () async {
                  // Call SaveSpot and then once that is done move on to the next part!
                  await _saveSpot(_nameController.text, selectedValue);
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return AddPhotos(
                        "0", "$_nameController.text", "$zone/$spotId");
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
            } else {
              // This was a spot that has been discovered but not for this user.
              // Push the user to the add photo pages.
              child = Center(child: CircularProgressIndicator());

              return AddPhotos(
                  snapshot.data[0], snapshot.data[1], snapshot.data[2]);
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
