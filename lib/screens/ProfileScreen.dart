import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

final firestoreInstance = FirebaseFirestore.instance;

class ProfileButton extends StatefulWidget {
  final int relationShipToProfile;

  ProfileButton(this.relationShipToProfile);

  @override
  _ProfileButtonState createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.relationShipToProfile == 3) {
      return IconButton(
        icon: Icon(Icons.settings),
        onPressed: () => {
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(title: Text('Settings Pages')),
              // Might want to add a way to log out here.
              body: Center(
                child: Column(children: [
                  RawMaterialButton(
                    fillColor: Theme.of(context).accentColor,
                    child: Icon(
                      Icons.add_photo_alternate_rounded,
                      color: Colors.white,
                    ),
                    elevation: 8,
                    onPressed: () {
                      getImage();
                    },
                    padding: EdgeInsets.all(15),
                    shape: CircleBorder(),
                  ),
                  _image == null ? Text("Select an Image") : Image.file(_image)
                ]),
              ),
            );
          }))
        },
      );
    } else {
      // This is not your profile page
      String buttonText;
      if (widget.relationShipToProfile == 2) {
        buttonText = "Friends";
      } else if (widget.relationShipToProfile == 1) {
        buttonText = "Accept Friend";
      } else {
        buttonText = "Requested";
      }

      return ElevatedButton(
          onPressed: () => {setState(() {})}, child: Text(buttonText));
    }
  }
}

class ProfileHeader extends StatelessWidget {
  final String profileID;
  ProfileHeader(this.profileID);
  Widget build(BuildContext context) {
    // Initial UserName before we get data can be loading?
    String UserName = "Loading";
    // Initial Image should probably be a file loaded on phone eventually
    String imageURL =
        "https://firebasestorage.googleapis.com/v0/b/atlas-8b3b8.appspot.com/o/blankProfile.png?alt=media&token=8ffc6a2d-6e08-499a-b2cf-0f250a8b0f8f";

    // grab collection of users
    CollectionReference users = FirebaseFirestore.instance.collection("Users");
    // here we will create a future builder.
    return FutureBuilder<DocumentSnapshot>(
        future: users.doc(profileID).get()
          ..then((value) {
            // If we are able to find a setup Profile for this profile Id, set up the usernamme and profile photo
            UserName = value['UserName'];
            imageURL = value['profileURL'];
          }),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          //Map<String, dynamic> data = snapshot.data.data();
          // Build the actual profile here. It will rebuild again once the future returns
          return SafeArea(
              child: Column(children: [
            Expanded(
              child: (Row(children: <Widget>[
                Text("$UserName"),
                (Expanded(child: Image.network("$imageURL")))
              ])),
            ),
            SizedBox(height: 50)
          ]));

          //return Text("James Fleming");
        });
  }
}

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
  // Here we would call to the FireStore database to actually get information on the profile

  // Example Check in's just to see what having a list as one of the tabs feels like.
  final List<String> checkInExample =
      List.generate(50, (index) => "Check In $index");
  @override
  void initState() {
    super.initState();
    tController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    int relationShipToProfile =
        -1; // this will be to represent two users that are not friends

    if (widget.profileID == myId) {
      relationShipToProfile = 3;
    } else {
      // Grab RelationShip to profile from firestore
      relationShipToProfile = 2;
    }

    return Scaffold(
        // We will use a NestedScrollView so that we can have a sliverAppBar with a Tab bar to differentiate between
        // The different pages of a user's profile.
        body: NestedScrollView(
      floatHeaderSlivers: true,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          // Create a persistent header. This is where we put the actual profile stuff
          SliverAppBar(
            // Whether the par becomes pinned at the top or not
            pinned: true,
            // Whether part of the appbar is always there
            floating: true,
            snap: false,
            expandedHeight: 450,

            flexibleSpace: FlexibleSpaceBar(
              background: ProfileHeader(widget.profileID),
            ),
            bottom: TabBar(
              tabs: [
                Tab(text: "Check Ins"),
                Tab(text: "Favorite Places"),
                Tab(text: "HeatMap")
              ],
              controller: tController,
              //labelColor: Colors.blue,
            ),
            actions: <Widget>[ProfileButton(relationShipToProfile)],
          ),

          /*
          SliverPersistentHeader(
              delegate: CustomSliverDelegate(
                expandedHeight: 120,
              ),
              pinned: true,
              floating: true),
          // Create the app Bar here
          */
        ];
      },
      // The bulk of a users view.
      body: TabBarView(
        children: [
          ListView.builder(
            itemCount: checkInExample.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  checkInExample[index],
                ),
              );
            },
          ),
          Text("Put a list of all favorite places"),
          Text("Put a user's heatmap here"),
        ],
        controller: tController,
      ),
    ));
  }
}

/// NONE OF THIS IS IN use right now.. Provides alternative way to doing things.
class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  //final TabBar tabBar;
  CustomSliverDelegate({
    @required this.expandedHeight,
    //@required this.tabBar,
    this.hideTitleWhenExpanded = true,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return Opacity(
      child: ProfileHeader("Test"),
      opacity: hideTitleWhenExpanded ? percent : 1.0 - percent,
    );

    //return SafeArea(child: tabBar);
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
