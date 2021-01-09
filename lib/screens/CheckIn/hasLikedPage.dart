import 'package:atlas/screens/CustomAppBar.dart';
import 'package:atlas/screens/ProfileScreen.dart';

import 'package:flutter/material.dart';

class HasLikedPage extends StatelessWidget {
  Map data;
  HasLikedPage(Map data) {
    this.data = data;
  }
  @override
  Widget build(BuildContext context) {
    List keys = data.keys.toList();
    return Scaffold(
        appBar: CustomAppBar("Likes", null, context, null),
        body: ListView.builder(
          itemCount: keys.length,
          itemBuilder: (context, index) {
            return ListTile(
                onTap: () {
                  // On tap take the user to this profile
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      /// Return the associated checkIn
                      return ProfileScreen(keys[index]);
                    },
                  ));
                },
                // Super simple just username
                title: Text(data[keys[index]]));
          },
        ));
  }
}
