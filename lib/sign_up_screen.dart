import 'package:carded/user.dart' as curr_user;
import 'package:carded/wallet_display_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';


class SignUpScreen extends StatelessWidget {
  final FirebaseFirestore database = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  SignUpScreen({super.key});

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
      appBar: AppBar(title: const Text("Sign Up Screen")),
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
                  String fname = name.first;
                  String lname = name.last;
                  String email = value.email;
                  database.collection("users").where("Email", isEqualTo: value.email).get().then((querysnapshot) {
                    querysnapshot.docs.isEmpty ? curr_user.User.addUser(email, fname, lname).then((_) {_showSnackBar(context, 'Sign-up successful');}).catchError((e) {
                      debugPrint('Error signing up: $e');
                      _showSnackBar(context, 'Sign-up failed');
                    }) : {
                      for(var docSnapshot in querysnapshot.docs){
                        Provider.of<curr_user.UserProvider>(context, listen: false).setUser(curr_user.User(
                            docSnapshot.id,
                            docSnapshot['Email'],
                            docSnapshot['Card'],
                            docSnapshot['Wallet'].isEmpty ? [] : docSnapshot['Wallet']))
                      }
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WalletDisplayScreen(),
                      ),
                    );
                  }
                  );
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
