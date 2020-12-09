import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';

import 'MainScreen.dart';

/// The splash screen. Navigates to the main screen of app
class SplashScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return MediaQuery(
      // Have to wrap in a media query so that the animated splash screen
      // understands how to fill up the space. Media queries return data about
      // the specific screen size and dimensions of the device.
      data: new MediaQueryData(),
      child: MaterialApp(
        // Has a duration, image, and transition types to the next screen.
        home: AnimatedSplashScreen(
            duration: 2000,
            splash: 'images/mountain.png',
            nextScreen: MainScreen(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.bottomToTop,
        ),
      ),
    );
  }
}