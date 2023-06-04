import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
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
  late TextEditingController _emailController;       // Add this
  late TextEditingController _linkedinController;    // Add this
  late TextEditingController _websiteController;     // Add this
  late File? _profileImage;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.userCard.contactPage['Fname']);
    _lastNameController =
        TextEditingController(text: widget.userCard.contactPage['Lname']);
    _emailController =
        TextEditingController(text: widget.userCard.contactPage['Email']);
    _linkedinController =
        TextEditingController(text: widget.userCard.contactPage['Linkedin']);
    _websiteController =
        TextEditingController(text: widget.userCard.contactPage['Website']);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _profileImage = null;
    // Dispose other controllers
    super.dispose();
  }
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _profileImage = File(image!.path);
    });
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
    String email = _emailController.text;
    String linkedin = _linkedinController.text;
    String website = _websiteController.text;
    File? _profileImage = null; // Initialize with null

    User_Card? updatedUserCard;
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      if (_profileImage != null) {
        String profileImageUrl = await Provider.of<UserProvider>(
          context,
          listen: false,
        ).uploadProfilePicture(_profileImage!, widget.userCard.id);

        //update the profile picture URL in Firebase
        await firestore.collection('cards').doc(widget.userCard.id).update({
          'profilePictureUrl': profileImageUrl,
        });
      }

      // Update the other fields in Firebase
      await firestore.collection('cards').doc(widget.userCard.id).update({
        'contactPage.Fname': firstName,
        'contactPage.Lname': lastName,
        'contactPage.Email': email,
        'contactPage.Linkedin': linkedin,
        'contactPage.Website': website,
      });

      //retrieve the updated user card from Firebase
      DocumentSnapshot cardSnapshot =
      await firestore.collection('cards').doc(widget.userCard.id).get();
      updatedUserCard = User_Card.fromDocument(cardSnapshot);

      // update the user card
      Provider.of<UserProvider>(context, listen: false)
          .updateUserCard(updatedUserCard);

      // Show success message
      _showSnackBar('Card details saved successfully');
    } catch (error) {
      // Show error message
      _showSnackBar('Failed to save card details');
    }

    if (updatedUserCard != null || _profileImage == null) {
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
              IconButton(
                icon: Icon(Icons.photo_library),
                onPressed: _pickImage,
              ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _linkedinController,
                decoration: InputDecoration(labelText: 'LinkedIn'),
              ),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(labelText: 'Website'),
              ),
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