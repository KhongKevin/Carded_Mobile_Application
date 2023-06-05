import 'package:carded/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'guest_sign_in_screen.dart';

class SignUpScreen extends StatelessWidget {
  final FirebaseFirestore database = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up Screen")),
      body: FractionallySizedBox(
        heightFactor: 0.7,
        widthFactor: 0.9,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SignInButton(
              Buttons.Google,
              onPressed: () {
                _googleSignIn.signIn().then((value) {
                  List<String> name = value!.displayName!.split(" ");
                  String Fname = name.first;
                  String Lname = name.last;
                  String Email = value.email!;
                  User.addUser(Email, Fname, Lname)
                      .then((_) {
                    _showSnackBar(context, 'Sign-up successful!');
                  }).catchError((e) {
                    debugPrint('Error signing up: $e');
                    _showSnackBar(context, 'Sign-up failed!');
                  });
                }).catchError((e) {
                  debugPrint('Error signing in with Google: $e');
                  _showSnackBar(context, 'Sign-up failed!');
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
