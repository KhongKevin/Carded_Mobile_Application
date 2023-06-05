import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:carded/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


FirebaseFirestore database = FirebaseFirestore.instance;

class User with ChangeNotifier {
  late String refId;
  late String email;
  late String card;
  late List<String> wallet;
  late User_Card updatedCard;

  User(this.refId, this.email, this.card, this.wallet)
      : updatedCard = User_Card("", {'': ''}, {'': ''}); // Initialize an empty card


  User.fromDocument(DocumentSnapshot doc) {
    refId = doc.id;
    try {
      email = doc.get('Email');
    } catch (e) {
      email = '';
    }
    try {
      card = doc.get('Card');
    } catch (e) {
      card = '';
    }
    try {
      wallet = List<String>.from(doc.get('Wallet'));
    } catch (e) {
      wallet = [];
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
    debugPrint("Card added");
    final user = <String, dynamic>{
      "Card": cardID,
      "Email": email,
      "Wallet":[]
    };
    database.collection("users").add(user);
    debugPrint("User added");
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

  Stream<List<User_Card>> watchWalletUsers() async* {
    for (var cardId in wallet) {
      // 'snapshots()' method provides a stream of snapshots
      var docStream = database.collection('cards').doc(cardId).snapshots();

      // Using await for loop to listen to the stream
      await for (var snapshot in docStream) {
        if (snapshot.exists) {
          // Create a new User_Card and yield a list of them
          User_Card userCard = User_Card.fromDocument(snapshot);
          yield [userCard];  // Yields a List of User_Card
        }
      }
    }
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
  User_Card _userCard = User_Card("", {'': ''}, {'': ''}); // Add the userCard property
  List<User_Card> wallet = [];

  // Add an initializer to use in the signOut function
  void _init() {
    _user = User("defaultID", "defaultEmail", "defaultCard", []);
    _userCard = User_Card("", {'': ''}, {'': ''});
    wallet = [];
  }

  UserProvider() {
    _init();
  }

  Future<void> addCardToWallet(String cardId) async {
    _user?.addCardToWallet(cardId);

    database.collection("cards").doc(cardId).get().then((docSnapshot) {
      String ppurl = docSnapshot['profilePictureUrl'];
      Map<String, dynamic> bP = docSnapshot['bioPage'];
      Map<String, dynamic> cP = docSnapshot['contactPage'];
      Map<String, String> bioPage = {
        "Current Employment": bP['Current Employment'].toString(),
        "Education": bP['Education'].toString(),
        "Experience": bP['Experience'].toString()
      };
      Map<String, String> contactPage = {
        "Email": cP['Email'].toString(),
        "Fname": cP['Fname'].toString(),
        "Lname": cP['Lname'].toString(),
        "Linkedin": cP['Linkedin'].toString(),
        "Website": cP['Website'].toString()
      };

      User_Card card = User_Card(ppurl, contactPage, bioPage);
      wallet.add(card);
    },
      onError: (e) {
        debugPrint('Error completing $e');
      }
    );
  }

  User? get user => _user;
  User_Card get userCard => _userCard; // Add getter for userCard

  void setUser(User user) {
    _user = user;
    List<String> w = user.wallet;

    database.collection("cards").
        where(FieldPath.documentId, whereIn: w).
        get().
        then((querySnapshot) {
          for(var docSnapshot in querySnapshot.docs){
            String ppurl = docSnapshot['profilePictureUrl'];
            Map<String, dynamic> bP = docSnapshot['bioPage'];
            Map<String, dynamic> cP = docSnapshot['contactPage'];
            Map<String, String> bioPage = {
              "Current Employment": bP['Current Employment'].toString(),
              "Education": bP['Education'].toString(),
              "Experience": bP['Experience'].toString()
            };
            Map<String, String> contactPage = {
              "Email": cP['Email'].toString(),
              "Fname": cP['Fname'].toString(),
              "Lname": cP['Lname'].toString(),
              "Linkedin": cP['Linkedin'].toString(),
              "Website": cP['Website'].toString()
            };

            User_Card card = User_Card(ppurl, contactPage, bioPage);
            wallet.add(card);
          }
        }, onError: (e) {
            debugPrint("Error completing: $e");
          }
        );
    notifyListeners();
  }


  void updateUserCard(User_Card updatedCard) {
    if (_user != null) {
      _user!.updatedCard = updatedCard;
      _userCard = updatedCard; // Update the userCard property
      notifyListeners();
    }
  }


  Future<String> uploadProfilePicture(File imageFile, String uid) async {
    String fileName = 'users/$uid/profilePicture.png'; // File path in the storage

    Reference ref = FirebaseStorage.instance.ref().child(fileName);

    //upload the file to Firebase Storage
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;

    //get the URL of the uploaded file
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    return imageUrl;
  }


  void signOut() {
    _init(); // Reset the user and userCard to their initial states
    notifyListeners();
  }
}