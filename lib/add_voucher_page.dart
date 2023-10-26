import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'voucher.dart';

class SecondRoute extends StatefulWidget {
  const SecondRoute({key}) : super(key: key);

  @override
  State<SecondRoute> createState() {
    return _SecondRouteState();
  }
}

class _SecondRouteState extends State<SecondRoute> {
  sendVoucher(
      String barcode, String name, String branch, String expirydate) async {
    int id = int.parse(barcode);
    Voucher voucher =
        Voucher(name: name, branch: branch, id: id, expirydate: expirydate);
    List<Voucher> vouchers = [voucher];
    return vouchers;
    //return await handler.insertVoucher(vouchers);
  }

  @override
  void initState() {
    super.initState();
  }

  //String _scanBarcode = 'Unknown';
  //bool _isVisible = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController discountAmount = TextEditingController();
  TextEditingController barcodeController = TextEditingController();
  TextEditingController dateContoller = TextEditingController();
  String selectedDate = '';
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
    String locationIdentifier = list[0] + list[1];
    //String branchIdentifier = list[2] + list[3];
    if (locationIdentifier == "93") {
      nameController.text = "Tissue Box";
      branchController.text = "Desk";
    } else if (locationIdentifier == "14") {
      nameController.text = "New World";
      branchController.text = "Lower Hutt";
    } else if (locationIdentifier == "15") {
      nameController.text = "Pak'n'save";
      branchController.text = "Lower Hutt";
    }
    discountAmount.text = "6c";
    barcodeController.text = barcode;
  }

  void _presentDatePicker() {
    // showDatePicker is a pre-made funtion of Flutter
    DateTime dateNow = DateTime.now();
    DateTime initialDate = dateNow.add(const Duration(days: 11));
    showDatePicker(
            context: context,
            initialDate: initialDate,
            firstDate: DateTime.now(),
            lastDate: DateTime(2030))
        .then((pickedDate) {
      // Check if no date is selected
      if (pickedDate == null) {
        return;
      }
      selectedDate = pickedDate.toString();
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
    return WillPopScope(
        onWillPop: () async {
          List<Voucher> vouchers = [];
          Navigator.pop(context, vouchers);
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blue),
                onPressed: () {
                  List<Voucher> vouchers = [];
                  Navigator.pop(context, vouchers);
                },
              ),
              title: const Text('Add a new voucher'),
            ),
            body: Center(
              child: Flex(
                  direction: Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 16),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 16),
                      child: TextField(
                        controller: nameController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Station name',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 16),
                      child: TextField(
                        controller: branchController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Branch Name',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 16),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 16),
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context,
                            sendVoucher(
                                barcodeController.text,
                                nameController.text,
                                branchController.text,
                                selectedDate));
                      },
                      child: const Text('Save'),
                    )
                  ]),
            )));
  }
}
