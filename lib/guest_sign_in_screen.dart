import 'package:carded/user.dart' as curr_user;
import 'package:carded/wallet_display_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:provider/provider.dart';
import 'main.dart';
import 'user_card.dart' as card;

class GuestSignInScreen extends StatefulWidget {
  @override
  _GuestSignInScreenState createState() => _GuestSignInScreenState();
}
class _GuestSignInScreenState extends State<GuestSignInScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<curr_user.User?> signInGuest() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();

    try {
      fb_auth.UserCredential userCredential = await _auth.signInAnonymously();
      fb_auth.User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        String cardId = await card.User_Card.addCard(firstName, lastName, email);
        debugPrint('Guest signed in:');
        debugPrint('First Name: $firstName');
        debugPrint('Last Name: $lastName');
        debugPrint('Email: $email');
        await _addUser(firebaseUser.uid, email, cardId);
        curr_user.User newUser = curr_user.User(firebaseUser.uid, email, cardId, []); // Create a new User

        // Set the new User in UserProvider
        Provider.of<curr_user.UserProvider>(context, listen: false).setUser(newUser);

        showSnackBar(context, 'Success');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WalletDisplayScreen()),
              (Route<dynamic> route) => false,
        );

        return newUser; // Return the new User (from user.dart)
      }
    } catch (e) {
      debugPrint('$e');
      showSnackBar(context, 'Fail');
    }
    return null;
  }

  Future<void> _addUser(String uid, String email, String cardId) {
    return curr_user.UserProvider().database.collection('users').doc(uid).set({
      'Email': email,
      'Card': cardId,
      'Wallet': [],
    });
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: signInGuest,
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: GuestSignInScreen(),
  ));
}
