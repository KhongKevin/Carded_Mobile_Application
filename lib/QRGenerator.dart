import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:carded/user.dart';

class QRCodePage extends StatelessWidget {
  final User loggedIn;

  QRCodePage({required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
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
