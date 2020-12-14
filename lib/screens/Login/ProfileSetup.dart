// THis page will be to setup a user's profile the first time they log into the app;
import 'package:atlas/screens/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:atlas/screens/Login/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Right now this page will come up when a user is signing in for the first time on a device
// We should make a check so that if it does already have an account we can auto skip this step.

// essentially it will build this widget... if noa account is set up
// it will build homescreen widget if there is an account setup.
// Sounds like we need a future builder
// I will soon later.

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class ProfileSetup extends StatefulWidget {
  @override
  _ProfileSetup createState() => _ProfileSetup();
}

class _ProfileSetup extends State<ProfileSetup> {
  @override
  Widget build(BuildContext context) {
    String userName;

    CollectionReference users = FirebaseFirestore.instance.collection("Users");

    Future<void> addUser() {
      return users.doc(myId).set({
        'UserName': userName,
        // Might as well set a default url here
        'profileURL':
            'https://firebasestorage.googleapis.com/v0/b/atlas-8b3b8.appspot.com/o/blankProfile.png?alt=media&token=8ffc6a2d-6e08-499a-b2cf-0f250a8b0f8f'
        // If we can successfuly add them, navigate to the main app!!! exciting
      }).then((value) => Navigator.pushReplacement(
              // Switched from mainScreen to Profile Setup
              context,
              MaterialPageRoute(builder: (context) => MainScreen()))
          .catchError((error) => print("Failed to add user")));
    }

// This code will move a user from the signup page to the main app almost immeditaely when they sign in
    /// There might be a better way to do this. because you can briefly see the signup page before being redirected
    /// Maybe do this check after the sign up button is pressed?
    users.doc(myId).get()
      ..then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Navigator.pushReplacement(
              // Switched from mainScreen to Profile Setup
              context,
              MaterialPageRoute(builder: (context) => MainScreen()));
        }
      });
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
                child: Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                      Center(child: Text("Welcome to Atlas")),
                      TextField(
                          // Once the user submits there text we update our string
                          onChanged: (String value) {
                            userName = value;
                          },
                          decoration:
                              InputDecoration(hintText: "Enter a Username")),
                      ElevatedButton(
                          child: Text("Sign Up"),
                          // Add networking shit here were we send out a request to create a user in the database and assign a username
                          //

                          // This is gonna take some thought on how we want to go about designing this
                          // Especially for the searching aspect.
                          onPressed: (() {
                            addUser();
                          }))
                    ])))));
  }
}
