import 'package:carded/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
class SignUpScreen extends StatelessWidget {
  FirebaseFirestore database = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text("Sign Up Screen")),
        body: FractionallySizedBox(
            heightFactor: 0.7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: SignInButton(
                      Buttons.Google,
                      onPressed: () {
                        _googleSignIn.signIn().then((value) {
                          List<String> name = value!.displayName!.split(" ");
                          String Fname = name.first;
                          String Lname = name.last;
                          String Email = value.email;
                          User.addUser(Email, Fname, Lname);
                        });
                      },
                    )
                )],
            )
          )
        );
  }

}
