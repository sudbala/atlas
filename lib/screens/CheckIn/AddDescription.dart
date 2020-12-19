import 'package:atlas/screens/MainScreen.dart';
import 'package:flutter/material.dart';

class AddDescription extends StatefulWidget {
  @override
  _AddDescriptionState createState() => _AddDescriptionState();
}

class _AddDescriptionState extends State<AddDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Add a Title and Description to this post!"),
          ElevatedButton(
              child: Text("Skip"),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (BuildContext context) {
                  return MainScreen();
                }));
              }),
        ],
      )),
    );
  }
}
