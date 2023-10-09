import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
//import 'package:syncfusion_flutter_barcodes/barcodes.dart';

void main() => runApp(const MyApp());

class VoucherDetails {
  final String name;
  final String branch;
  final String barcode;

  const VoucherDetails(
      {required this.name, required this.branch, required this.barcode});
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
      debugShowCheckedModeBanner: false,
      title: "Gas Voucher Scanner",
      theme: ThemeData(
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          // ···
          brightness: Brightness.light,
        ),

        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
              title: const Text('Saved Fuel Vouchers',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white),
          body: Builder(builder: (BuildContext context) {
            return Container(
                alignment: Alignment.center,
                child: const Flex(
                    direction: Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /*ElevatedButton(
                          onPressed: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SecondRoute()),
                                )
                              },
                          child: const Text('Add new voucher')),*/
                      const SizedBox(height: 50),
                      const SizedBox(height: 50),
                    ]));
          }),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding( 
            padding: const EdgeInsets.only(bottom: 50.0),
            child:SizedBox( 
            width: 65,
            height: 65,
            child:FloatingActionButton(
            tooltip: 'Add', // used by assistive technologies
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SecondRoute()),
              )
            },
            child: const Icon(Icons.add),
          ))),
        );
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute({key}) : super(key: key);

  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  @override
  void initState() {
    super.initState();
  }

  //String _scanBarcode = 'Unknown';
  //bool _isVisible = false;
  TextEditingController stationName = TextEditingController();
  TextEditingController branchName = TextEditingController();
  TextEditingController discountAmount = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController dateContoller = TextEditingController();
  //String _dateSelected = '';

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      //print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    updateTextBoxes(barcodeScanRes);
  }

  void updateTextBoxes(barcode) {
    String str = barcode;
    List<String> list = str.split("");
    String firstTwo = list[0] + list[1];
    if (firstTwo == "93") {
      stationName.text = "Tissue Box";
      branchName.text = "Desk";
    } else if (firstTwo == "14") {
      stationName.text = "New World";
      branchName.text = "Lower Hutt";
    } else if (firstTwo == "15") {
      stationName.text = "Pak'n'save";
      branchName.text = "Lower Hutt";
    }
    discountAmount.text = "6c";
    barcodeController.text = barcode;
  }

  void _presentDatePicker() {
    // showDatePicker is a pre-made funtion of Flutter
    DateTime dateNow = DateTime.now();
    DateTime initialDate = dateNow.add(const Duration(days: 6));
    showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030))
        .then((pickedDate) {
      // Check if no date is selected
      if (pickedDate == null) {
        return;
      }
      String newFormat = DateFormat('dd MMM yyyy').format(pickedDate);
      dateContoller.text = newFormat;
      setState(() {
        // using state so that the UI will be rerendered when date is picked
        //_dateSelected = newFormat;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add a new voucher'),
        ),
        body: Center(
          child: Flex(
              direction: Axis.vertical,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: TextField(
                    controller: discountAmount,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Discount Amount',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: TextField(
                    controller: stationName,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Station name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: TextField(
                    controller: branchName,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Branch Name',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: TextField(
                    controller: barcodeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Barcode',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: TextField(
                    controller: dateContoller,
                    readOnly: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Expiry Date',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
                /*Container(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    'Expiry Date: $_dateSelected',
                    style: const TextStyle(fontSize: 25),
                  ),
                ), */
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                          width: 150,
                          child: ElevatedButton(
                              onPressed: _presentDatePicker,
                              child: const Text('Select Date'))),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: 150,
                          child: ElevatedButton(
                              onPressed: () => scanBarcodeNormal(),
                              child: const Text('Scan Barcode')))
                    ]),

                const SizedBox(height: 20),
                /*Text('Scan result : $_scanBarcode\n',
                    style: const TextStyle(fontSize: 20)),*/
                /*Visibility(
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
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                    child: const Text('Generate Barcode')
                ),*/

                // display the selected date

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                )
              ]),
        ));
  }
}
