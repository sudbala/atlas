import 'dart:collection';

import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/model/CheckInOrder.dart';
import 'package:atlas/screens/CheckIn/CheckInPost.dart';
import 'package:atlas/screens/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class ProfileScreen extends StatefulWidget {
  final String profileID;
  ProfileScreen(this.profileID);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

// Don't really know what SingleTickerProviderStateMixin is but it allows me to may a tab controller
class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  // A little bit of code to setup a tabController;
  TabController tController;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  // Here we would call to the FireStore database to actually get information on the profile

  // Example Check in's just to see what having a list as one of the tabs feels like.
  final List<String> checkInExample =
      List.generate(50, (index) => "Check In $index");

  int personalPostsLoaded;
  @override
  void initState() {
    super.initState();
    tController = TabController(length: 3, vsync: this);
  }

  int relationShipToProfile;
  List exploredPlaces;

// Set the profile id's
  void setProfiles(int other, int me) {
    users.doc(widget.profileID).update({"Friends.$myId": other});
    users.doc(myId).update({"Friends.${widget.profileID}": me});
  }

  void updateUsersVisibleSpots(String user1, String user2, List user1Explored) {
    user1Explored.forEach((fullSpotId) async {
      var split = fullSpotId.split("/");
      String zone = split[0];
      String spotId = split[1];
      var splitId = spotId.split(";");
      String area =
          "${splitId[0].substring(0, 3)};${splitId[1].substring(0, 2)}";

      DocumentReference zoneRef = FirebaseFirestore.instance
          .collection("Users")
          .doc(user2)
          .collection("visibleZones")
          .doc(zone);
      DocumentReference areaRef = zoneRef.collection("Area").doc(area);
      DocumentReference spotRef = areaRef.collection("Spots").doc(spotId);

      DocumentSnapshot spotShot = await spotRef.get();

      if (spotShot.exists) {
        // If the spot was already in the other user's visible regions just add this friend as someone who has visited. THeir checkins will now show up for this spot
        spotRef.update({
          "FriendsWhoHaveVisited": FieldValue.arrayUnion([user1])
        });
      } else {
        // We need to add this spot into other users visible area.

        // Make sure this area exits and the zone exits! This need to exist for querying later so create them if they don't
        var areaSnap = await areaRef.get();
        if (!areaSnap.exists) {
          areaRef.set({"exists": true});
        }

        // Add this spot from our databases of spots!

        Map data = ((await FirebaseFirestore.instance
                .collection("Zones")
                .doc(zone)
                .collection("Area")
                .doc(area)
                .collection("Spots")
                .doc(spotId)
                .get())
            .data());
        spotRef.set({
          "Easting": data["Easting"].toString(),
          "Northing": data["Northing"].toString(),
          "FriendsWhoHaveVisited": [user1],
          "havePersonallyExplored": false,
          "Genre": data["Genre"],
          "Name": data["Name"],
        });
      }
      // Update the users zones document so that the map knows to reload.
      zoneRef.set({"LastUpdate": DateTime.now().toString()});
    });
  }

  void becomeFriends(String otherProfileId, List exploredPlacesOther) async {
    // Grab user1s list of explored places for myId, we already have the other profile's
    DocumentSnapshot myProfile = await users.doc(myId).get();
    List myExploredSpots = myProfile.data()["ExploredSpots"];

    // Go through all of my explored spots and add them to otherProfileId visibleZones.
    updateUsersVisibleSpots(myId, otherProfileId, myExploredSpots);
    updateUsersVisibleSpots(otherProfileId, myId, exploredPlacesOther);
  }

  Widget profileButton() {
    if (relationShipToProfile == 3) {
      return IconButton(
        icon: Icon(Icons.settings),
        onPressed: () => {
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return SettingsScreen();
          }))
        },
      );
    } else {
      //  Case when viewing someone else's profile page
      String buttonText;
      double scale;
      if (relationShipToProfile == 2) {
        buttonText = "Friends";
        scale = 1;
      } else if (relationShipToProfile == 1) {
        buttonText = "Accept";
        scale = 1;
      } else if (relationShipToProfile == 4) {
        buttonText = "Requested";
        scale = 0.8;
      } else if (relationShipToProfile == 0) {
        buttonText = "Add";
        scale = 1.2;
      }

      return ElevatedButton(
          onPressed: () => {
                if (relationShipToProfile == 1)
                  {
                    setProfiles(2, 2),
                    becomeFriends(widget.profileID, exploredPlaces)
                  }
                // This means we just became friends. So we have to update each other's visibleSpot collection such that user1 has all of user2 explore spots. and vice versa.

                else if (relationShipToProfile == 0)
                  // Set other profile to 4 so I see requested. Set my profile to 1 so they see Accept Friend
                  {setProfiles(4, 1)}
              },
          child: Text(buttonText, textScaleFactor: scale));
    }
  }

  Widget profileHeader(
      double height,
      double width,
      String userName,
      String name,
      String imageUrl,
      String bio,
      int relationShip,
      int numExplored) {
    TransformationController controller = TransformationController();
    return Stack(children: [
      //FittedBox(fit: BoxFit.fitWidth, child: Center(child: Text("$userName"))),
      SizedBox(
        height: height - height * (2 / 5),
        width: double.infinity,
        child: ClipPath(
            clipper: ProfileClipper(),
            child: InteractiveViewer(
                onInteractionEnd: (ScaleEndDetails endDetails) {
                  controller.value = Matrix4.identity();
                },
                child: Image.network("$imageUrl", fit: BoxFit.cover))),
      ),
      Positioned(
          top: height - height * (2 / 5) - 10,
          child: SizedBox(
            //height: 100,
            child: SizedBox(
                width: width,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(children: [
                            SizedBox(
                                width: width * (3 / 5),
                                child: Text(name,
                                    style: GoogleFonts.ebGaramond(
                                        textStyle: TextStyle(
                                            shadows: <Shadow>[
                                          // Playing with some shadows to make the page less 2d, kinda looking cheesy
                                          // If only I was good with graphic design.
                                          Shadow(
                                              offset: Offset(1.0, 1.0),
                                              blurRadius: 3.0,
                                              color: Color.fromRGBO(
                                                  89, 85, 79, 0.8))
                                        ],
                                            fontSize: width * 0.07,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)))),
                            SizedBox(
                                child: Center(child: profileButton()),
                                width: width * (2 / 5) - 30)
                          ]),
                          Text("@$userName",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.andika(
                                  textStyle: TextStyle(
                                fontSize: width * 0.04,
                                color: Colors.white.withOpacity(0.9),
                              ))),
                          SizedBox(height: 4),
                          Text(bio,
                              style: GoogleFonts.andika(
                                  textStyle: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.white,
                              ))),
                          SizedBox(height: 10),
                          Text("Number of Places Explored: $numExplored",
                              style: GoogleFonts.andika(
                                  textStyle: TextStyle(
                                fontSize: width * 0.035,
                                color: Colors.white.withOpacity(0.9),
                              )))
                        ]))),
          )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Profile Height is currently set to 3/5 of user's screen
    double profileHeight = MediaQuery.of(context).size.height * (10 / 10);
    double screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: users.doc(widget.profileID).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            String userName = snapshot.data["UserName"];
            String name = snapshot.data["Name"];
            String bio = snapshot.data["Bio"];
            String profileUrl = snapshot.data["profileURL"];
            exploredPlaces = snapshot.data["ExploredSpots"];

            if (widget.profileID == myId) {
              relationShipToProfile = 3;
            } else {
              // Grab RelationShip to profile from firestore
              relationShipToProfile = (snapshot.data["Friends"])[myId];

              // if there was no data there then assign it to 0
              relationShipToProfile ??= 0;
            }

            return Scaffold(
                // We will use a NestedScrollView so that we can have a sliverAppBar with a Tab bar to differentiate between
                // The different pages of a user's profile.
                body: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  // Create a persistent header. This is where we put the actual profile stuff
                  SliverAppBar(
                    // Whether the par becomes pinned at the top or not
                    pinned: true,
                    // Whether part of the appbar is always there
                    floating: true,
                    snap: true,
                    expandedHeight: profileHeight,

                    flexibleSpace: FlexibleSpaceBar(
                      background: profileHeader(
                          profileHeight,
                          screenWidth,
                          userName,
                          name,
                          profileUrl,
                          bio,
                          relationShipToProfile,
                          exploredPlaces.length),
                    ),
                    bottom: TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.rate_review_rounded),
                        ),
                        Tab(
                          icon: Icon(Icons.favorite_border_rounded),
                        ),
                        Tab(icon: Icon(Icons.map))
                      ],
                      controller: tController,
                      //labelColor: Colors.blue,
                    ),
                  ),
                ];
              },
              // The bulk of a users view.
              body: TabBarView(
                children: [
                  checkInTab(widget.profileID, userName, exploredPlaces),
                  Text("Put a list of all favorite places"),
                  Text("Put a user's heatmap here"),
                ],
                controller: tController,
              ),
            ));
          } else {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}

