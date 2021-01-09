import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/CheckInDeletion.dart';
import 'package:atlas/screens/CustomAppBar.dart';
import 'package:flutter/material.dart';

class CheckInSettings extends StatefulWidget {
  CheckIn checkIn;

  CheckInSettings({@required this.checkIn});

  @override
  _CheckInSettingsState createState() => _CheckInSettingsState();
}

class _CheckInSettingsState extends State<CheckInSettings> {
  bool currentlyDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Settings", null, context, null),
        body: ListView(
          children: [
            // Deletion Button
            InkWell(
              onTap: () {
                // Call deletePost and then put the user back to the home screen.
                setState(() {
                  currentlyDeleting = true;
                });
                deletePost(widget.checkIn).then((value) {
                  // Push replacement back to home screen once we are done deleting.
                  //Navigator.of(context).pushReplacementNamed("mainScreen");
                  // We want to remove the routes behind so there is no way to go back to deleted stuff
                  // Still getting an error message when we delete on the CheckInPost page and i'm not sure why... we aren't even on this page

                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('mainScreen', (route) => false);
                });
              },
              child: Container(
                  height: 75,
                  child: Row(children: [
                    Icon(Icons.delete),
                    Text("Delete Post"),
                    SizedBox(width: 15),
                    if (currentlyDeleting) CircularProgressIndicator()
                  ])),
            )
          ],
        ));
  }
}
