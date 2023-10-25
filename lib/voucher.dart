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

  int getId() {
    return id;
  }
}