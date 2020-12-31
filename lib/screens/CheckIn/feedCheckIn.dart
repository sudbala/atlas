import 'package:atlas/model/CheckIn.dart';
import 'package:atlas/screens/CheckIn/CheckInPost.dart';
import 'package:flutter/material.dart';

class FeedCheckIn extends StatelessWidget {
  CheckIn checkIn;
  FeedCheckIn(CheckIn checkIn) {
    this.checkIn = checkIn;
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                /// Return the associated checkIn
                return CheckInPost(
                  checkIn: checkIn,
                  userName: checkIn.checkInUserName,
                );
              },
            ),
          );
        },
        child: Container(
            height: 400,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Image.network(
                    checkIn.photoURLs[0],
                    fit: BoxFit.cover,
                  )),
              Text(
                  "Check In: ${checkIn.checkInTitle} \n @${checkIn.userName} \n Posted: ${checkIn.checkInDate.substring(5, 16)}"),
            ])));
  }
}
