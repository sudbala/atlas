import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/CheckInComments.dart';
import 'package:atlas/screens/CheckIn/CheckInSettings.dart';
import 'package:atlas/screens/CheckIn/photoPage.dart';
import 'package:atlas/screens/ProfileScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
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
  bool isLiked = false;
  void likedPress(bool liked) {
    setState(() {
      isLiked = !isLiked;
    });
    if (!liked) {
      // Our notification system is super simple. Just adds a notification to the users list
      // This allows spamming, a user can dislike and then just keep liking to spam someone's notifications...
      // Not a huge problem

      // User will still get noitification even if you dislike the post. but like why are you disliking a  post , kinda shady
      if (myId != widget.checkIn.checkInProfileId) {
        FirebaseFirestore.instance
            .collection("Notifications")
            .doc(widget.checkIn.checkInProfileId)
            .update({
          "Notifications": FieldValue.arrayUnion([
            "$myId ;${globals.userName} liked ${widget.checkIn.checkInTitle}!  ;${widget.checkIn.checkInID}"
          ])
        });
      }

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

  void initState() {
    //isLiked = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Media Query Size
    Size size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Likes")
            .doc(widget.checkIn.checkInID)
            .snapshots(),
        builder: (context, snapshot) {
          String message = "";
          Map whoLiked = {};
          if (snapshot.hasData) {
            whoLiked = snapshot.data["whoLiked"];
            int numLikes = snapshot.data["whoLiked"].keys.length;
            if (numLikes != 1) {
              message = "${numLikes.toString()} Likes!";
            } else {
              message = "1 Like!";
            }
            if (snapshot.data["whoLiked"][myId] != null) {
              isLiked = true;
            }
          }

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
                      checkIn: widget.checkIn,
                      title: widget.checkIn.title,
                      onBackPressed: () {
                        Navigator.pop(context);
                      },
                      isLiked: isLiked,
                    ),
                    CheckInContent(
                      userName: widget.userName,
                      checkInTitle: widget.checkIn.checkInTitle,
                      description: widget.checkIn.checkInDescription,
                      checkInID: widget.checkIn.checkInID,
                      profileId: widget.checkIn.profileId,
                      message: message,
                      whoLiked: whoLiked,
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
  bool isLiked;
  CheckIn checkIn;

  /// Constructor of the [CheckInHeader]
  CheckInHeader({
    Key key,
    @required this.images,
    @required this.title,
    @required this.onLikePress,
    @required this.checkIn,
    @required this.onBackPressed,
    @required this.isLiked,
  }) : super(key: key);

  _CheckInHeaderState createState() => _CheckInHeaderState();
}

/// Widget that holds the header media for the [CheckInPost]. Subject to change.
class _CheckInHeaderState extends State<CheckInHeader> {
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
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
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
            top: 40,
            left: 5,
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
          if (myId == widget.checkIn.checkInProfileId)
            Positioned(
              top: 40,
              right: 5,
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
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return CheckInSettings(
                          checkIn: widget.checkIn,
                        );
                      }));
                    },
                    child: Icon(Icons.settings, size: 25),
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
                  this.widget.onLikePress(widget.isLiked);
                },
                child: SvgPicture.asset(
                  "assets/heart.svg",
                  color: widget.isLiked
                      ? Colors.red
                      : Colors.black.withOpacity(0.5),
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

  String message;
  Map whoLiked;

  CheckInContent({
    Key key,
    @required this.checkInID,
    @required this.checkInTitle,
    @required this.description,
    @required this.userName,
    @required this.profileId,
    @required this.message,
    @required this.whoLiked,
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
            // User Name and Profile Link
            Row(
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
                ),
                SizedBox(width: 5),
              ],
            ),

// Spot location, post time ago and location link
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 13,
                  color: Colors.green,
                ),
                Flexible(
                  child: TextButton(
                    child: Text(
                      spotName + " " + timeAgo,
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
// Likes and like page link
            Row(children: [
              Icon(Icons.favorite, size: 13, color: Colors.red),
              SizedBox(width: 3),
              Flexible(
                  child: TextButton(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                onPressed: () {
                  // Go to the "liked page to see a list of users who have liked this post"

                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      // Send user to LocationScreen.
                      return HasLikedPage(whoLiked);
                    },
                  ));
                },
              )),
              SizedBox(width: 5),
              //Comments and comment page link
              Icon(Icons.comment_rounded, size: 13, color: Colors.black),
              SizedBox(width: 1),
              Flexible(
                  child: TextButton(
                child: Text(
                  "Comments",
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                onPressed: () {
                  // Go to the "liked page to see a list of users who have liked this post"

                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      // Send user to LocationScreen.
                      return CheckInComments(
                        checkInId: checkInID,
                        myId: myId,
                        checkInProfileId: profileId,
                        checkInTitle: checkInTitle,
                      );
                    },
                  ));
                },
              ))
            ]),
            SizedBox(
              height: 10,
            ),
            Text(
              this.description,
              style: TextStyle(
                fontSize: size.width * 0.04,
                color: Colors.black.withOpacity(0.7),
                height: 1.3,
              ),
            ),
          ],
        ));
  }
}
