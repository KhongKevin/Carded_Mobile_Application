import 'package:flutter/foundation.dart';
import 'package:carded/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore database = FirebaseFirestore.instance;

class User with ChangeNotifier {
  late String refId;
  late String email;
  late String card;
  late List<String> wallet;
  late User_Card updatedCard;

  User(this.refId, this.email, this.card, this.wallet)
      : updatedCard = User_Card({'': ''}, {'': ''}); // Initialize an empty card


  User.fromDocument(DocumentSnapshot doc) {
    this.refId = doc.id;
    try {
      this.email = doc.get('Email');
    } catch (e) {
      this.email = '';
    }
    try {
      this.card = doc.get('Card');
    } catch (e) {
      this.card = '';
    }
    try {
      this.wallet = List<String>.from(doc.get('Wallet'));
    } catch (e) {
      this.wallet = [];
    }
    notifyListeners();
  }


  Future<void> addCardToWallet(String cardId) async {
    wallet.add(cardId);

    DocumentReference userRef = database.collection("users").doc(refId);
    await userRef.update({
      "Wallet": wallet
    });

    print("Card $cardId added to wallet");
    notifyListeners();
  }

  static Future<void> addUser(String email, String fname, String lname) async {
    String cardID = await User_Card.addCard(fname, lname, email);
    print("Card added");
    final user = <String, dynamic>{
      "Card": cardID,
      "Email": email,
      "Wallet":[]
    };
    database.collection("users").add(user);
    print("User added");
  }
  Future<User_Card> fetchUpdatedCard() async {
    if (card != "defaultCard") {
      DocumentSnapshot cardSnapshot =
      await database.collection('cards').doc(card).get();
      updatedCard = User_Card.fromDocument(cardSnapshot);
      updatedCard.id = cardSnapshot.id;  // add this line
    }
    return updatedCard;
  }


  Future<List<User_Card>> fetchWalletUsers() async {
    List<User_Card> walletUsers = [];

    for (var cardId in wallet) {
      DocumentSnapshot docSnapshot = await database.collection('cards').doc(cardId).get();
      User_Card userCard = User_Card.fromDocument(docSnapshot);

      walletUsers.add(userCard);
    }

    return walletUsers;
  }

  @override
  String toString(){
    return("$refId, $email, $card, $wallet");
  }
}


class UserProvider with ChangeNotifier {
  FirebaseFirestore database = FirebaseFirestore.instance;
  User? _user;
  User_Card _userCard = User_Card({'': ''}, {'': ''}); // Add the userCard property

  // Add an initializer to use in the signOut function
  void _init() {
    _user = User("defaultID", "defaultEmail", "defaultCard", []);
    _userCard = User_Card({'': ''}, {'': ''});
  }

  UserProvider() {
    _init();
  }

  User? get user => _user;
  User_Card get userCard => _userCard; // Add getter for userCard

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUserCard(User_Card updatedCard) {
    if (_user != null) {
      _user!.updatedCard = updatedCard;
      _userCard = updatedCard; // Update the userCard property
      notifyListeners();
    }
  }

  void signOut() {
    _init(); // Reset the user and userCard to their initial states
    notifyListeners();
  }
}
