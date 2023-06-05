import 'package:carded/QRGenerator.dart';
import 'package:carded/QRScanner.dart';
import 'package:carded/user.dart' as currUser;
import 'package:carded/user_card.dart' as card;
import 'package:carded/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'card_display.dart';
import 'package:provider/provider.dart';
import 'edit_card_screen.dart';
import 'dart:async'; // Import the async library

class AddUsers extends StatefulWidget {
  AddUsers({Key? key}) : super(key: key);

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
    Completer<void> _dataFetchCompleter = Completer<void>(); // Create a Completer to control data fetching
    final userProvider = Provider.of<currUser.UserProvider>(context, listen: false);
    final user = userProvider.user ?? currUser.User("defaultID", "defaultEmail", "defaultCard", []);

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
      print(_walletUsers); // Debug print
    } catch (error) {
      // Handle any error that occurs during data fetching
      print('Error fetching data: $error');
    } finally {
      // Mark the data fetching as complete
      _dataFetchCompleter.complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<currUser.UserProvider>(
      builder: (context, userProvider, child) {
        final user =
            userProvider.user ?? currUser.User("defaultID", "defaultEmail", "defaultCard", []);
        final userCardData = userProvider.userCard;

        return Scaffold(
          appBar: AppBar(title: Text("Add and Scan Users")),
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
                    child: Text('Scan QR Code'),
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
                    child: Text('Display Your QR Code'),
                  ),
                  SizedBox(height: 90),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _textController,
                            decoration: InputDecoration(
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
                                print('No user found with the provided ID');
                              }
                            } catch (e) {
                              print('Error adding user: $e');
                            }
                          }
                        },
                        child: Text('Add User'),
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
