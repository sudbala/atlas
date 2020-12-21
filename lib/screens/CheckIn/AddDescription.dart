import 'package:atlas/screens/MainScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class AddDescription extends StatefulWidget {
  String creationId;
  String fullId;
  String zone;
  String spotId;
  String area;
  String easting;
  String northing;

  AddDescription(String creationId, String fullId) {
    this.creationId = creationId;
    this.fullId = fullId;

    var split = (fullId.split("/"));

    this.zone = split[0];
    this.spotId = split[1];

    var areaSplit = this.spotId.split(";");
    this.northing = areaSplit[0];
    this.easting = areaSplit[1];
    this.area =
        "${this.northing.substring(0, 3)};${this.easting.substring(0, 2)}";
  }
  @override
  _AddDescriptionState createState() => _AddDescriptionState();
}

class _AddDescriptionState extends State<AddDescription> {
  DocumentReference userDoc =
      FirebaseFirestore.instance.collection("Users").doc(myId);
  // When a user discovers or explore a spot it needs to be added to
  void addToExploredSpots() {
    // It is important to keep a list of spots that the user has actually personally explored
    // This will be nice for their profile where they can just look at what they have explored.
    // When two friends become friends we will add all spots from ExploredSpots to each others visible spots section of profile
    // Furthermore when we delete someone as a friend we can remove one's friend id from all the spots that that user has visited

    // Simply add the fullId to the list of explored spots under the user's id.
    userDoc.update({
      "ExploredSpots": FieldValue.arrayUnion(["${widget.fullId}"])
    });
  }

  Future<bool> addToVisibleSpots(String userId) async {
    // We need to check if a user had this spot already in their profile of places they can view on map
    // Get a document snapshot.
    DocumentReference zoneRef = FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .collection("visibleZones")
        .doc(widget.zone);
    DocumentReference areaRef = zoneRef.collection("Area").doc(widget.area);
    DocumentReference spotRef = areaRef.collection("Spots").doc(widget.spotId);

    DocumentSnapshot spotSnap = await spotRef.get();
    bool personallyExplored;
    if (spotSnap.exists) {
      // return a true in order to signify that the spot already existed!
      return Future.value(true);
    } else {
      // if the user didn't already have this spot in their visible spots then set it
      if (userId == myId) {
        personallyExplored = true;
      } else {
        personallyExplored = false;
      }

      // Don't love having to read this in... Not sure i set the data structures up that well... but so far i see advantages and disadvantages to any way that I cut it...
      String genre = ((await FirebaseFirestore.instance
              .collection("Zones")
              .doc(widget.zone)
              .collection("Area")
              .doc(widget.area)
              .collection("Spots")
              .doc(widget.spotId)
              .get())
          .data())["Genre"];
      spotRef.set({
        "Easting": widget.easting,
        "Northing": widget.northing,
        "FriendsWhoHaveVisited": [],
        "havePersonallyExplored": personallyExplored,
        "Genre": genre
      });

      // I need the area and zone documents to exist for future queries. Unfortunately we need to make some extra reads here to make sure they do.
      // start with areaREf. If the area exists then certainly the zone does and we can save a read.
      var areaSnap = await areaRef.get();
      if (!areaSnap.exists) {
        areaRef.set({"exists": true});
        var zoneSnap = await zoneRef.get();
        if (!zoneSnap.exists) {
          zoneRef.set({"exists": true});
        }
      }

      return Future.value(false);
    }

    // If they don't then add it
  }

  void updateFriendsVisibleSpots() {
    // anytime a user discovers or explores a spot (creationid 0 or 1), we need to update all their friend's visble spots to show that this user has explored those spots

    // GO through all friends of this user

    // We can use addToVisibleSpots.
    // if the friend already had this spot as a visible one then just update the "FriendsWhoHaveVisited" array by adding this user id

    // if the friend did not already have this spot as a visible one, then create it as a spot in their collection and add this user id to FriendsWhoHaveVisited

    // This spot will now show up on this user's map, very exciting!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Add a Title and Description to this post!"),
          ElevatedButton(
              child: Text("Skip"),
              onPressed: () {
                // Okay the user has completed the process of a check in.
                ///Now if this was the first check in at a spot ie doesn't have a creation Id of 2 (2 is for returning spot)
                // We need to add it to the user's explored page and visibleSpots!

                if (widget.creationId != "2") {
                  addToExploredSpots();
                  addToVisibleSpots(myId);
                }

                Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return MainScreen();
                }));
              }),
        ],
      )),
    );
  }
}
