import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path_path;
import 'voucher.dart';

class DataBase {
  Future<Database> initializedDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      path_path.join(path, 'vouchers.db'),
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