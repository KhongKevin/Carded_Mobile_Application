import 'package:carded/guest_sign_in_screen.dart';
import 'package:carded/sign_up_screen.dart';
import 'package:carded/user.dart' as currUser;
import 'package:carded/wallet_display_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
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
    final userProvider = Provider.of<currUser.UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          SizedBox(height: 200, width: 100),
          Center(
            child: MaterialButton(
              onPressed: () {
                _googleSignIn.signIn().then((value) {
                  userProvider.database
                      .collection("users")
                      .where("Email", isEqualTo: value!.email)
                      .get()
                      .then(
                        (querySnapshot) {
                      print("----------------------------------------------------Success-------------------------------------------------------");
                      for (var docSnapshot in querySnapshot.docs) {
                        String refId = docSnapshot.id;
                        String email = docSnapshot['Email'];
                        String card = docSnapshot['Card'];
                        List<String> wallet = docSnapshot['Wallet'].cast<String>();
                        currUser.User loggedIn = currUser.User(refId, email, card, wallet);
                        userProvider.setUser(loggedIn);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WalletDisplayScreen(),
                          ),
                        );
                        _showSnackBar(context, 'Signed in successfully!');
                      }
                    },
                    onError: (e) {
                      debugPrint("Error completing: $e");
                      _showSnackBar(context, 'Sign-in failed!');
                    },
                  );
                }).catchError((e) {
                  debugPrint("Error signing in: $e");
                  _showSnackBar(context, 'Sign-in failed!');
                });
              },
              color: Colors.deepOrange,
              height: 50,
              minWidth: 100,
              child: const Text(
                'Google Sign in',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          SizedBox(height: 50, width: 100),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuestSignInScreen(),
                ),
              );
            },
            child: Text("Sign In As Guest"),
          ),
        ],
      ),
    );
  }
}
