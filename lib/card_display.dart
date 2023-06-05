import 'package:flutter/material.dart';
import 'dart:ui'; // Import dart:ui library to use Image.asset

class CardDisplay extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePictureUrl;
  final String? linkedin;
  final String? website;

  final String defaultProfilePicture = 'assets/images/profile.png'; // Declare the asset path for the default profile picture

  CardDisplay({
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePictureUrl,
    this.linkedin,
    this.website,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orangeAccent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: (profilePictureUrl != null && profilePictureUrl != '')
                      ? NetworkImage(profilePictureUrl!)
                      : AssetImage(defaultProfilePicture) as ImageProvider,

                ),
                SizedBox(width: 16),
                Text(
                  '$firstName $lastName',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              email,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              linkedin ?? '',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              website ?? '',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}