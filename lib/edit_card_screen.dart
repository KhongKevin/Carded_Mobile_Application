import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'user.dart';
import 'package:carded/user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditCardScreen extends StatefulWidget {
  final User_Card userCard;

  EditCardScreen({required this.userCard});

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  // Add controllers for other fields

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.userCard.contactPage['Fname']);
    _lastNameController =
        TextEditingController(text: widget.userCard.contactPage['Lname']);
    // Initialize other controllers with existing values
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    // Dispose other controllers
    super.dispose();
  }

  void _showSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _saveCardDetails() async {
    // Get the updated values from the form fields
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    // Get other field values as needed

    User_Card? updatedUserCard;

    try {
      // Update the card details in Firebase
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('cards').doc(widget.userCard.id).update({
        'contactPage.Fname': firstName,
        'contactPage.Lname': lastName,
        // Update other fields as needed
      });

      // Retrieve the updated user card from Firebase
      DocumentSnapshot cardSnapshot =
      await firestore.collection('cards').doc(widget.userCard.id).get();
      updatedUserCard = User_Card.fromDocument(cardSnapshot);

      // Update the user card in the user model
      Provider.of<UserProvider>(context, listen: false)
          .updateUserCard(updatedUserCard);

      // Show success message
      _showSnackBar('Card details saved successfully');
    } catch (error) {
      // Show error message
      _showSnackBar('Failed to save card details');
    }

    if (updatedUserCard != null) {
      // Navigate back to the previous screen and pass the updated user card
      Navigator.pop(context, updatedUserCard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: Text('Edit Card')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              // Add other form fields
              ElevatedButton(
                onPressed: _saveCardDetails,
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}