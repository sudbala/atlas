//import 'package:atlas/screens/Login/testing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

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
        .where('UserName', isEqualTo: username)
        .get();
    if (result.docs.isNotEmpty) {
      return 'That username is already taken';
    }
    return null;
  }

  @override
  void onSubmitting() async {
    print(username.value);

    try {
      await Future<void>.delayed(Duration(milliseconds: 500));

      emitSuccess();
    } catch (e) {
      emitFailure();
    }
  }
}

class UsernameValidator extends StatelessWidget {
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
              },
              onFailure: (context, state) {
                LoadingDialog.hide(context);

                Scaffold.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse)));
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
                              hintStyle:
                              new TextStyle(color: Colors.grey[800]),
                              hintText: "Username",
                              fillColor: Colors.white70),
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
