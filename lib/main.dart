import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path/path.dart' as Path;
import 'package:sqflite/sqflite.dart';
//import 'package:syncfusion_flutter_barcodes/barcodes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class Voucher {
  late final int id;
  late final String name;
  late final String branch;
  late final String expirydate;

  Voucher(
      {required this.name,
      required this.branch,
      required this.id,
      required this.expirydate});

  Voucher.fromMap(Map<String, dynamic> result)
      : id = result["id"],
        name = result["name"],
        branch = result["branch"],
        expirydate = result["expirydate"];

  Map<String, Object> toMap() {
    return {'id': id, 'name': name, 'branch': branch, "expirydate": expirydate};
  }
  int getId(){
    return id;
  }
}

class DataBase {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      Path.join(path, 'vouchers.db'),
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          "CREATE TABLE vouchers(id INTEGER PRIMARY KEY , name TEXT NOT NULL,branch TEXT NOT NULL, expirydate TEXT NOT NULL)",
        );
      },
    );
  }

  // insert data
  Future<int> insertVoucher(List<Voucher> vouchers) async {
    int result = 0;
    final Database db = await initializedDB();
    for (var voucher in vouchers) {
      result = await db.insert('vouchers', voucher.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    return result;
  }

  // retrieve data
  Future<List<Voucher>> retrieveVoucher() async {
    final Database db = await initializedDB();
    final List<Map<String, Object?>> queryResult = await db.query('vouchers');
    return queryResult.map((e) => Voucher.fromMap(e)).toList();
  }

  // delete user
  Future<void> deleteVoucher(int id) async {
    final db = await initializedDB();
    await db.delete(
      'vouchers',
      where: "id = ?",
      whereArgs: [id],
    );
  }
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
  late DataBase handler;

  @override
  void initState() {
    handler = DataBase();
    super.initState();
  }

  Future sendToDb(List<Voucher> vouchers) async {
    return await handler.insertVoucher(vouchers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Saved Fuel Vouchers',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white),
      body: FutureBuilder(
          future: handler.retrieveVoucher(),
          builder: (context, AsyncSnapshot<List<Voucher>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data![index].name + " - " + snapshot.data![index].branch),
                      subtitle: Text(snapshot.data![index].expirydate + " - " + snapshot.data![index].id.toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(icon: const Icon(Icons.delete_forever), color: Colors.red, onPressed: (){}),
                          IconButton(icon: const Icon(Icons.qr_code), color: Colors.black, onPressed: (){})
                        ],
                      ),
                    ), 
                  );
                },
              );
            } else {
              return const Center(child: Text("No vouchers found"));
            }
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: SizedBox(
              width: 65,
              height: 65,
              child: FloatingActionButton(
                tooltip: 'Add', // used by assistive technologies
                onPressed: () async {
                  List<Voucher> result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SecondRoute()),
                  );
                  if (result.isNotEmpty) {
                    sendToDb(result);
                    setState(() {});
                  }
                },
                child: const Icon(Icons.add),
              ))),
    );
  }
}

class SecondRoute extends StatefulWidget {
  const SecondRoute({key}) : super(key: key);

  @override
  _SecondRouteState createState() => _SecondRouteState();
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
      nameController.text = "Tissue Box";
      branchController.text = "Desk";
    } else if (firstTwo == "14") {
      nameController.text = "New World";
      branchController.text = "Lower Hutt";
    } else if (firstTwo == "15") {
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.orange),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                    Navigator.pop(
                        context,
                        sendVoucher(barcodeController.text, nameController.text,
                            branchController.text, dateContoller.text));
                  },
                  child: const Text('Save'),
                )
              ]),
        ));
  }
}
