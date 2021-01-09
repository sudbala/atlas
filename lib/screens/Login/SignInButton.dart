import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  SignIn();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270.0,
      height: 60.0,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomLeft,
            colors: <Color>[
              Color.fromRGBO(39, 124, 161, 0.7),
              Color.fromRGBO(39, 155, 175, 0.9),
            ]),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 2,
            offset: Offset(2, 2),
            spreadRadius: 2.0,
          ),
        ],

        //color: Theme.of(context).primaryColor.withOpacity(0.7),
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Text(
        "Sign in with Google",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
