import 'package:atlas/screens/CheckIn/AddPhotos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class LocationScreen extends StatefulWidget {
  Map data;
  String creationId;
  String fullId;

  LocationScreen(Map data) {
    this.data = data;
    if (data["havePersonallyExplored"] == true) {
      creationId = "2";
    } else {
      creationId = "1";
    }
  }

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.data["Name"]),
          actions: [
            IconButton(
              icon: Icon(Icons.rate_review_rounded),
              onPressed: () {
                // This is the very start of a check in. Lets head over into our map in which we select where we would like to make a check in
                Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return AddPhotos(widget.creationId, widget.data["Name"],
                      "${widget.data["zone"]}/${widget.data["Northing"]};${widget.data["Easting"]}");
                }));
              },
            )
          ],
        ),
        body: Center(
          child: Text(
              "This spot is a ${widget.data["Genre"]} with time of symbol creation ${widget.data["time"]}"),
        ));
  }
}
