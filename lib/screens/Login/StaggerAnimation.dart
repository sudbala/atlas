import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../MainScreen.dart';
import './ProfileSetup.dart';

class StaggerAnimation extends StatelessWidget {
  StaggerAnimation({Key key, this.buttonController})
      : buttonSqueezeanimation = new Tween(
          begin: 320.0,
          end: 70.0,
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.0,
              0.150,
            ),
          ),
        ),
        buttomZoomOut = new Tween(
          begin: 70.0,
          end: 1000.0,
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.550,
              0.999,
              curve: Curves.bounceOut,
            ),
          ),
        ),
        containerCircleAnimation = new EdgeInsetsTween(
          begin: const EdgeInsets.only(top: 500.0),
          end: const EdgeInsets.only(bottom: 0.0),
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.500,
              0.800,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final AnimationController buttonController;
  final Animation<EdgeInsets> containerCircleAnimation;
  final Animation buttonSqueezeanimation;
  final Animation buttomZoomOut;

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
      await buttonController.reverse();
    } on TickerCanceled {}
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    return new Padding(
      padding: buttomZoomOut.value == 70
          ? const EdgeInsets.only(top: 500.0)
          : containerCircleAnimation.value,
      child: new InkWell(
          onTap: () {
            _playAnimation();
          },
          child: new Hero(
            tag: "fade",
            child: buttomZoomOut.value <= 300
                ? new Container(
                    width: buttomZoomOut.value == 70
                        ? buttonSqueezeanimation.value
                        : buttomZoomOut.value,
                    height:
                        buttomZoomOut.value == 70 ? 60.0 : buttomZoomOut.value,
                    alignment: FractionalOffset.center,
                    decoration: new BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomLeft,
                          colors: <Color>[
                            Color.fromRGBO(39, 124, 161, 0.7),
                            Color.fromRGBO(39, 155, 175, 0.9),
                          ]),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2,
                          offset: Offset(2, 2),
                          spreadRadius: 2.0,
                        ),
                      ],
                      borderRadius: buttomZoomOut.value < 400
                          ? new BorderRadius.all(const Radius.circular(20.0))
                          : new BorderRadius.all(const Radius.circular(0.0)),
                    ),
                    child: buttonSqueezeanimation.value > 75.0
                        ? new Text(
                            "Sign in with Google",
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.3,
                            ),
                          )
                        : buttomZoomOut.value < 300.0
                            ? new CircularProgressIndicator(
                                value: null,
                                strokeWidth: 1.0,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              )
                            : null)
                : new Container(
                    width: buttomZoomOut.value,
                    height: buttomZoomOut.value,
                    decoration: new BoxDecoration(
                      shape: buttomZoomOut.value < 500
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomLeft,
                          colors: <Color>[
                            Color.fromRGBO(39, 124, 161, 0.7),
                            Color.fromRGBO(39, 155, 175, 0.9),
                          ]),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2,
                          offset: Offset(2, 2),
                          spreadRadius: 2.0,
                        ),
                      ],
                    ),
                  ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<void> checkForProfile() {
      // Grab our userID
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final User currentUser = _auth.currentUser;
      final String myId = currentUser.uid;
      // Grab users collection
      CollectionReference users =
          FirebaseFirestore.instance.collection("Users");
      // See if we can grab a profile document with give user Id
      return users.doc(myId).get()
        ..then((DocumentSnapshot documentSnapshot) {
          // If this documentExists go straight to mainScreen()
          if (documentSnapshot.exists) {
            Navigator.pushReplacement(
                // Switched from mainScreen to Profile Setup
                context,
                MaterialPageRoute(builder: (context) => MainScreen()));
          } else {
            // If document does not exist go ahead to Profile Setup and we will make one!
            Navigator.pushReplacement(
                // Switched from mainScreen to Profile Setup
                context,
                MaterialPageRoute(builder: (context) => ProfileSetup()));
          }
        });
    }

    buttonController.addListener(() {
      if (buttonController.isCompleted) {
        // Switched this to pushReplacement so that you can't go back to login page.
        // Decide here whether to go to MainScreen or to a profile setup page once signup is complete :)
        checkForProfile();
      }
    });
    return new AnimatedBuilder(
      builder: _buildAnimation,
      animation: buttonController,
    );
  }
}
