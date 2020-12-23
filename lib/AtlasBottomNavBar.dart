import 'package:flutter/material.dart';

class AtlasBottomNavBar extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width/12;
    final height = MediaQuery.of(context).size.height/12;
    final iconSize = height/1.5;
    return Container(
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.home, size: iconSize),
              onPressed: () {

              }
          ),
          IconButton(
              icon: Icon(Icons.map, size: iconSize),
              onPressed: () {

              }
          ),
          IconButton(
              icon: Icon(Icons.explore_rounded, size: iconSize),
              onPressed: () {

              }
          ),
          IconButton(
              icon: Icon(Icons.person, size: iconSize),
              onPressed: () {

              }
          )
        ],

      ),
    );
  }
}