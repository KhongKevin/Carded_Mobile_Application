import 'package:carded/QRGenerator.dart';
import 'package:carded/QRScanner.dart';
import 'package:carded/user.dart' as curr_user;
import 'package:carded/user_card.dart' as card;
import 'package:carded/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Import the async library

class AddUsers extends StatefulWidget {
  const AddUsers({Key? key}) : super(key: key);

  @override
  _AddUsersState createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> with ChangeNotifier {
  List<User_Card> _walletUsers = [];
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }


  Future<void> fetchData() async {
    Completer<void> dataFetchCompleter = Completer<void>(); // Create a Completer to control data fetching
    final userProvider = Provider.of<curr_user.UserProvider>(context, listen: false);
    final user = userProvider.user ?? curr_user.User("defaultID", "defaultEmail", "defaultCard", []);

    try {
      if (user.card != "defaultCard") {
        // Fetch the user's card if not default
        final docSnapshot = await database.collection('cards').doc(user.card).get();
        final userCard = card.User_Card.fromDocument(docSnapshot);
        userProvider.updateUserCard(userCard);
      }

      if (_walletUsers.isEmpty && user.email != "defaultEmail") {
        final users = await user.fetchWalletUsers();
        setState(() {
          _walletUsers = users;
        });
      }
      debugPrint(_walletUsers.toString()); // Debug print
    } catch (error) {
      // Handle any error that occurs during data fetching
      debugPrint('Error fetching data: $error');
    } finally {
      // Mark the data fetching as complete
      dataFetchCompleter.complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<curr_user.UserProvider>(
      builder: (context, userProvider, child) {
        final user =
            userProvider.user ?? curr_user.User("defaultID", "defaultEmail", "defaultCard", []);

        return Scaffold(
          appBar: AppBar(title: const Text("Add and Scan Users")),
          body: FractionallySizedBox(
            heightFactor: 1.0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QRScannerPage()),
                      );
                    },
                    child: const Text('Scan QR Code'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodePage(loggedIn: user),
                        ),
                      );
                    },
                    child: const Text('Display Your QR Code'),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _textController,
                            decoration: const InputDecoration(
                              labelText: 'Enter user id',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              String newUserId = _textController.text;

                              // Fetch user document from firestore
                              DocumentSnapshot userDoc =
                              await database.collection('users').doc(newUserId).get();

                              // Check if such user exists
                              if (userDoc.exists) {
                                // Fetch the user's card and add it to the wallet
                                await userProvider.user!.addCardToWallet(userDoc.get('Card'));
                                await fetchData();
                                // Update _walletUsers
                                setState(() {
                                  _walletUsers.add(User_Card.fromDocument(userDoc));
                                });

                                // Clear text field
                                _textController.clear();
                              } else {
                                debugPrint('No user found with the provided ID');
                              }
                            } catch (e) {
                              debugPrint('Error adding user: $e');
                            }
                          }
                        },
                        child: const Text('Add User'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
