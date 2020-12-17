// THis page will be to setup a user's profile the first time they log into the app;
import 'package:atlas/screens/Login/ProfileSetupWidgets.dart';
import 'package:atlas/screens/MainScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_page_indicator/flutter_page_indicator.dart';
//import 'config.dart';
import 'package:atlas/screens/Login/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Right now this page will come up when a user is signing in for the first time on a device
// We should make a check so that if it does already have an account we can auto skip this step.

// essentially it will build this widget... if noa account is set up
// it will build homescreen widget if there is an account setup.
// Sounds like we need a future builder
// I will soon later.

class ProfileSetup extends StatefulWidget {
  @override
  _ProfileSetupState createState() => new _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  // Custom properties
  int _itemCount;
  bool _loop;
  bool _autoplay;
  int _autoplayDely;
  double _padding;
  bool _outer;
  double _radius;
  double _viewportFraction;
  SwiperLayout _layout;
  int _currentIndex;
  double _scale;
  Axis _scrollDirection;
  Curve _curve;
  double _fade;
  bool _autoplayDisableOnInteraction;
  CustomLayoutOption customLayoutOption;


  final List<Widget> setupWidgets = [
    UsernameValidator(),
    Placeholder(),
    Placeholder(),
  ];

  @override
  void initState() {
    customLayoutOption = new CustomLayoutOption(startIndex: -1, stateCount: 3)
        .addTranslate([
      new Offset(-350.0, 0.0),
      new Offset(0.0, 0.0),
      new Offset(350.0, 0.0)
    ]);
    _fade = 1.0;
    _currentIndex = 0;
    _curve = Curves.ease;
    _scale = .3;
    _layout = SwiperLayout.CUSTOM;
    _radius = 20;
    _padding = 0.0;
    _loop = false;
    _itemCount = 3;
    _autoplay = false;
    _autoplayDely = 3000;
    _viewportFraction = 0.8;
    _outer = false;
    _scrollDirection = Axis.horizontal;
    _autoplayDisableOnInteraction = false;
    super.initState();
  }

  Widget _buildItem(BuildContext context, int index) {
    return Container(
      child: IndexedStack(
        children: setupWidgets,
        index: index,
      ),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.8),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
//      ClipRRect(
//      borderRadius: new BorderRadius.all(new Radius.circular(_radius)),
//      child: new Image.asset(
//        images[index % images.length],
//        fit: BoxFit.fill,
//      ),
//    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height / 1.5;
    return Container(
      decoration: BoxDecoration(
        image: profileSetupBackground,
      ),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: <Color>[
            const Color.fromRGBO(162, 146, 199, 0.8),
            const Color.fromRGBO(70, 70, 70, 0.9),
          ],
          stops: [0.2, 1.0],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
        )),
        child: Scaffold(
          //resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Swiper(
//            onTap: (int index) {
//              Navigator.of(context)
//                  .push(new MaterialPageRoute(builder: (BuildContext context) {
//                return Scaffold(
//                  appBar: AppBar(
//                    title: Text("New page"),
//                  ),
//                  body: Container(),
//                );
//              }));
//            },
            customLayoutOption: customLayoutOption,
            fade: _fade,
            index: _currentIndex,
            onIndexChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            curve: _curve,
            scale: _scale,
            itemWidth: 300.0,
//        controller: _controller,
            layout: _layout,
            outer: _outer,
            itemHeight: height,
            viewportFraction: _viewportFraction,
            autoplayDelay: _autoplayDely,
            loop: _loop,
            autoplay: _autoplay,
            itemBuilder: _buildItem,
            itemCount: _itemCount,
            scrollDirection: _scrollDirection,
            indicatorLayout: PageIndicatorLayout.COLOR,
            autoplayDisableOnInteraction: _autoplayDisableOnInteraction,
            pagination: new SwiperPagination(
                builder: const DotSwiperPaginationBuilder(
                    size: 5.0, activeSize: 5.0, space: 5.0)),
          ),
        ),
      ),
    );
  }
}

//final FirebaseAuth _auth = FirebaseAuth.instance;
//final User currentUser = _auth.currentUser;
//final String myId = currentUser.uid;
//
//class ProfileSetup extends StatefulWidget {
//  @override
//  _ProfileSetup createState() => _ProfileSetup();
//}
//
//class _ProfileSetup extends State<ProfileSetup> {
//  @override
//  Widget build(BuildContext context) {
//    String userName;
//
//    CollectionReference users = FirebaseFirestore.instance.collection("Users");
//
//    Future<void> addUser() {
//      // If we want to require that usernames are unique we need to add in a bit of code that make sure that the username has not been taken yet
//
//      return users.doc(myId).set({
//        // Set the username (let's make them all lowercase to make my life easier searching)
//        'UserName': userName.toLowerCase(),
//        // Might as well set a default url here
//        'profileURL':
//            'https://firebasestorage.googleapis.com/v0/b/atlas-8b3b8.appspot.com/o/blankProfile.png?alt=media&token=8ffc6a2d-6e08-499a-b2cf-0f250a8b0f8f'
//        // If we can successfuly add them, navigate to the main app!!! exciting
//      }).then((value) => Navigator.pushReplacement(
//              // Switched from mainScreen to Profile Setup
//              context,
//              MaterialPageRoute(builder: (context) => MainScreen()))
//          .catchError((error) => print("Failed to add user")));
//    }
//
//    return Scaffold(
//        body: Container(
//            decoration: BoxDecoration(
//              image: profileSetupBackground,
//            ),
//            child: Container(
//                decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                  colors: <Color>[
//                    const Color.fromRGBO(162, 146, 199, 0.8),
//                    const Color.fromRGBO(70, 70, 70, 0.9),
//                  ],
//                  stops: [0.2, 1.0],
//                  begin: const FractionalOffset(0.0, 0.0),
//                  end: const FractionalOffset(0.0, 1.0),
//                )),
//                child: Center(
//                    child: Column(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        crossAxisAlignment: CrossAxisAlignment.center,
//                        children: [
//                      Center(child: Text("Welcome to Atlas")),
//                      TextField(
//                          // Once the user submits there text we update our string
//                          onChanged: (String value) {
//                            userName = value;
//                          },
//                          decoration:
//                              InputDecoration(hintText: "Enter a Username")),
//                      ElevatedButton(
//                          child: Text("Sign Up"),
//                          onPressed: (() {
//                            // When user click sign up run addUser!
//                            addUser();
//                          }))
//                    ])))));
//  }
//}
