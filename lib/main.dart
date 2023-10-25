import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';
import 'database.dart';
import 'voucher.dart';
import 'add_voucher_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
                      title: Text("${snapshot.data![index].name} - ${snapshot.data![index].branch}"),
                      subtitle: Text("${snapshot.data![index].expirydate} - ${snapshot.data![index].id.toString()}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                              icon: const Icon(Icons.delete_forever),
                              color: Colors.red,
                              onPressed: () {
                                Widget okButton = TextButton(
                                  child: const Text("Delete"),
                                  onPressed: () {
                                    handler.deleteVoucher(
                                        snapshot.data![index].id);
                                    setState(() {});
                                    Navigator.of(context).pop();
                                  },
                                );
                                AlertDialog alert = AlertDialog(
                                  title: const Text("Delete voucher"),
                                  content: const Text("Are you sure?"),
                                  actions: [
                                    okButton,
                                  ],
                                );
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    });
                              }),
                          IconButton(
                              icon: const Icon(Icons.qr_code),
                              color: Colors.black,
                              onPressed: () {
                                Widget okButton = TextButton(
                                  child: const Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                                AlertDialog alert = AlertDialog(
                                  title: const Text("Barcode"),
                                  content: SizedBox(
                                      height: 100,
                                      width: 300,
                                      child: SfBarcodeGenerator(
                                        value:
                                            snapshot.data![index].id.toString(),
                                        symbology: Code128(),
                                        showValue: false,
                                      )),
                                  actions: [
                                    okButton,
                                  ],
                                );
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    });
                              }),
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
              width: 60,
              height: 60,
              child: FloatingActionButton.large(
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
                child: const Icon(Icons.add,),
              ))),
    );
  }
}

