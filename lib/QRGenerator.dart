import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:carded/user.dart' as curr_user;

class QRCodePage extends StatelessWidget {
  final curr_user.User loggedIn;

  QRCodePage({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Center(
        child: RepaintBoundary(
            child: QrImageView(
              //unique per id
              data: loggedIn.refId,
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            )
        ),
      ),
    );
  }
}
