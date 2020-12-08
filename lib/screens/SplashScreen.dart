import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'MainScreen.dart';

/// The splash screen. Navigates to the main screen of app
class SplashScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: new MediaQueryData(),
      child: MaterialApp(
        home: AnimatedSplashScreen(
            splash: 'images/mountain.png',
            nextScreen: MainScreen(title: 'Atlas'),
            splashTransition: SplashTransition.fadeTransition,
        ),
      ),
    );
  }
}