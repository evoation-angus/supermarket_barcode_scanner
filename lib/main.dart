import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  bool _isVisible = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Gas Voucher Scanner",
        theme: ThemeData(
          useMaterial3: true,

          // Define the default brightness and colors.
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red.shade800,
            // ···
            brightness: Brightness.light,
          ),

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
        ),
        home: Scaffold(
            appBar: AppBar(
                title: const Text('Selected Supermarket - New World',
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.red.shade800),
            body: Builder(builder: (BuildContext context) {
              return Container(
                  alignment: Alignment.center,
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/new_world.png',
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(height: 50),
                        ElevatedButton(
                            onPressed: () => scanBarcodeNormal(),
                            child: const Text('Start barcode scan')),
                        const SizedBox(height: 50),
                        Text('Scan result : $_scanBarcode\n',
                            style: const TextStyle(fontSize: 20)),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isVisible = !_isVisible;
                              });
                            },
                            child: const Text('Generate Barcode')),
                        const SizedBox(height: 50),
                        Visibility(
                          visible: _isVisible,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: SizedBox(
                              height: 100,
                              width: 300,
                              child: SfBarcodeGenerator(
                                value: _scanBarcode,
                                symbology: Code128(),
                                showValue: false,
                              )),
                        )
                      ]));
            })));
  }
}
