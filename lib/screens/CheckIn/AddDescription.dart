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
      // If this is you who just explored it, update to reflect that this is a spot you have personally explored
      if (userId == myId) {
        spotRef.update({"havePersonallyExplored": true});
      } else {
        // If this was a friend that just explored this place for the first time, but you alread had on your visible spots
        // Update FriendsWhoHaveVisited to include this user who just discovered it for themselves for the first time.
        // Remember that just because two people have mutual friends does not mean they see the same spots. You only see a spot if your immediate friend
        // has actually discovered it.
        spotRef.update({
          "FriendsWhoHaveVisited": FieldValue.arrayUnion([myId])
        });
      }
      return Future.value(true);
    } else {
      List FWHVlist; // FriendsWhoHaveVisited list
      // if the user didn't already have this spot in their visible spots then set it
      if (userId == myId) {
        personallyExplored = true;
        FWHVlist = [];
      } else {
        personallyExplored = false;
        FWHVlist = [myId];
      }

      // Don't love having to read this in... Not sure i set the data structures up that well... but so far i see advantages and disadvantages to any way that I cut it...
      Map spotData = ((await FirebaseFirestore.instance
              .collection("Zones")
              .doc(widget.zone)
              .collection("Area")
              .doc(widget.area)
              .collection("Spots")
              .doc(widget.spotId)
              .get())
          .data());
      spotRef.set({
        "Easting": widget.easting,
        "Northing": widget.northing,
        "FriendsWhoHaveVisited": FWHVlist,
        "havePersonallyExplored": personallyExplored,
        "Genre": spotData["Genre"],
        // Will include the name here, will allow for querying personal visible spots and less reads eventhough it will take a bit more space

        "Name": spotData["Name"],
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

  void updateFriendsVisibleSpots() async {
    // anytime a user discovers or explores a spot (creationid 0 or 1), we need to update all their friend's visble spots to show that this user has explored those spots

    // GO through all friends of this user and call addToVisibleSpots
    Map friends = (await userDoc.get()).data()["Friends"];
    friends.keys.forEach((friendId) {
      if (friends[friendId] == 2) {
        print(friendId);
        addToVisibleSpots(friendId);
      }
    });
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
                  updateFriendsVisibleSpots();
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
