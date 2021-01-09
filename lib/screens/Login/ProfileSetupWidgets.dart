import 'package:atlas/screens/MainScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/services.dart';

import 'package:multi_image_picker/multi_image_picker.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final User currentUser = _auth.currentUser;
final String myId = currentUser.uid;

class AsyncFieldValidationFormBloc extends FormBloc<String, String> {
  final username = TextFieldBloc(
    validators: [
      FieldBlocValidators.required,
      _min6Char,
    ],
    asyncValidatorDebounceTime: Duration(milliseconds: 300),
  );

  AsyncFieldValidationFormBloc() {
    addFieldBlocs(fieldBlocs: [username]);

    username.addAsyncValidators(
      [_checkUsername],
    );
  }

  static String _min6Char(String username) {
    if (username.length < 6) {
      return 'Must have at least 6 characters';
    }
    return null;
  }

  Future<String> _checkUsername(String username) async {
    var result = await FirebaseFirestore.instance
        .collection('Users')
        .where('UserName', isEqualTo: username.toLowerCase())
        .get();
    if (result.docs.isNotEmpty) {
      return 'That username is already taken';
    }
    return null;
  }

  @override
  void onSubmitting() async {
    print(username.value);

    _addUser(username.value);

    try {
      await Future<void>.delayed(Duration(milliseconds: 500));

      emitSuccess();
    } catch (e) {
      emitFailure();
    }
  }

  Future<void> _addUser(String username) {
    return FirebaseFirestore.instance.collection('Users').doc(myId).update({
      /// Set the username (let's make them all lowercase to make life easier searching)
      'UserName': username.toLowerCase(),
    });
  }
}

