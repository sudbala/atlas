import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/model/CheckInOrder.dart';
import 'package:atlas/screens/CheckIn/feedCheckIn.dart';
import 'package:atlas/screens/CustomAppBar.dart';
import 'package:atlas/screens/Notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:atlas/screens/CheckIn/SelectSpot.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class Feed extends StatefulWidget {
  Feed({Key key}) : super(key: key);
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> with WidgetsBindingObserver {
  int numPostLoaded;
  List finalCheckIns;
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    numPostLoaded = 5;
    finalCheckIns = [];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Stream friendCheckInStream(List friends) {
    List<Stream<DocumentSnapshot>> friendsCheckIn = List();
    for (String friendId in friends) {
      friendsCheckIn.add(
        FirebaseFirestore.instance
            .collection("CheckIns")
            .doc(friendId)
            .snapshots(),
      );
    }
    return StreamZip(friendsCheckIn);
  }

  Stream feedStream(Map postToLoad) {
    List<Stream> streams = List();
    List<CheckInOrder> checkIns = List();
    for (String userId in postToLoad.keys) {
      for (String post in postToLoad[userId]) {
        CheckInOrder postCheckIn = CheckInOrder(post);
        postCheckIn.userId = userId;
        checkIns.add(postCheckIn);
      }
    }
    checkIns.sort((a, b) => a.postDate.compareTo(b.postDate));
    int loadThisMany;
    if (checkIns.length > numPostLoaded) {
      loadThisMany = numPostLoaded;
    } else {
      loadThisMany = checkIns.length;
    }
    for (int i = checkIns.length - 1;
        i >= checkIns.length - loadThisMany;
        i--) {
      CheckInOrder check = checkIns[i];
      streams.add(FirebaseFirestore.instance
          .collection("Zones")
          .doc(check.zone)
          .collection("Area")
          .doc(check.area)
          .collection("Spots")
          .doc(check.spotId)
          .collection("VisitedUsers")
          .doc(check.userId)
          .collection("CheckIns;${check.userId}")
          .doc(check.checkInId)
          .snapshots());
    }
    return StreamZip(streams);
  }

  Future<void> _getData() async {
    setState(() {
      numPostLoaded = 5;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        numPostLoaded = 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
            "Atlas",
            <Widget>[
              IconButton(
                icon: Icon(Icons.notifications_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return Notifications();
                  }));
                },
              ),
              IconButton(
                icon: Icon(Icons.rate_review_rounded),
                onPressed: () {
                  // This is the very start of a check in. Lets head over into our map in which we select where we would like to make a check in
                  Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return SelectSpot();
                  }));
                },
              )
            ],
            context,
            Container()),
        body:

            /// Oh boy 3 nested StreamBuilders
            StreamBuilder(
          // First stream grabs the users information to get all their friends
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(myId)
              .snapshots(),
          builder: (context, docSnapshot) {
            if (docSnapshot.hasData) {
              // Once we have data make a list of all the friends userIds
              List friends = [];
              // Make sure they are actually friends and not just requested.
              for (String friend in docSnapshot.data["Friends"].keys) {
                if (docSnapshot.data["Friends"][friend] == 2) {
                  friends.add(friend);
                }
              }
              // We can add our own id so our own posts show up here
              friends.add(myId);

              return StreamBuilder(
                  // Call the next stream
                  // Given a list of friends this will return a list of snapshot where each snapshot is the document containing all a user's checkins in list format
                  stream: friendCheckInStream(friends),
                  builder: (context, snapshot) {
                    // Create a map of post that has key being userId and value is list of checkIns.
                    Map postToLoad = Map();
                    if (snapshot.hasData) {
                      // Go through each user
                      List<DocumentSnapshot> docSnaps = snapshot.data.toList();
                      for (int i = 0; i < docSnaps.length; i++) {
                        // For now we limit the posts in a feed of one user to 5
                        DocumentSnapshot checkDoc = docSnaps[i];
                        List allCheckIns = checkDoc.data()["CheckIns"];

                        // if we have more than 5 checkIns just take the last 5.
                        if (allCheckIns.length > 5) {
                          postToLoad[friends[i]] = (allCheckIns.sublist(
                              allCheckIns.length - 5, allCheckIns.length));
                        } else {
                          postToLoad[friends[i]] = allCheckIns;
                        }
                      }
                      return StreamBuilder(
                          // returns a list of streams

                          stream: feedStream(postToLoad),
                          builder: (context, lastSnap) {
                            ScrollController scrollController =
                                ScrollController();
                            scrollController.addListener(() {
                              if (scrollController.position.pixels >=
                                  scrollController.position.maxScrollExtent -
                                      100) {
                                setState(() {
                                  // load 5 more posts WOOOO
                                  numPostLoaded += 5;
                                });
                              }
                            });
                            if (lastSnap.hasData) {
                              finalCheckIns = [];

                              for (DocumentSnapshot checkIn
                                  in lastSnap.data.toList()) {
                                //Make sure the check in has the photos uploaded before we try to access them.
/*
                                if ((List<String>.from(checkIn["PhotoUrls"]))
                                        .length !=
                                    0) {
                                      */
                                finalCheckIns.add(CheckIn(
                                  checkInTitle: checkIn['title'],
                                  checkInDescription: checkIn['message'],
                                  photoURLs:
                                      List<String>.from(checkIn['PhotoUrls']),
                                  checkInDate: checkIn['Date'],
                                  checkInID: checkIn.id,
                                  checkInProfileId: checkIn["profileId"],
                                  checkInUserName: checkIn["UserName"],
                                  timeStamp: checkIn["TimeStamp"],
                                ));
                                // }
                              }

                              return RefreshIndicator(
                                  onRefresh: _getData,
                                  child: ListView.builder(
                                    controller: scrollController,
                                    itemCount: finalCheckIns.length,
                                    itemBuilder: (context, index) {
                                      return FeedCheckIn(finalCheckIns[index]);
                                    },
                                  ));
                            } else if (lastSnap.hasError) {
                              print(lastSnap.error);
                            } else {
                              return Container(
                                  child: Center(
                                      child: CircularProgressIndicator()));
                            }
                          });
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                    } else {
                      return Container(
                          child: Center(child: CircularProgressIndicator()));
                    }
                  });
            } else if (docSnapshot.hasError) {
              print(docSnapshot.error);
            } else {
              return Container(
                  child: Center(child: CircularProgressIndicator()));
            }
          },
        ));
  }
}
