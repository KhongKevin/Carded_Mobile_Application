import 'package:carded/AddUsers.dart';
import 'package:carded/sign_up_screen.dart';
import 'package:carded/wallet_display_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:carded/user.dart' as curr_user;
import 'package:firebase_auth/firebase_auth.dart' as auth;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => curr_user.UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carded',
      theme: ThemeData(

        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CardedHomePage(),
    );
  }
}
class CardedHomePage extends StatelessWidget {
  CardedHomePage({super.key});
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('$e');  // Optional: add error handling here
    }
  }
  Future<curr_user.User?> getCurrentUser() async {
    final firebaseUser = auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (docSnapshot.exists) {
        curr_user.User user = curr_user.User.fromDocument(docSnapshot);
        return user;
      }
    }
    // Return null if no logged in user or user does not exist in Firestore
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<curr_user.User?>(
      future: getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final user = snapshot.data;
          if (user != null) {
            Provider.of<curr_user.UserProvider>(context, listen: false).setUser(user);
          }
          return Scaffold(
              appBar: AppBar(
                  title: const Text("Carded"),
                  automaticallyImplyLeading: false,
              ),
              body: FractionallySizedBox(
                  heightFactor: 1.0,
                  child: Center(
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 200.0, child: ElevatedButton(
                                  child: const Text("Login Page"),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => LoginScreen()),
                                    );
                                  },
                                ),
                                ),

                                const SizedBox(height: 50),
                                SizedBox(
                                  width: 200.0, // set the desired width here
                                  child: ElevatedButton(
                                    child: const Text("Sign Up Page"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 50),
                                SizedBox(
                                  width: 200.0, // set the desired width here
                                  child: ElevatedButton(
                                    child: const Text("Add Users"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AddUsers()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 50),

                                //This is a test, hard coded wallet in here in case the sign in / login authorization does not work :D
                                SizedBox(
                                  width: 200.0, // set the desired width here
                                  child: ElevatedButton(
                                    child: const Text("wallet display"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => WalletDisplayScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 50),
                                SizedBox(
                                  width: 200.0, // set the desired width here
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await auth.FirebaseAuth.instance.signOut();
                                      Provider.of<curr_user.UserProvider>(context, listen: false).signOut(); // Added this line
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginScreen()),
                                      );
                                    },
                                    child: const Text("Sign Out"),
                                  ),

                                ),
                              ]
                          )
                      )
                  )
              )
          );
        }
      },
    );
  }
}

