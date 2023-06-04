import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore database = FirebaseFirestore.instance;

class User_Card with ChangeNotifier {
  late String id;
  late Image? profilePicture;
  late Map<String, String> contactPage;
  late Map<String, String> bioPage;

  User_Card(this.contactPage, this.bioPage);

  void updateUserCard(User_Card updatedUserCard) {
    this.id = updatedUserCard.id; // Assuming you have a user object and it has a `card` property
    notifyListeners(); // Notify listeners after changing the model
  }

  User_Card.fromDocument(DocumentSnapshot doc) {
    this.id = doc.id;  // add this line
    this.contactPage = Map<String, String>.from(doc['contactPage'] ?? {});
    this.bioPage = Map<String, String>.from(doc['bioPage'] ?? {});
    notifyListeners();
  }
  static Future<String> addCard(String fname, String lname, String email) async {
    final card = <String, dynamic>{
      "contactPage": {
        "Email": email,
        "Fname": fname,
        "Lname": lname,
        "Linkedin": "",
        "Website": ""
      },
      "bioPage":{
        "Current Employment": "",
        "Education": "",
        "Experience": ""
      }};
    DocumentReference docRef = await database.collection("cards").add(card);
    return docRef.id;
  }

}