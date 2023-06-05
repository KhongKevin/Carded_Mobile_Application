import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:carded/user.dart' as curr_user;
import 'package:flutter/material.dart';
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
        title: const Text('Scan QR Code'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              "Result",
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              qrCodeResult,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(15.0),
                side: const BorderSide(color: Colors.blue, width: 3.0),
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
              child: const Text(
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
      final userProvider = Provider.of<curr_user.UserProvider>(context, listen: false);
      final user = userProvider.user ?? curr_user.User("defaultID", "defaultEmail", "defaultCard", []);

      // Fetch user document from firestore
      DocumentSnapshot userDoc = await curr_user.database
          .collection('users').doc(qrCodeResult).get();

      // Check if such user exists
      if (userDoc.exists) {
        // Fetch the user's card and add it to the wallet
        await userProvider.addCardToWallet(
            userDoc.get('Card'));
      } else {
        debugPrint('No user found with the provided ID');
      }
    } catch (e) {
      debugPrint('Error adding user: $e');
    }
  }
}
