import 'dart:ui';

import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/CheckInPost.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = "customKey";
  // I'm hoping this will delete photos from the cache if they have not been used in 1 day. Not sure how to actually test if it is working
  // But ideally the app is not saving too much storage on your phone.
  static CacheManager instance = CacheManager(Config(
    key,
    stalePeriod: const Duration(days: 1),
  ));
}

class FeedCheckIn extends StatelessWidget {
  CheckIn checkIn;
  DateTime postDate;
  String postedAgo;
  String spotName;

  FeedCheckIn(CheckIn checkIn) {
    this.checkIn = checkIn;
    postDate = DateTime.parse(checkIn.checkInDate);
    postedAgo = timeago.format(postDate);
    var splitID = checkIn.checkInID.split(";");
    spotName = splitID[3];
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = (MediaQuery.of(context).size.width);
    return InkWell(
        onTap: () {
          // On tap we will send user to the full check In page
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                /// Return the associated checkIn
                return CheckInPost(
                  checkIn: checkIn,
                  userName: checkIn.checkInUserName,
                );
              },
            ),
          );
        },
        child: Column(children: [
          // Stack allows text and blur affect over photo
          Stack(children: [
            Container(
                height: 300,
                // Width gives a little border from edges of phone
                width: screenWidth - 24,
                // Shadow of a post
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 2,
                      offset: Offset(2, 2),
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                // Give image some rounded borders
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Using cachedImage

                    child: CachedNetworkImage(
                      cacheManager: CustomCacheManager.instance,
                      imageUrl: checkIn.photoURLs[0],
                      // This fit works the best. Have to consider vertical and horizontal photos
                      fit: BoxFit.cover,
                    ))),
            // Position the text at the bottom of the photo
            Positioned(
              top: (300.0 - 80),
              left: 0,
              width: screenWidth - 24,
              height: 80,
              child: ClipRRect(
                // Give the bottom of the blur box rounded borderr
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12)), //clipper: FeedClipper(),

                child: BackdropFilter(
                    child: Container(
                      width: screenWidth - 24,

                      // Controls the opacity of the frosted blur above the image
                      color: Colors.white.withOpacity(0.0),
                      //color: Theme.of(context).primaryColor.withOpacity(0.3),
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, top: 0, bottom: 0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(checkIn.checkInTitle,
                                  style: GoogleFonts.ebGaramond(
                                      textStyle: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold))),
                              Text(
                                "@${checkIn.userName}\n $spotName $postedAgo",
                                style: GoogleFonts.andika(
                                    textStyle: TextStyle(color: Colors.white)),
                              )
                            ]),
                      ),
                    ),
                    // Blurs the image
                    filter: ImageFilter.blur(
                      sigmaX: 1,
                      sigmaY: 1,
                    )),
              ),
            )
          ]),
          SizedBox(height: 20)
          //Text(
          //    "Check In: ${checkIn.checkInTitle} \n @${checkIn.userName} \n Posted: ${checkIn.checkInDate.substring(5, 16)}"),
        ]));
  }
}

class FeedClipper extends CustomClipper<Path> {
  /// getClip() gives back the rounded clipping patter you see on the images.
  @override
  Path getClip(Size size) {
    var path = Path();

    path.quadraticBezierTo(
        size.width * (3 / 4), 0, size.width, size.height * (4 / 5));
    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    /// Necessary but has no purpose
    return false;
  }
}
