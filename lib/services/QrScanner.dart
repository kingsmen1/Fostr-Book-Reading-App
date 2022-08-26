import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({ Key? key }) : super(key: key);

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;

  QRViewController? controller;

  Widget buildQrView(BuildContext context) => QRView(
    key: qrKey,
    onQRViewCreated: onQRViewCreated,
    overlay: QrScannerOverlayShape(
      borderLength: 20,
      borderRadius: 10,
      borderWidth: 10,
      cutOutSize: MediaQuery.of(context).size.width * 0.8,
    ),
  );

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((barcode) { setState(() {
      this.barcode = barcode;
    });
        // Navigator.pop(context, this.barcode?.code);
});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if(Platform.isAndroid){
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget buildResult() => Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white24
    ),
    child: GestureDetector(
      child: Text(
        barcode != null ? '${barcode!.code} scanned. Tap to Search.':'Scan a code',
        maxLines: 3,
        style: TextStyle(color: Colors.white)
      ),
      onTap: (){
        barcode != null ? Navigator.of(context).pop(barcode?.code):null;
      },
    )
  );

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQrView(context),
          Positioned(bottom:10, child: buildResult()),
          Positioned(top: 10, left: 5,
          child: IconButton(
            onPressed: (){
              Navigator.of(context).pop(barcode?.code);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
          ),)
        ],
      ),
    );
  }
}