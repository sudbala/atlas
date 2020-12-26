import 'dart:async';

import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/AddPhotos.dart';
import 'package:atlas/screens/CheckIn/CheckInPost.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class friendsPage extends StatefulWidget {
  Map data;
  String area;
  friendsPage(Map data) {
    this.data = data;
    this.area =
        "${data["Northing"].substring(0, 3)};${data["Easting"].substring(0, 2)}";
  }
  @override
  _friendsPageState createState() => _friendsPageState();
}

class _friendsPageState extends State<friendsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Stream friendCheckIns() {
    List<Stream<QuerySnapshot>> checkInStreams = List();
    CollectionReference allCheckIns = FirebaseFirestore.instance
        .collection('Zones')
        .doc(widget.data["zone"])
        .collection('Area')
        .doc(widget.area)
        .collection('Spots')
        .doc("${widget.data["Northing"]};${widget.data["Easting"]}")
        .collection('VisitedUsers');

    List fWHVS = widget.data["FriendsWhoHaveVisited"];
    for (String friend in fWHVS) {
      print(friend);
      checkInStreams.add(allCheckIns
          .doc(friend)
          .collection("CheckIns")
          .orderBy("TimeStamp", descending: true)
          //.limit(1) Any limiting here will limit by user. Not really what we want to be honest. We could lazily rationalize it by saying that its nice it doesn't overwhelm the spot with 1 users info
          // Maybe its better to see 1 users most recent post and another friends post from a while ago. as opposed to two from the same user... idk.
          .snapshots());
    }

    //return StreamGroup.merge(checkInStreams);
    // BUG DOES NOT WORK IF THERE ARE NO CHECK INs BY ANY FRIENDS>>>>>> AND EVEN ONCE ONE IS ADDED IT will NOT FIX
    /// HOever if app is reloaded all subsequent checkins after the first are okay.
    /// Snapshot.hasData is returning false when there is no data and error out I think, will check for the error when I have time
    return StreamZip(checkInStreams);

    /// ALTERNATIVE WAY

    //This collectionGroup thing is pretty cool but unfortunately would go through every CheckIn... not just the checkIN's under this spot.
    //could maybe do a where spotId is the spot id we are looking for and then have checkIns include their spot id, but I think this would take too long
    // If we already know the spot and we already know the friends who have visited this spot it really shouldnt be that long of  search
  }

  @override
  Widget build(BuildContext context) {
    //HeapPriorityQueue<CheckIn> checkIns = HeapPriorityQueue<CheckIn>(
    List checkIns;
    return StreamBuilder(
        stream: friendCheckIns(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            checkIns = [];

            List<QuerySnapshot> checkInCollections = snapshot.data.toList();
            for (QuerySnapshot friendCheckIn in checkInCollections) {
              List<DocumentSnapshot> checkInSnapShots = friendCheckIn.docs;
              //List<DocumentSnapshot> checkInSnapShots = snapshot.data.docs;
              for (DocumentSnapshot checkIn in checkInSnapShots) {
                //Make sure the check in has the photos uploaded before we try to access them.
                if ((List<String>.from(checkIn["PhotoUrls"])).length != 0) {
                  checkIns.add(CheckIn(
                    checkInTitle: checkIn['title'],
                    checkInDescription: checkIn['message'],
                    photoURLs: List<String>.from(checkIn['PhotoUrls']),
                    checkInDate: checkIn['Date'],
                    checkInID: checkIn.id,
                    checkInProfileId: checkIn["profileId"],
                    checkInUserName: checkIn["UserName"],
                    timeStamp: checkIn["TimeStamp"],
                  ));
                }
              }
            }

            if (checkIns.length != 0) {
              checkIns.sort((b, a) => (a.timeStamp).compareTo(b.timeStamp));
              return ListView.builder(
                //controller: scrollController,
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
                                userName: checkIns[index].userName,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 300,
                        child: Text(
                          "Check In: ${checkIns[index].checkInTitle} \n @${checkIns[index].userName} \n Posted: ${checkIns[index].checkInDate.substring(5, 16)}",
                        ),
                      ));
                },
              );
            } else {
              return Text(
                  "None of your friends have checked in here before, take them with you next time!");
            }
          } else {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}

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
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  TabController tController;
  int personalPostsLoaded;
  int friendsPostLoaded;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    tController = TabController(length: 2, vsync: this);
    personalPostsLoaded = 5;
    friendsPostLoaded = 5;
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
    //Return the snapshots of the users check INs. Order by timestamp descending and limit the number of posts
    // Once the user scrolls down more we can load more posts!
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
    List<CheckIn> checkIns;
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
            friendsPage(widget.data),
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
                          checkInProfileId: checkIn["profileId"],
                          checkInUserName: checkIn["UserName"],
                        ));
                      }
                      //}

                    }
                    if (checkIns.length != 0) {
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
                                        userName: checkIns[index].userName,
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
                      return Text(
                          "No check ins here yet, time to go make some!");
                    }
                  } else {
                    return Container(
                        child: Center(child: CircularProgressIndicator()));
                  }
                })
          ],
        ));
  }
}
