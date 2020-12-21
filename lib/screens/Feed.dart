import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:atlas/screens/CheckIn/SelectSpot.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  static const TextStyle headerStyle = TextStyle(
    fontSize: 25,
  );

  @override
  Widget build(BuildContext context) {
    double tHeight = MediaQuery.of(context).size.height * (1 / 19);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: tHeight,

        elevation: 0.0,
        title: Text("Atlas",
            // Set the font of the appbar header here
            style: GoogleFonts.ebGaramond(textStyle: headerStyle)),
        // App bar icons
        actions: <Widget>[
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
      ),
      body: Text(
        'Index 0: Home',
      ),
    );
  }
}
