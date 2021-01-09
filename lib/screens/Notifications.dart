import 'package:atlas/screens/CustomAppBar.dart';
import 'package:atlas/screens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

// Page where we list all of a users notifications.
class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  void removeNotification(String data) {
    // Delete notification from the notificaiton arrays.
    FirebaseFirestore.instance.collection("Notifications").doc(myId).update({
      "Notifications": FieldValue.arrayRemove([data])
    });
  }

  List notifications = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar("Notifications", null, context, null),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Notifications")
                .doc(myId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                notifications = snapshot.data["Notifications"];
              }
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  // Grab in reverse order
                  var split = notifications[notifications.length - index - 1]
                      .split(";");
                  return Dismissible(
                      background: Container(
                          color: Color.fromRGBO(197, 40, 61, 1),
                          alignment: Alignment(0.8, 0),
                          child: Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          )),
                      key: Key(notifications[notifications.length - index - 1]),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        removeNotification(
                            notifications[notifications.length - index - 1]);
                      },
                      child: ListTile(
                          title: Text(split[1]),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (BuildContext context) {
                                /// Return the associated checkIn
                                return ProfileScreen(
                                    split[0].toString().trim());
                              },
                            ));
                          }));
                },
              );
            }));
  }
}
