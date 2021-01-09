import 'package:atlas/screens/CustomAppBar.dart';
import 'package:atlas/screens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:atlas/globals.dart' as globals;

// ignore: must_be_immutable
class CheckInComments extends StatefulWidget {
  String checkInTitle;
  String checkInId;
  String checkInProfileId;
  String myId;
  CheckInComments(
      {this.checkInId, this.myId, this.checkInProfileId, this.checkInTitle});
  @override
  _CheckInCommentsState createState() => _CheckInCommentsState();
}

class _CheckInCommentsState extends State<CheckInComments> {
  // Method for uploading comment to firestore database.
  DocumentReference checkInDoc;
  void initState() {
    super.initState();
    checkInDoc =
        FirebaseFirestore.instance.collection("Likes").doc(widget.checkInId);
  }

  List data = [];
  void addComment(String message) {
    checkInDoc.update({
      "comments":
          FieldValue.arrayUnion(["${widget.myId};${globals.userName};$message"])
    });

    if (myId != widget.checkInProfileId) {
      FirebaseFirestore.instance
          .collection("Notifications")
          .doc(widget.checkInProfileId)
          .update({
        "Notifications": FieldValue.arrayUnion([
          "$myId;${globals.userName} commented on ${widget.checkInTitle}: $message  ;${widget.checkInId}"
        ])
      });
    }
  }

  void removeComment(String fullComment) {
    checkInDoc.update({
      "comments": FieldValue.arrayRemove([fullComment])
    });
  }

  ScrollController _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    TextEditingController _commentController = TextEditingController();

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Likes")
            .doc(widget.checkInId)
            .snapshots(),
        builder: (context, snapshot) {
          double width = MediaQuery.of(context).size.width;
          if (snapshot.hasData) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              _controller.jumpTo(_controller.position.maxScrollExtent);
            });
            data = snapshot.data["comments"];
          } else if (snapshot.hasError) {
            print(snapshot.error);
          }
          return Scaffold(
              appBar: CustomAppBar("Discussion", null, context, null),
              body: SafeArea(
                  child: Column(children: [
                Expanded(
                    child: ListView.builder(
                        controller: _controller,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          var split = data[index].split(";");
                          // A comment can only be deleted by the person who made the comment or the owner of this post

                          Future<bool> confirmDismiss(direction) {
                            if (split[0] == myId ||
                                myId == widget.checkInProfileId) {
                              return Future.value(true);
                            } else {
                              return Future.value(false);
                            }
                          }

                          return Dismissible(
                              background: Container(
                                  color: Color.fromRGBO(197, 40, 61, 1),
                                  alignment: Alignment(0.8, 0),
                                  child: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                  )),
                              key: Key(data[index]),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: confirmDismiss,
                              onDismissed: (direction) {
                                removeComment(data[index]);
                              },
                              child: ListTile(
                                  onTap: () {
                                    // On tap take the user to this profile
                                    Navigator.of(context)
                                        .push(MaterialPageRoute<void>(
                                      builder: (BuildContext context) {
                                        /// Return the associated checkIn
                                        return ProfileScreen(split[0]);
                                      },
                                    ));
                                  },
                                  title: Text("${split[1]}: ${split[2]}")));
                        })),
                Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Container(
                      height: 70,
                      width: width - 60,

                      //jjheight: 50,
                      child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(2, 3),
                                spreadRadius: 0.3,
                              ),
                            ],
                          ),
                          child: TextField(

                              //inputFormatters: [LengthLimitingTextInputFormatter(20)],
                              controller: _commentController,
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 6,
                              decoration: InputDecoration(
                                isDense: true,
                                border: new OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    const Radius.circular(20.0),
                                  ),
                                ),
                                filled: true,
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      addComment(_commentController.text);
                                      _commentController.text = "";
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((timeStamp) {
                                        _controller.jumpTo(_controller
                                            .position.maxScrollExtent);
                                      });
                                    },
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.8),
                                    icon: Icon(Icons.add_comment_rounded)),
                                hintStyle:
                                    new TextStyle(color: Colors.grey[800]),
                                hintText: "Add a comment...",
                                fillColor: Colors.white,
                              ))),
                    ))
              ])));
        });
  }
}
