import 'package:flutter/material.dart';

class SignIn extends StatelessWidget {
  SignIn();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.0,
      height: 60.0,
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
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
