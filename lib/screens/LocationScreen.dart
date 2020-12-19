import 'package:flutter/material.dart';

class LocationScreen extends StatelessWidget {
  final String coord;
  LocationScreen(this.coord);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("East Peak (lmao this was hardcoded heheh")),
        body: Center(
          child: Text(
              "The Spot you Click on has longitude and latitude coordinates of $coord. We should be able to find its hashkey with that information"),
        ));
  }
}
