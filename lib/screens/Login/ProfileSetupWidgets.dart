import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserName extends StatefulWidget {
  UserName({Key key}) : super(key: key);
  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  /// User name string and the collections of users we add to
  String userName;
  String validText = 'Invalid Username';
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  bool userNameValid = false;
  final _formKey = GlobalKey<FormState>();

  Future<bool> _checkUserName(String username) async {
    /// Check if the username is valid
    /// This is if its over 6 characters, not already taken, and not empty
    if (username != null && username.length >= 6) {
      var result = await users.where('UserName', isEqualTo: username).get();
      return result.docs.isEmpty;
//      if (userNameValid) print('Valid');
//      else print('Invalid');
    }
    return false;
  }

  bool _userExist = false;
  checkUserValue<bool>(String user) {
    print("WE GOT HERE");
    _checkUserName(user).then((value) => {
          if (!value)
            {
              print("Username Is Valid"),
              _userExist = value,
            }
          else
            {
              print("Username is Invalid"),
              _userExist = value,
            }
        });
    return _userExist;
  }

  void validUserName() {
    validText = 'Valid Username!';
  }

  @override
  Widget build(BuildContext context) {
    final widgetWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text("Welcome to Atlas"),
              ),
              SizedBox(
                height: 20.0,
              ),
              Container(
                  width: widgetWidth / 1.5,
                  child: TextFormField(
                    onChanged: (String value) {
                      userName = value;
                      _formKey.currentState.validate();
                    },
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(20.0),
                          ),
                        ),
                        filled: true,
                        hintStyle: new TextStyle(color: Colors.grey[800]),
                        hintText: "Enter a Username",
                        fillColor: Colors.white70),
                    validator: (value) => checkUserValue(value)
                        ? "Username taken or invalid. (>= 6)"
                        : null,
                  )
//              TextField(
//                /// Once the user submits their text, we update our string
//                onChanged: (String value) {
//                  userName = value;
//                  checkUserName();
//                },
//                decoration: new InputDecoration(
//                    border: new OutlineInputBorder(
//                      borderRadius: const BorderRadius.all(
//                        const Radius.circular(10.0),
//                      ),
//                    ),
//                    filled: true,
//                    hintStyle: new TextStyle(color: Colors.grey[800]),
//                    hintText: "Enter a Username",
//                    fillColor: Colors.white70),
//              ),
                  ),
//              SizedBox(
//                height: 20.0,
//              ),
//              FlatButton(
//                onPressed: userNameValid ? validUserName : null,
//                child: Text(validText),
//                textColor: Colors.blue,
//                disabledColor: Colors.grey,
//                disabledTextColor: Colors.white,
//                shape: RoundedRectangleBorder(
//                    side: BorderSide(
//                        color: Colors.blue, width: 1, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.circular(50)),
//              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
