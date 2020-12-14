// THis page will be to setup a user's profile the first time they log into the app;
import 'package:atlas/screens/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:atlas/screens/Login/styles.dart';

// Right now this page will come up when a user is signing in for the first time on a device
// We should make a check so that if it does already have an account we can auto skip this step.

// essentially it will build this widget... if noa account is set up
// it will build homescreen widget if there is an account setup.
// Sounds like we need a future builder
// I will soon later.

class ProfileSetup extends StatefulWidget {
  @override
  _ProfileSetup createState() => _ProfileSetup();
}

class _ProfileSetup extends State<ProfileSetup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: profileSetupBackground,
            ),
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: <Color>[
                    const Color.fromRGBO(162, 146, 199, 0.8),
                    const Color.fromRGBO(70, 70, 70, 0.9),
                  ],
                  stops: [0.2, 1.0],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.0, 1.0),
                )),
                // No idea why it styled the text in that way....
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Center(child: Text("Welcome to Atlas")),
                      TextField(
                          decoration:
                              InputDecoration(hintText: "Enter a Username")),
                      ElevatedButton(
                          child: Text("Sign Up"),
                          // Add networking shit here were we send out a request to create a user in the database and assign a username
                          //
                          onPressed: () => Navigator.pushReplacement(
                              // Switched from mainScreen to Profile Setup
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainScreen())))
                    ])))));
  }
}
