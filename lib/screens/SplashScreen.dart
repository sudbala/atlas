import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:atlas/screens/Login/LoginScreen.dart';

import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'MainScreen.dart';

/// The splash screen. Navigates to the main screen of app
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  MainScreen mainScreen;
  var isLoggedIn = false;

  Future<void> _loggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = (prefs.getBool('isLoggedIn_Atlas') == null)
        ? false
        : prefs.getBool('isLoggedIn_Atlas');
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // Have to wrap in a media query so that the animated splash screen
      // understands how to fill up the space. Media queries return data about
      // the specific screen size and dimensions of the device.
      data: new MediaQueryData(),
      child: FutureBuilder(
          future: _loggedIn(),
          builder: (context, snapshot) {
            final textTheme = Theme.of(context).textTheme;

            return MaterialApp(
                // Has a duration, image, and transition types to the next screen.

                theme: ThemeData(
                  // Playing with themedata and colors here.

                  textTheme: GoogleFonts.andikaTextTheme(textTheme),
                  //primarySwatch: Colors.blue,
                  primaryColor: Color.fromRGBO(39, 124, 161, 1),
                ),
                initialRoute: 'splashScreen',
                onGenerateRoute: (RouteSettings settings) {
                  var routes = <String, WidgetBuilder>{
                    'mainScreen': (context) => MainScreen((settings.arguments))
                  };
                  WidgetBuilder builder = routes[settings.name];
                  return MaterialPageRoute(
                      builder: (context) => builder(context));
                },
                routes: {
                  //'mainScreen': (context) => MainScreen(),
                  'splashScreen': (context) => AnimatedSplashScreen(
                        duration: 2000,
                        splash: 'images/mountain.png',
                        nextScreen: isLoggedIn ? MainScreen() : LoginScreen(),
                        splashTransition: SplashTransition.fadeTransition,
                        pageTransitionType: PageTransitionType.bottomToTop,
                      ),
                });
          }),
    );
  }
}
