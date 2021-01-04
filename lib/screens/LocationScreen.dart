import 'dart:async';

import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/AddPhotos.dart';
import 'package:atlas/screens/CheckIn/CheckInPost.dart';
import 'package:atlas/screens/CheckIn/feedCheckIn.dart';
import 'package:atlas/screens/CustomAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utm/utm.dart';

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
  List fWHVS;
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder(
        // oh the inefficency... Need this data anyways to see that the list of friends who have visited can change.
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(myId)
            .collection("visibleZones")
            .doc(widget.data["zone"])
            .collection('Area')
            .doc(widget.area)
            .collection('Spots')
            .doc("${widget.data["Northing"]};${widget.data["Easting"]}")
            .snapshots(),
        builder: (context, docSnapshot) {
          if (docSnapshot.hasData) {
            fWHVS = docSnapshot.data["FriendsWhoHaveVisited"];
            if (fWHVS.length > 0) {
              return innerStream(widget.data, widget.area, fWHVS);
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

class innerStream extends StatelessWidget {
  Map data;
  String area;
  List fWHVS;
  int postPerFriendToLoad = 2;
  innerStream(Map data, String area, List fWHVS) {
    this.data = data;
    this.area = area;
    this.fWHVS = fWHVS;
  }

  List checkIns;

  Stream friendCheckIns() {
    List<Stream> checkInStreams = List();
    CollectionReference allCheckIns = FirebaseFirestore.instance
        .collection('Zones')
        .doc(data["zone"])
        .collection('Area')
        .doc(area)
        .collection('Spots')
        .doc("${data["Northing"]};${data["Easting"]}")
        .collection('VisitedUsers');

    if (fWHVS.length != 0) {
      for (String friend in fWHVS) {
        checkInStreams.add(allCheckIns
            .doc(friend)
            .collection("CheckIns;$friend")
            // Don't really need to order by timeStamp if we are sorting later i guess.
            .orderBy("TimeStamp", descending: true)
            //.limit()
            //Any limiting here will limit by user. Not really what we want to be honest. We could lazily rationalize it by saying that its nice it doesn't overwhelm the spot with 1 users info
            // Maybe its better to see 1 users most recent post and another friends post from a while ago. as opposed to two from the same user... idk.
            // We could switch over to a more similar strategy of the feed but I am tooo lazy.
            .snapshots());
      }
    }

    return StreamZip(checkInStreams);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: friendCheckIns(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List streams = snapshot.data.toList();
            checkIns = [];

            List checkInCollections = streams;
            if (checkInCollections.length > 0) {
              // Go through each stream of a friends CheckIns
              for (QuerySnapshot friendCheckIn in checkInCollections) {
                List<DocumentSnapshot> checkInSnapShots = friendCheckIn.docs;
                // Go through each CheckIn document of this current friend
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
            }

            if (checkIns.length != 0) {
              // Sort the checkIns by time
              checkIns.sort((b, a) => (a.timeStamp).compareTo(b.timeStamp));
              // Create the list of all the checkIns
              return ListView.builder(
                //controller: scrollController,
                itemCount: checkIns.length,
                itemBuilder: (context, index) {
                  return FeedCheckIn(checkIns[index]);
                },
              );
            } else {
              return Text(
                  "None of your friends have checked in here before, take them with you next time!");
            }
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Container(child: Center(child: CircularProgressIndicator()));
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
  UtmCoordinate coord;
  String url;

  @override
  bool get wantKeepAlive => true;

  void initState() {
    super.initState();
    tController = TabController(length: 2, vsync: this);
    personalPostsLoaded = 3;
    friendsPostLoaded = 5;
    coord = UTM.fromUtm(
        easting: double.parse(widget.data["Easting"]),
        northing: double.parse(widget.data["Northing"]),
        zoneNumber: int.parse(widget.data["zone"].substring(0, 2)),
        zoneLetter: widget.data["zone"].substring(2));
// Url that will be sent to google maps should the user try to get directions to a spot!
    url =
        'https://www.google.com/maps/dir/?api=1&destination=${coord.lat},${coord.lon}&travelmode=driving&dir_action=navigate';
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
        .collection('CheckIns;$myId');
    //Return the snapshots of the users check INs. Order by timestamp descending and limit the number of posts
    // Once the user scrolls down more we can load more posts!
    return myCheckIns
        .orderBy("TimeStamp", descending: true)
        .limit(personalPostsLoaded)
        .snapshots();
  }

// Method for opening up the url with directions to the location in google maps
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          // load 3 more posts WOOOO
          personalPostsLoaded += 3;
        });
      }
    });
    List<CheckIn> checkIns;
    return Scaffold(
        appBar: CustomAppBar(
          widget.data["Name"],
          <Widget>[
            IconButton(
              icon: Icon(Icons.map),
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'mainScreen',
                    // data to be sent to the homescreen so that it knows to go back to the map and specifically open the map
                    arguments: {
                      "startIndex": 1,
                      "mapStart": LatLng(coord.lat, coord.lon)
                    });
              },
            ),
            IconButton(
              icon: Icon(Icons.directions_car_rounded),
              onPressed: () {
                _launchURL(url);
              },
            ),
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
          context,
          null,
          TabBar(
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
                            return FeedCheckIn(checkIns[index]);
                          });
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
