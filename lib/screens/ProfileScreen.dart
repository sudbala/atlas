import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileButton extends StatefulWidget {
  final bool myProfile;
  ProfileButton(this.myProfile);
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
    if (widget.myProfile) {
      return IconButton(
        icon: Icon(Icons.settings),
        onPressed: () => {
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(title: Text('Settings Pages')),
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
      return ElevatedButton(onPressed: () => {}, child: Text("Add Friend"));
    }
  }
}

class ProfileHeader extends StatelessWidget {
  final String profileName;
  ProfileHeader(this.profileName);
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: [
      Expanded(
        child: (Row(children: <Widget>[
          Text("$profileName"),
          (Expanded(child: Image.network("https://i.imgur.com/BoN9kdC.png")))
        ])),
      ),
      SizedBox(height: 50)
    ]));

    //return Text("James Fleming");
  }
}

class ProfileScreen extends StatefulWidget {
  final String profileName;
  ProfileScreen(this.profileName);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

// Don't really know what SingleTickerProviderStateMixin is but it allows me to may a tab controller
class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // A little bit of code to setup a tabController;
  TabController tController;

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
              background: ProfileHeader(widget.profileName),
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
            actions: <Widget>[ProfileButton(true)],
          ),

          /*SliverPersistentHeader(
              delegate: CustomSliverDelegate(
                expandedHeight: 120,
              ),
              pinned: true,
              floating: true),
          // Create the app Bar here
          */
        ];
      },
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
