import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:carded/user.dart' as currUser;
import 'package:carded/user_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String qrCodeResult = "Not Yet Scanned";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Result",
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              qrCodeResult,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20.0,
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(15.0),
                side: BorderSide(color: Colors.blue, width: 3.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
              ),
              onPressed: () async {
                final scanResult = await BarcodeScanner.scan();
                setState(() {
                  qrCodeResult = scanResult.rawContent;
                  handleScannedUser(context);
                });
              },
              child: Text(
                "Open Scanner",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> handleScannedUser(BuildContext context) async {
    try {
      final userProvider = Provider.of<currUser.UserProvider>(context, listen: false);
      final user = userProvider.user ?? currUser.User("defaultID", "defaultEmail", "defaultCard", []);

      // Fetch user document from firestore
      DocumentSnapshot userDoc = await currUser.database
          .collection('users').doc(qrCodeResult).get();

      // Check if such user exists
      if (userDoc.exists) {
        // Fetch the user's card and add it to the wallet
        await userProvider.addCardToWallet(
            userDoc.get('Card'));
      } else {
        print('No user found with the provided ID');
      }
    } catch (e) {
      print('Error adding user: $e');
    }
  }
}
