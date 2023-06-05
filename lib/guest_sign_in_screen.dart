import 'package:carded/user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fbAuth;
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
  final fbAuth.FirebaseAuth _auth = fbAuth.FirebaseAuth.instance;

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<User?> signInGuest() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();

    try {
      fbAuth.UserCredential userCredential = await _auth.signInAnonymously();
      fbAuth.User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        String cardId = await card.User_Card.addCard(firstName, lastName, email);
        print('Guest signed in:');
        print('First Name: $firstName');
        print('Last Name: $lastName');
        print('Email: $email');
        await _addUser(firebaseUser.uid, email, cardId);
        User newUser = User(firebaseUser.uid, email, cardId, []); // Create a new User

        // Set the new User in UserProvider
        Provider.of<UserProvider>(context, listen: false).setUser(newUser);

        showSnackBar(context, 'Success');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CardedHomePage()),
              (Route<dynamic> route) => false,
        );

        return newUser; // Return the new User (from user.dart)
      }
    } catch (e) {
      print(e);
      showSnackBar(context, 'Fail');
    }
    return null;
  }

  Future<void> _addUser(String uid, String email, String cardId) {
    return database.collection('users').doc(uid).set({
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
        title: Text('Guest Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: signInGuest,
              child: Text('Sign In'),
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
