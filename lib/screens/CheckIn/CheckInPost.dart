import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/photoPage.dart';
import 'package:atlas/screens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:geolocator/geolocator.dart';
import 'package:atlas/globals.dart' as globals;
import '../LocationScreen.dart';
import './hasLikedPage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

/// The view of a [CheckInPost]. This widget will be used in various places
class CheckInPost extends StatefulWidget {
  /// One final instance variable is the checkIn object, which will hold all information
  final CheckIn checkIn;
  final String userName;

  const CheckInPost({
    Key key,
    @required this.checkIn,
    this.userName,
  }) : super(key: key);
  @override
  _CheckInPostState createState() => _CheckInPostState();
}

class _CheckInPostState extends State<CheckInPost> {
  void likedPress(bool liked) {
    if (!liked) {
      FirebaseFirestore.instance
          .collection("Likes")
          .doc(widget.checkIn.checkInID)
          .update({"whoLiked.$myId": globals.userName});
    } else {
      FirebaseFirestore.instance
          .collection("Likes")
          .doc(widget.checkIn.checkInID)
          .update({"whoLiked.$myId": FieldValue.delete()});
    }
  }

  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    /// Media Query Size
    Size size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: null,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              width: size.width,
              height: size.height,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CheckInHeader(
                      images: widget.checkIn.photoURLs ?? ["images/detail.png"],
                      onLikePress: likedPress,
                      title: widget.checkIn.title,
                      onBackPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    CheckInContent(
                      userName: widget.userName,
                      checkInTitle: widget.checkIn.checkInTitle,
                      description: widget.checkIn.checkInDescription,
                      checkInID: widget.checkIn.checkInID,
                      profileId: widget.checkIn.profileId,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class CheckInHeader extends StatefulWidget {
  final List<String> images;
  final String title;
  // bool isLiked = false;
  final Function onLikePress, onBackPressed;

  /// Constructor of the [CheckInHeader]
  const CheckInHeader(
      {Key key,
      @required this.images,
      @required this.title,
      @required this.onLikePress,
      @required this.onBackPressed})
      : super(key: key);

  _CheckInHeaderState createState() => _CheckInHeaderState();
}

/// Widget that holds the header media for the [CheckInPost]. Subject to change.
class _CheckInHeaderState extends State<CheckInHeader> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    /// Media Query to fit the entire width and height of the current context
    /// the height will be restricted, but width will most likely be the entire
    /// phone
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height / 2,
      color: Colors.white,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: RoundClipper(),
            child: Swiper(
              itemBuilder: (context, index) {
                return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(
                          builder: (BuildContext context) {
                        return PhotoPage(widget.images, widget.title);
                      }));
                    },
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.cover,
                    ));
              },
              indicatorLayout: PageIndicatorLayout.COLOR,
              itemCount: widget.images.length,
              pagination: SwiperPagination(
                  builder: const DotSwiperPaginationBuilder(
                      color: Colors.grey,
                      size: 5.0,
                      activeSize: 5.0,
                      space: 5.0)),
              loop: false,
            ),
          ),
          Positioned(
            top: 25,
            left: 3,
            child: Container(
                width: 50,
                height: 50,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: FlatButton(
                  color: Colors.white,
                  splashColor: Colors.green.withOpacity(0.3),
                  padding: EdgeInsets.all(10),
                  onPressed: this.widget.onBackPressed,
                  child: Icon(Icons.arrow_back, size: 25),
                )),
          ),
          Positioned(
            bottom: 12,
            right: 25,
            child: Container(
              width: 40,
              height: 40,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: Offset(1, 5),
                    spreadRadius: 5.0,
                  ),
                ],
              ),
              child: FlatButton(
                padding: EdgeInsets.all(10),
                onPressed: () {
                  this.widget.onLikePress(this.isLiked);
                  setState(() {
                    this.isLiked = !this.isLiked;
                  });
                },
                child: SvgPicture.asset(
                  "assets/heart.svg",
                  color:
                      this.isLiked ? Colors.red : Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class RoundClipper extends CustomClipper<Path> {
  /// getClip() gives back the rounded clipping patter you see on the images.
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
        size.width / 1.5, size.height, size.width, size.height - 30);
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

class CheckInContent extends StatelessWidget {
  /// These are the instance variables for the [CheckInContent]
  final String checkInID, checkInTitle, description, userName, profileId;
  String spotName, zone, area, spotID;
  String timeAgo;

  CheckInContent({
    Key key,
    @required this.checkInID,
    @required this.checkInTitle,
    @required this.description,
    @required this.userName,
    @required this.profileId,
  }) : super(key: key) {
    var splitID = checkInID.split(";");
    zone = splitID[0];
    area = splitID[1].substring(0, 3) + ";" + splitID[2].substring(0, 2);
    spotID = splitID[1] + ";" + splitID[2];
    spotName = splitID[3];

    /// Getting how long ago it was posted
    String fullDate = splitID[4];
    var dateTimeSplit = fullDate.split(" ");

    /// Now do date and time separately
    String date = dateTimeSplit[0];
    var dateSplit = date.split("-");
    int year = int.parse(dateSplit[0]);
    int month = int.parse(dateSplit[1]);
    int day = int.parse(dateSplit[2]);

    /// Now we do the same with time
    String time = dateTimeSplit[1];
    var timeSplit = time.split(":");
    int hour = int.parse(timeSplit[0]);
    int minute = int.parse(timeSplit[1]);
    var secondSplit = timeSplit[2].split('.');
    int second = int.parse(secondSplit[0]);
    int millisecond = int.parse(secondSplit[1].substring(0, 3));
    int microsecond = int.parse(secondSplit[1].substring(3));

    /// Create a new Date time with it
    DateTime postDate = DateTime(
        year, month, day, hour, minute, second, millisecond, microsecond);
    timeAgo = timeago.format(postDate);
  }

  void _onLocationPressed(context) async {
    /// Here we go to the respective spot page by reading it from the db.
    /// May be an unnecessary read, we'll have to talk about this later on...
    DocumentSnapshot currentSpot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(myId)
        .collection('visibleZones')
        .doc(zone)
        .collection('Area')
        .doc(area)
        .collection('Spots')
        .doc(spotID)
        .get();

    var data = currentSpot.data();
    data["zone"] = zone;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          // Send user to LocationScreen.
          return LocationScreen(data);
        },
      ),
    );
  }

  void onUserPressed(context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          // Send user to LocationScreen.
          return ProfileScreen(profileId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Once again we get the size to make this more dynamic
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// The Blog post title

          Text(
            this.checkInTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.06,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 0),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  size: 13,
                  color: Colors.blue,
                ),
                SizedBox(width: 5),
                Flexible(
                  child: TextButton(
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    onPressed: () {
                      onUserPressed(context);
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 13,
                  color: Colors.green,
                ),
                SizedBox(width: 5),
                Flexible(
                  child: TextButton(
                    child: Text(
                      userName + " checked into " + spotName + " " + timeAgo,
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    onPressed: () {
                      _onLocationPressed(context);
                    },
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Row(
              children: [
                Icon(Icons.favorite, size: 13, color: Colors.red),
                SizedBox(width: 5),
                Flexible(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Likes")
                          .doc(checkInID)
                          .snapshots(),
                      builder: (context, snapshot) {
                        String message = "";
                        if (snapshot.hasData) {
                          int numLikes = snapshot.data["whoLiked"].keys.length;
                          if (numLikes != 1) {
                            message = "${numLikes.toString()} Likes!";
                          } else {
                            message = "1 Like!";
                          }
                        }
                        return TextButton(
                          child: Text(
                            message,
                            style: TextStyle(
                              fontSize: size.width * 0.035,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                          onPressed: () {
                            // Go to the "liked page to see a list of users who have liked this post"
                            if (snapshot.hasData) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute<void>(
                                builder: (BuildContext context) {
                                  // Send user to LocationScreen.
                                  return HasLikedPage(
                                      snapshot.data["whoLiked"]);
                                },
                              ));
                            }
                          },
                        );
                      }),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            this.description,
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.black.withOpacity(0.6),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
