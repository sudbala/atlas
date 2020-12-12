
import 'package:atlas/screens/Login/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'SignInButton.dart';
import 'StaggerAnimation.dart';
import 'GoogleSignIn.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);
  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  /// [AnimationController] for the animation of the button
  AnimationController _loginButtonController;
  var animationStatus = 0;

  /// Upon initialization of the app, we set the [AnimationController] with a
  /// specific [Duration] and vsync, which is the [TickerProvider] of the class.
  /// The [TickerProvider] is what tells app when a frame has been triggered.
  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
      duration: Duration(
        milliseconds: 3000,
      ),
      vsync: this
    );
  }

  /// Disposes our [AnimationController] and app
  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  /// Animation played on an asynchronous thread to not mess with main thread
  Future<Null> _playAnimation() async {
    try {
      await _loginButtonController.forward();
      await _loginButtonController.reverse();
    } on TickerCanceled {}
  }

  /// Dialog on pop
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      child: new AlertDialog(
        title: new Text('Are you sure?'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, "/home"),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    /// Time dilation slows down the animation for development purposes
    timeDilation = 0.4;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: backgroundImage,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  const Color.fromRGBO(162, 146, 199, 0.8),
                  const Color.fromRGBO(51, 51, 63, 0.9),
                ],
                stops: [0.2, 1.0],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.0, 1.0),
              )
            ),
              child: new ListView(
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  new Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      animationStatus == 0
                          ? new Padding(
                        padding: const EdgeInsets.only(top: 500.0),
                        child: new InkWell(
                            onTap: () {
                              setState(() {
                                animationStatus = 1;
                              });
                              signInWithGoogle().then((value) => {
                                if (value != null) {
                                  _playAnimation()
                                }
                              });
                            },
                            child: SignIn()
                        ),
                      )
                          : new StaggerAnimation(
                          buttonController:
                          _loginButtonController.view),
                    ],
                  ),
                ],
              )
          ),
        ),
      ),
    );
  }


}