class UsernameValidator extends StatelessWidget {
  SwiperController _controller;
  UsernameValidator(this._controller);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AsyncFieldValidationFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = context.bloc<AsyncFieldValidationFormBloc>();
          final widgetWidth = MediaQuery.of(context).size.width;
          return FormBlocListener<AsyncFieldValidationFormBloc, String, String>(
            onSubmitting: (context, state) {
              LoadingDialog.show(context);
            },
            onSuccess: (context, state) {
              LoadingDialog.hide(context);
              _controller.next();
            },
            onFailure: (context, state) {
              LoadingDialog.hide(context);

              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text(state.failureResponse)));
            },
            child: Center(
              child: Container(
                width: widgetWidth / 1.5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text("Welcome to Atlas"),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.username,
                        suffixButton: SuffixButton.asyncValidating,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(20.0),
                              ),
                            ),
                            filled: true,
                            prefixIcon: Icon(Icons.person),
                            hintStyle: new TextStyle(color: Colors.grey[800]),
                            hintText: "Username",
                            fillColor: Colors.white70),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue)),
                        color: Colors.white,
                        textColor: Colors.blue,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () {
                          formBloc.submit();
                        },
                        child: Text(
                          "Save".toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

/// For the Name Field
class InputNameField extends StatelessWidget {
  /// The Controller to change the page we currently are on during the setup
  SwiperController swiperController;
  InputNameField({this.swiperController});
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  Future<void> _saveNameAndBio(String name, String bio) {
    // Update the same profile with a name and Bio
    return FirebaseFirestore.instance.collection('Users').doc(myId).update({
      'Name': name,
      'Bio': bio,
    });
//    return FirebaseFirestore.instance.collection('Users').doc(myId).set({
//      /// Set the username (let's make them all lowercase to make life easier searching)
//      'UserName': username.toLowerCase(),
//    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: widgetWidth / 1.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text("Enter a Name and Bio!"),
              ),
              SizedBox(
                height: 25.0,
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(20.0),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(Icons.person),
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "John Doe",
                    fillColor: Colors.white70),
              ),
              SizedBox(
                height: 25.0,
              ),
              Container(
                child: TextField(
                  inputFormatters: [LengthLimitingTextInputFormatter(70)],
                  controller: _bioController,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(20.0),
                        ),
                      ),
                      filled: true,
                      prefixIcon: Icon(Icons.message),
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "I like to swim!",
                      fillColor: Colors.white70),
                ),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blue)),
                color: Colors.white,
                textColor: Colors.blue,
                padding: EdgeInsets.all(8.0),
                onPressed: () async {
                  await _saveNameAndBio(
                      _nameController.text, _bioController.text);
                  swiperController.next();
                },
                child: Text(
                  "Save".toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Upload Profile Picture
class UploadProfilePicture extends StatefulWidget {
  bool photoSelected = false;
  @override
  _UploadProfilePictureState createState() => _UploadProfilePictureState();
}

class _UploadProfilePictureState extends State<UploadProfilePicture> {
  Asset _profileImage;
  List<Asset> _images = [];

  List<Asset> resultList;

  /// If we want to get an image from the gallery
  Future _imgFromGallery() async {
    try {
      resultList = await MultiImagePicker.pickImages(
          maxImages: 1, selectedAssets: _images);
    } on Exception catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _images = resultList;
      _profileImage = _images[0];
      widget.photoSelected = true;
    });

    /// Now once we get the image, we once again set the image and bool
  }

  /// We make the option chooser widget to give the user a choice in gallery
  /// or taking a picture
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: [
                  /// Two children. One will be photo library and the other will
                  /// be the camera. Upon selecting, we will use the image picker
                  /// method that is associated and then pop from the context
                  /// with the navigator
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                  /*
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Take a Photo'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  */
                ],
              ),
            ),
          );
        });
  }

  Future _savePhotos() async {
    /// Need to save a blank profile if we don't have a profile image
    /// First, let's decide what our url will be. If not a blank, we need to
    /// upload to firebase storage and grab that url. Otherwise, hardcoded blank
    /// url.
    ///
    List<String> photoUrls = new List<String>();
// can't use for each here... learned this the hard way.

    for (var image in _images) {
      // Trying a data upload method. hopefully this works better cause of course the other ways we have uploaded images don't work on my iphone for some reason

      // Convert the asset into a file
      ByteData byteData = await image.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();

      Reference ref =
          FirebaseStorage.instance.ref().child('profilePhotos/$myId.png');

      UploadTask uploadTask = ref.putData(imageData);

      await uploadTask.whenComplete(() async {
        photoUrls.add(await ref.getDownloadURL());
      });
    }

    /// Now we just update our storage in [Firestore]
    ///
    DocumentReference currentUserReference =
        FirebaseFirestore.instance.collection('Users').doc(myId);
    if (photoUrls[0] != null) {
      await currentUserReference.update({'profileURL': photoUrls[0]});
    } else {
      await currentUserReference.update({
        'profileURL':
            'https://firebasestorage.googleapis.com/v0/b/atlas-8b3b8.appspot.com/o/blankProfile.png?alt=media&token=8ffc6a2d-6e08-499a-b2cf-0f250a8b0f8f'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// We are gonna return a scaffold here
    final widgetWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        width: widgetWidth / 1.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text("Upload a Profile Photo!"),
              ),
              SizedBox(
                height: 25.0,
              ),
              Center(
                /// Use a [GestureDetector] to detect a tap on the profile photo
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                      radius: 76,
                      backgroundColor: Color(0xff000000),

                      /// If image is not null, use a ClipRRect to show the
                      /// selected photo
                      child: _profileImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: AssetThumb(
                                asset: _profileImage,
                                width: 150,
                                height: 150,
                                //fit: BoxFit.cover,
                              ),
                            )

                          /// If not, then show a blank camera icon
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(80),
                              ),
                              width: 150,
                              height: 150,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              ),
                            )),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.blue)),
                color: Colors.white,
                textColor: Colors.blue,
                padding: EdgeInsets.all(8.0),
                onPressed: () {
                  _savePhotos();
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (context) {
                    return MainScreen();
                  }));
                },
                child: Text(
                  "Save".toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              TextButton(
                onPressed: () {
                  _savePhotos();
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (context) {
                    return MainScreen();
                  }));
                },
                child: Text('Skip for now'),
                style: TextButton.styleFrom(primary: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Finally we build up and configure the image view on the screen

}
