import 'dart:collection';

import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/CheckInPost.dart';
import 'package:atlas/screens/SettingsScreen.dart';
import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  // A little bit of code to setup a tabController;
  TabController tController;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  // Here we would call to the FireStore database to actually get information on the profile

  // Example Check in's just to see what having a list as one of the tabs feels like.
  final List<String> checkInExample =
      List.generate(50, (index) => "Check In $index");

  List<CheckIn> checkIns;
  Set<String> checkInIds;

  @override
  void initState() {
    super.initState();
    tController = TabController(length: 3, vsync: this);
    checkIns = List();
    checkInIds = HashSet();
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

        // Update the users zones document so that the map knows to reload.
        zoneRef.set({"LastUpdate": DateTime.now().toString()});
      }
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

  Stream<List<QuerySnapshot>> checkInStream(List<dynamic> explored) {
    /// This method takes in the explored places for a given user and loads their
    /// associated checkIns with each. This seems a little tedious atm...

    /// Let's start with just making a for-each loop with the explored places.
    /// From here, we will do a read for each place we have checked in. Should
    /// be O(n) time because each read should be O(1)
    List<Stream<QuerySnapshot>> checkInStreams = List();
    print('WE GOT HERE #1');
    print('MY EXPLORED PLACES: ' + explored.toString());
    for (String fullSpotID in explored) {
      //print(fullSpotID);
      /// In order to get the collection reference for checkIns, we need to parse
      /// the current spotID. Was lazy, took from above lol
      var split = fullSpotID.split("/");
      String zone = split[0];
      String spotId = split[1];
      var splitId = spotId.split(";");
      String area =
          "${splitId[0].substring(0, 3)};${splitId[1].substring(0, 2)}";

      /// With all the parsed data, let's get the associated snapshot stream
      Stream<QuerySnapshot> stream = FirebaseFirestore.instance
          .collection('Zones')
          .doc(zone)
          .collection('Area')
          .doc(area)
          .collection('Spots')
          .doc(spotId)
          .collection('VisitedUsers')
          .doc(widget.profileID)
          .collection('CheckIns')
          .snapshots();

      /// Once we get the stream, we add it to the list of streams that we will
      /// zip up into one stream when we return
      checkInStreams.add(stream);
    }
    return StreamZip(checkInStreams);
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

  Widget profileHeader(double height, double width, String userName,
      String name, String imageUrl, String bio, int relationShip) {
    return Column(children: [
      //FittedBox(fit: BoxFit.fitWidth, child: Center(child: Text("$userName"))),
      SizedBox(
        height: height - 112,
        width: double.infinity,
        child: Image.network("$imageUrl", fit: BoxFit.cover),
      ),
      SizedBox(height: 5),
      SizedBox(
          height: 100,
          child: Row(children: [
            SizedBox(
                width: width * (3 / 4),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(userName,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ebGaramond(
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                          Text(name,
                              style: GoogleFonts.andika(
                                  textStyle: TextStyle(
                                color: Colors.white,
                              ))),
                          Text(bio,
                              style: GoogleFonts.andika(
                                  textStyle: TextStyle(
                                color: Colors.white,
                              )))
                        ]))),
            SizedBox(width: width / 4, child: Center(child: profileButton())),
          ])),
      SizedBox(height: 7),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Profile Height is currently set to 3/5 of user's screen
    double profileHeight = MediaQuery.of(context).size.height * (3 / 5);
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
                          relationShipToProfile),
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
                  StreamBuilder(
                      stream: checkInStream(exploredPlaces),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          checkIns = [];
                          List<QuerySnapshot> checkInCollections =
                              snapshot.data.toList();
                          for (QuerySnapshot areaCheckIns
                              in checkInCollections) {
                            for (QueryDocumentSnapshot checkIn
                                in areaCheckIns.docs) {
                              //Make sure the check in has the photos uploaded before we try to access them.
                              if ((List<String>.from(checkIn["PhotoUrls"]))
                                      .length !=
                                  0) {
                                checkIns.add(CheckIn(
                                  checkInTitle: checkIn['title'],
                                  checkInDescription: checkIn['message'],
                                  photoURLs:
                                      List<String>.from(checkIn['PhotoUrls']),
                                  checkInDate: checkIn['Date'],
                                  checkInID: checkIn.id,
                                ));
                                checkInIds.add(checkIn.id);
                              }
                              //}
                            }
                          }
                        }
                        return ListView.builder(
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
                                        userName: userName,
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
                      }),
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
