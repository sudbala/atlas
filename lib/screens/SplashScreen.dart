import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:atlas/screens/Login/LoginScreen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';

import 'MainScreen.dart';

/// The splash screen. Navigates to the main screen of app
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  MainScreen mainScreen;

  Future<void> _setMap() async {
    mainScreen = MainScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // Have to wrap in a media query so that the animated splash screen
      // understands how to fill up the space. Media queries return data about
      // the specific screen size and dimensions of the device.
      data: new MediaQueryData(),
      child: FutureBuilder(
          future: _setMap(),
          builder: (context, snapshot) {
            return MaterialApp(
              // Has a duration, image, and transition types to the next screen.

              theme: ThemeData(
                // Playing with themedata and colors here.

                primarySwatch: Colors.blue,

                primaryColor: Colors.cyan[800],
              ),
              home: AnimatedSplashScreen(
                duration: 2000,
                splash: 'images/mountain.png',
                nextScreen: LoginScreen(),
                splashTransition: SplashTransition.fadeTransition,
                pageTransitionType: PageTransitionType.bottomToTop,
              ),
            );
          }),
    );
  }
}
