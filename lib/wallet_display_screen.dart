import 'package:carded/main.dart';
import 'package:carded/user.dart' as curr_user;
import 'package:carded/user_card.dart' as card;
import 'package:carded/user_card.dart';
import 'package:flutter/material.dart';
import 'AddUsers.dart';
import 'card_display.dart';
import 'package:provider/provider.dart';
import 'edit_card_screen.dart';
import 'dart:async'; // Import the async library

class WalletDisplayScreen extends StatefulWidget {
  const WalletDisplayScreen({Key? key}): super(key: key);

  @override
  _WalletDisplayScreenState createState() => _WalletDisplayScreenState();
}

class _WalletDisplayScreenState extends State<WalletDisplayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFlipped = false;
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
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
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

  Future<void> fetchData() async {
    _dataFetchCompleter = Completer<void>();
    final userProvider = Provider.of<curr_user.UserProvider>(context, listen: false);
    final user = userProvider.user ?? curr_user.User("defaultID", "defaultEmail", "defaultCard", []);

    try {
      if (user.card != "defaultCard") {
        final docSnapshot = await database.collection('cards').doc(user.card).get();

        // Get profilePictureUrl from the document
        final profilePictureUrl = docSnapshot['profilePictureUrl'];

        final userCard = card.User_Card.fromDocument(docSnapshot);
        userProvider.updateUserCard(userCard);
      }

      // Rest of the code...
    } catch (error) {

      debugPrint('Error fetching data: $error');
    } finally {
      _dataFetchCompleter.complete();
    }
  }



  @override
  void dispose() {
    //_walletUsersSubscription?.cancel();
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    fetchData();
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _slideCardsBackDown() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<curr_user.UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user!;
        final userCardData = userProvider.userCard;



        return Scaffold(
          appBar: AppBar(
              title: Text(user.email),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                    onPressed: () {
                      userProvider.signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CardedHomePage(),)
                      );
                    },
                    icon: const Icon(Icons.logout)
                )
              ],
          ),
          body: FutureBuilder<void>(
            future: _dataFetchCompleter.future, // Wait for data fetching to complete
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                // Show a loading indicator while data is being fetched
                print('Wallet Users: ${userProvider.wallet}');

                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      if (!_isFlipped) ...[
                        const SizedBox(height: 30),
                        const SizedBox(height: 30,
                            child: Text(
                                "Your Card", style: TextStyle(fontSize: 20))),
                        SizedBox(
                          height: 220,
                          child: CardDisplay(
                            firstName: userCardData.contactPage['Fname'] ??
                                'FName',
                            lastName: userCardData.contactPage['Lname'] ??
                                'LName',
                            email: userCardData.contactPage['Email'] ?? 'Email',
                            linkedin: userCardData.contactPage['Linkedin'] ??
                                'linkedIn',
                            website: userCardData.contactPage['Website'] ??
                                'Website',
                            profilePictureUrl: userCardData.profilePictureUrl,
                            //     'Website',
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
                                curr_user.UserProvider userProvider = Provider.of<
                                    curr_user.UserProvider>(
                                    context, listen: false);
                                userProvider.updateUserCard(
                                    updatedUserCard as card
                                        .User_Card); // Here we update the card
                              }
                            });
                          },
                          child: const Text('Edit Card'),
                        ),
                        const SizedBox(height: 30),
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
                      ],

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
                          physics: const NeverScrollableScrollPhysics(),
                          // to make ListView inside Column
                          itemCount: userProvider.wallet.length,
                          itemBuilder: (context, index) {

                            return CardDisplay(
                              firstName: userProvider.wallet[index]
                                  .contactPage['Fname'] ?? 'N/A',
                              lastName: userProvider.wallet[index]
                                  .contactPage['Lname'] ?? 'N/A',
                              email: userProvider.wallet[index].contactPage['Email'] ??
                                  'N/A',
                              linkedin: userProvider.wallet[index]
                                  .contactPage['Linkedin'] ?? 'N/A',
                              website: userProvider.wallet[index]
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
              borderRadius: const BorderRadius.only(
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                height: 30,
                width: 300,
                alignment: Alignment.center,
                child: Text(
                  _isFlipped ? 'Hide Wallet' : 'Show Wallet',
                  style: const TextStyle(
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