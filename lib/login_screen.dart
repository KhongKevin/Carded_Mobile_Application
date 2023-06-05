import 'package:carded/guest_sign_in_screen.dart';
import 'package:carded/user.dart' as curr_user;
import 'package:carded/wallet_display_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  LoginScreen({super.key});
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<curr_user.UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 200, width: 100),
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
                        curr_user.User loggedIn = curr_user.User(refId, email, card, wallet);
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
          const SizedBox(height: 50, width: 100),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GuestSignInScreen(),
                ),
              );
            },
            child: const Text("Sign In As Guest"),
          ),
        ],
      ),
    );
  }
}
