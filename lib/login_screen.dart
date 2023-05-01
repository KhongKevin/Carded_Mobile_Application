import 'package:carded/user.dart';
import 'package:carded/wallet_display_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: MaterialButton(
          onPressed: () {
            _googleSignIn.signIn().then((value) {
              database.collection("users").where("Email", isEqualTo: value!.email).get().then(
                      (querySnapshot) {
                        print("----------------------------------------------------Success-------------------------------------------------------");
                        for (var docSnapshot in querySnapshot.docs){
                          User loggedIn = User(docSnapshot.id, docSnapshot['Email'], docSnapshot['Card'], docSnapshot['Wallet']);
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => WalletDisplayScreen(loggedin: loggedIn,))
                          );
                        }
                      },
                onError: (e) => debugPrint("Error completing: $e")
              );
            });
          },
          color: Colors.deepOrange,
          height: 50,
          minWidth: 100,
          child: const Text(
            'Google Sign in',
            style: TextStyle(
              color: Colors.black
            ),
          ),
        ),
      ),
    );
  }

}
