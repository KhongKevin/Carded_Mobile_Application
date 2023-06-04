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

class WalletDisplayScreen extends StatefulWidget {
  WalletDisplayScreen({Key? key}): super(key: key);

  @override
  _WalletDisplayScreenState createState() => _WalletDisplayScreenState();
}

class _WalletDisplayScreenState extends State<WalletDisplayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFlipped = false;
  List<card.User_Card> _walletUsers = [];
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  Completer<void> _dataFetchCompleter = Completer<void>(); // Create a Completer to control data fetching

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    fetchData(); // Call the function to fetch data
  }

  void fetchData() async {
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
  void dispose() {
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _slideCardsBackDown() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<currUser.UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user ?? currUser.User("defaultID", "defaultEmail", "defaultCard", []);
        final userCardData = userProvider.userCard;

        return Scaffold(
          appBar: AppBar(title: Text(user.email)),
          body: FutureBuilder<void>(
            future: _dataFetchCompleter.future, // Wait for data fetching to complete
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // Show a loading indicator while data is being fetched
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!_isFlipped) ...[
                        SizedBox(height: 100),
                        SizedBox(height: 30,
                            child: Text(
                                "Your Card", style: TextStyle(fontSize: 20))),
                        Container(
                          height: 200,
                          child: CardDisplay(
                            firstName: userCardData.contactPage['Fname'] ??
                                'First Name',
                            lastName: userCardData.contactPage['Lname'] ??
                                'Last Name',
                            email: userCardData.contactPage['Email'] ?? 'Email',
                            linkedin: userCardData.contactPage['Linkedin'] ??
                                'linkedIn',
                            website: userCardData.contactPage['Website'] ??
                                'Website',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  EditCardScreen(userCard: userCardData)),
                            ).then((updatedUserCard) {
                              if (updatedUserCard != null) {
                                currUser.UserProvider userProvider = Provider.of<
                                    currUser.UserProvider>(
                                    context, listen: false);
                                userProvider.updateUserCard(
                                    updatedUserCard as card
                                        .User_Card); // Here we update the card
                              }
                            });
                          },
                          child: Text('Edit Card'),
                        ),
                        SizedBox(height: 100),
                      ],
                      if (!_isFlipped)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRScannerPage()),
                                );
                              },
                              child: Text('Scan QR Code'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      QRCodePage(loggedIn: user)),
                                );
                              },
                              child: Text('Display Your QR Code'),
                            ),
                          ],
                        ),
                      if (!_isFlipped)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ...
                            // your existing buttons here
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Form(
                                key: _formKey,
                                child: TextFormField(
                                  controller: _textController,
                                  decoration: InputDecoration(
                                    labelText: 'Enter username',
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
                                    DocumentSnapshot userDoc = await database
                                        .collection('users').doc(newUserId).get();

                                    // Check if such user exists
                                    if (userDoc.exists) {
                                      // Fetch the user's card and add it to the wallet
                                      await userProvider.user!.addCardToWallet(
                                          userDoc.get('Card'));

                                      // Update _walletUsers
                                      setState(() {
                                        _walletUsers.add(
                                            User_Card.fromDocument(userDoc));
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
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: ListView.builder(
                          shrinkWrap: true,
                          // to make ListView inside Column
                          physics: NeverScrollableScrollPhysics(),
                          // to make ListView inside Column
                          itemCount: _walletUsers.length,
                          itemBuilder: (context, index) {
                            return CardDisplay(
                              firstName: _walletUsers[index]
                                  .contactPage['Fname'] ?? 'N/A',
                              lastName: _walletUsers[index]
                                  .contactPage['Lname'] ?? 'N/A',
                              email: _walletUsers[index].contactPage['Email'] ??
                                  'N/A',
                              linkedin: _walletUsers[index]
                                  .contactPage['Linkedin'] ?? 'N/A',
                              website: _walletUsers[index]
                                  .contactPage['Website'] ?? 'N/A',
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                );



            },
          ),
          bottomNavigationBar: Container(
            height: 30,
            alignment: Alignment.bottomCenter,
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              onTap: () {
                if (_isFlipped) {
                  _slideCardsBackDown();
                } else {
                  _controller.forward();
                }
                _toggleFlip();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                height: 30,
                width: 300,
                alignment: Alignment.center,
                child: Text(
                  _isFlipped ? 'Hide Wallet' : 'Show Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}