class ProfileClipper extends CustomClipper<Path> {
  /// getClip() gives back the rounded clipping patter you see on the images.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 1.5, size.height, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    /// Necessary but has no purpose
    return false;
  }
}

class checkInTab extends StatefulWidget {
  String profileID;
  String userName;
  List explored;

  checkInTab(String profileID, String userName, List explored) {
    this.profileID = profileID;
    this.userName = userName;
    this.explored = explored;
  }

  @override
  _checkInTabState createState() => _checkInTabState();
}

class _checkInTabState extends State<checkInTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int personalPostsLoaded;
  List<CheckIn> checkIns;
  List checkInsToLoad;
  bool workAroundReload;
  @override
  void initState() {
    super.initState();
    personalPostsLoaded = 5;
    checkIns = List();
    workAroundReload = false;
  }

  Stream checkInStream(List checkInsToLoad) {
    List<Stream> streams = List();

    for (int i = checkInsToLoad.length - 1; i >= 0; i--) {
      CheckInOrder checkIn = CheckInOrder(checkInsToLoad[i]);
      streams.add(FirebaseFirestore.instance
          .collection("Zones")
          .doc(checkIn.zone)
          .collection("Area")
          .doc(checkIn.area)
          .collection("Spots")
          .doc(checkIn.spotId)
          .collection("VisitedUsers")
          .doc(widget.profileID)
          .collection("CheckIns;${widget.profileID}")
          .doc(checkIn.checkInId)
          .snapshots());
    }
    return StreamZip(streams);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("CheckIns")
            .doc(widget.profileID)
            .snapshots(),
        builder: (context, docSnapshot) {
          if (docSnapshot.hasData) {
            List allCheckIns = docSnapshot.data["CheckIns"];
            int checkInLength = allCheckIns.length;
            if (checkInLength > personalPostsLoaded) {
              checkInsToLoad = allCheckIns.sublist(
                  checkInLength - personalPostsLoaded, checkInLength);
            } else {
              checkInsToLoad = allCheckIns;
            }
            return StreamBuilder(
                stream: checkInStream(checkInsToLoad),
                builder: (context, snapshot) {
                  //Set up some stuff for the check Ins tab scroller to detect when to load more posts.

                  ScrollController scrollController = ScrollController();
                  scrollController.addListener(() {
                    if (scrollController.position.pixels ==
                        scrollController.position.maxScrollExtent) {
                      if (personalPostsLoaded != checkInLength) {
                        setState(() {
                          // load 5 more posts WOOOO
                          if (personalPostsLoaded <= checkInLength - 5) {
                            personalPostsLoaded += 5;
                          } else {
                            personalPostsLoaded = checkInLength;
                          }
                        });
                      }
                    }
                  });

                  if (snapshot.hasData) {
                    checkIns = [];
                    //List<QuerySnapshot> checkInCollections = snapshot.data.toList();
                    // for (QuerySnapshot areaCheckIns in checkInCollections) {
                    for (DocumentSnapshot checkIn in snapshot.data.toList()) {
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
                          timeStamp: checkIn["TimeStamp"],
                        ));
                      }
                    }
                    // }

                  } else if (snapshot.hasError) {
                    print(snapshot.error);

                    if (workAroundReload == false) {
                      workAroundReload = true;
                      Future.delayed(Duration(seconds: 1), () {
                        setState(() {
                          workAroundReload = true;
                        });
                      });
                    }
                  }

                  // a little sorting by time never hurt anyone... right
                  /*
                        checkIns.sort(
                            (b, a) => (a.timeStamp).compareTo(b.timeStamp));

                        */

                  return ListView.builder(
                    //controller: scrollController,
                    itemCount: checkIns.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                /// Return the associated checkIn
                                return CheckInPost(
                                  checkIn: checkIns[index],
                                  userName: widget.userName,
                                );
                              },
                            ),
                          );
                        },
                        title: Text(
                          "Check In: " + checkIns[index].checkInTitle,
                        ),
                      );
                    },
                  );
                });
          } else {
            return Container(child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
