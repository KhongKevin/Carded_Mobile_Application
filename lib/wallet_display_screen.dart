import 'package:carded/QRGenerator.dart';
import 'package:carded/QRScanner.dart';
import 'package:carded/user.dart';
import 'package:carded/user_card.dart' as card;
import 'package:flutter/material.dart';
import 'card_display.dart';
import 'package:provider/provider.dart';

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
  }

  @override
  void dispose() {
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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user ?? User("defaultID", "defaultEmail", "defaultCard", []);
        card.User_Card userCard = card.User_Card({'': ''}, {'': ''}, []); // Initialize an empty card

        // Fetch the user's card if not default
        if(user.card != "defaultCard") {
          database.collection('cards').doc(user.card).get().then((docSnapshot) {
            userCard = card.User_Card.fromDocument(docSnapshot);
          });
        }

        if (_walletUsers.isEmpty && user.email != "defaultEmail") {
          user.fetchWalletUsers().then((users) {
            setState(() {
              _walletUsers = users;
            });
          });
        }
        // if (!_isFlipped)
        //   SizedBox(height:100),
        // SizedBox(height:30, child: Text("Your Card", style: TextStyle(fontSize: 20))),
        // Container(height: 200, child: CardDisplay(
        // firstName: userCard.contactPage['Fname'] ?? 'First Name',
        // lastName: userCard.contactPage['Lname'] ?? 'Last Name',
        // email: userCard.contactPage['Email'] ?? 'Email',
        // linkedin: userCard.contactPage['Linkedin'] ?? 'linkedIn',
        // website: userCard.contactPage['Website'] ?? 'Website',
        // ),
        // ),
        // SizedBox(height:100),
        return Scaffold(
          appBar: AppBar(title: Text(user.email)),
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (!_isFlipped) ...[
                  SizedBox(height: 100),
                  SizedBox(height: 30, child: Text("Your Card", style: TextStyle(fontSize: 20))),
                  Container(
                    height: 200,
                    child: CardDisplay(
                      firstName: userCard.contactPage['Fname'] ?? 'First Name',
                      lastName: userCard.contactPage['Lname'] ?? 'Last Name',
                      email: userCard.contactPage['Email'] ?? 'Email',
                      linkedin: userCard.contactPage['Linkedin'] ?? 'linkedIn',
                      website: userCard.contactPage['Website'] ?? 'Website',
                    ),
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
                            MaterialPageRoute(builder: (context) => QRScannerPage()),
                          );
                        },
                        child: Text('Scan QR Code'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRCodePage(loggedIn: user)),
                          );
                        },
                        child: Text('Display Your QR Code'),
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
                    shrinkWrap: true, // to make ListView inside Column
                    physics: NeverScrollableScrollPhysics(), // to make ListView inside Column
                    itemCount: _walletUsers.length,
                    itemBuilder: (context, index) {
                      return CardDisplay(
                        firstName: _walletUsers[index].contactPage['Fname'] ?? 'N/A',
                        lastName: _walletUsers[index].contactPage['Lname'] ?? 'N/A',
                        email: _walletUsers[index].contactPage['Email'] ?? 'N/A',
                        linkedin: _walletUsers[index].contactPage['Linkedin'] ?? 'N/A',
                        website: _walletUsers[index].contactPage['Website'] ?? 'N/A',
                      );
                    },
                  ),
                ),
              ],
            ),
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
                    topLeft: Radius.circular(15), topRight: Radius.circular(15),
                  ),
                ), height: 30, width: 300,
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
