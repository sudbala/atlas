import 'package:atlas/screens/MainScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class AddDescription extends StatefulWidget {
  String creationId;
  String fullId;

  AddDescription(String creationId, String fullId) {
    this.creationId = creationId;
    this.fullId = fullId;
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

  void addToVisibleSpots() {
    // We need to check if a user had this spot already in their profile of places they can view on map

    // If they don't
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
                // We need to add it to the user's explored page

                if (widget.creationId != "2") {
                  addToExploredSpots();
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
