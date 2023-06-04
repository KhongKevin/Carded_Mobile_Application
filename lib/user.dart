import 'package:flutter/foundation.dart';
import 'package:carded/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore database = FirebaseFirestore.instance;

class User with ChangeNotifier {
  late String refId;
  late String email;
  late String card;
  late List<String> wallet;

  User(this.refId, this.email, this.card, this.wallet);

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
  User? _user;

  UserProvider() {
    _user = User("defaultID", "defaultEmail", "defaultCard", []);
  }

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void signOut() {
    _user = null; // Sign out
    notifyListeners();
  }

}

