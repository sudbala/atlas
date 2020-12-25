import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/AddPhotos.dart';
import 'package:atlas/screens/CheckIn/CheckInPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class LocationScreen extends StatefulWidget {
  Map data;
  String creationId;
  String area;

  LocationScreen(Map data) {
    this.data = data;
    if (data["havePersonallyExplored"] == true) {
      creationId = "2";
    } else {
      creationId = "1";
    }
    this.area =
        "${data["Northing"].substring(0, 3)};${data["Easting"].substring(0, 2)}";
  }

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with SingleTickerProviderStateMixin {
  TabController tController;
  int personalPostsLoaded;

  void initState() {
    super.initState();
    tController = TabController(length: 2, vsync: this);
    personalPostsLoaded = 5;
  }

  Stream friendCheckIns() {
    CollectionReference allCheckIns = FirebaseFirestore.instance
        .collection('Zones')
        .doc(widget.data["zone"])
        .collection('Area')
        .doc(widget.area)
        .collection('Spots')
        .doc("${widget.data["Northing"]};${widget.data["Easting"]}")
        .collection('VisitedUsers');

    list FWHVS = data["FriendsWhoHaveVisited"];
  }

  Stream personalCheckIns() {
    CollectionReference myCheckIns = FirebaseFirestore.instance
        .collection('Zones')
        .doc(widget.data["zone"])
        .collection('Area')
        .doc(widget.area)
        .collection('Spots')
        .doc("${widget.data["Northing"]};${widget.data["Easting"]}")
        .collection('VisitedUsers')
        .doc(myId)
        .collection('CheckIns');
    // We are gonna return the snapshots of a query, ordering it by date and limiting it to 2 post for now
    // Then we can use listController to tell us when we need to add more I think.
    return myCheckIns
        .orderBy("TimeStamp", descending: true)
        .limit(personalPostsLoaded)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    double tHeight = MediaQuery.of(context).size.height * (1 / 13);
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          // load 5 more posts WOOOO
          personalPostsLoaded += 5;
        });
      }
    });
    List checkIns;
    return Scaffold(
        appBar: AppBar(
          // toolbarHeight: tHeight,
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
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Friends",
              ),
              Tab(text: "Me"),
            ],
            controller: tController,
            //labelColor: Colors.blue,
          ),
        ),
        body: TabBarView(
          controller: tController,
          children: [
            Center(child: Text("FriendsGo here")),
            StreamBuilder(
                stream: personalCheckIns(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    checkIns = [];
                    List<DocumentSnapshot> checkInSnapShots =
                        snapshot.data.docs;
                    for (DocumentSnapshot checkIn in checkInSnapShots) {
                      //Make sure the check in has the photos uploaded before we try to access them.
                      if ((List<String>.from(checkIn["PhotoUrls"])).length !=
                          0) {
                        checkIns.add(CheckIn(
                          checkInTitle: checkIn['title'],
                          checkInDescription: checkIn['message'],
                          photoURLs: List<String>.from(checkIn['PhotoUrls']),
                          checkInDate: checkIn['Date'],
                          checkInID: checkIn.id,
                        ));
                      }
                      //}

                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: checkIns.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) {
                                    /// Return the associated checkIn
                                    return CheckInPost(
                                      checkIn: checkIns[index],
                                      userName: "needUsername",
                                    );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              height: 300,
                              child: Text(
                                "Check In: " + checkIns[index].checkInTitle,
                              ),
                            ));
                      },
                    );
                  } else {
                    return Container(
                        child: Center(child: CircularProgressIndicator()));
                  }
                })
          ],
        ));
  }
}
