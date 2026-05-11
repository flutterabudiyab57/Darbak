import 'dart:convert';

BranchFromCarModel branchFromCarModelFromMap(String str) =>
    BranchFromCarModel.fromMap(json.decode(str));

String branchFromCarModelToMap(BranchFromCarModel data) =>
    json.encode(data.toMap());

class BranchFromCarModel {
  BranchFromCarModel({
    required this.data,
    this.meta,
  });

  List<Datum> data;
  Meta? meta;

  factory BranchFromCarModel.fromMap(Map<String, dynamic> json) =>
      BranchFromCarModel(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromMap(x))),
        meta: json["meta"] != null ? Meta.fromMap(json["meta"]) : null,
      );

  Map<String, dynamic> toMap() => {
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
    "meta": meta?.toMap(),
  };
}

class Datum {
  Datum({
    required this.id,
    required this.text,
    required this.image,
    required this.canBookToday,
    this.stockCount,
    this.availableCount,
  });

  int id;
  String text;
  String image;
  int canBookToday;
  int? stockCount;
  int? availableCount;

  factory Datum.fromMap(Map<String, dynamic> json) => Datum(
    id: json["id"],
    text: json["text"],
    image: json["image"] ?? "",
    canBookToday: json["can_book_today"] ?? 0,
    stockCount: json["stock_count"],
    availableCount: json["available_count"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "text": text,
    "image": image,
    "can_book_today": canBookToday,
    "stock_count": stockCount,
    "available_count": availableCount,
  };
}

class Meta {
  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  int? currentPage;
  int? from;
  int? lastPage;
  String? path;
  int? perPage;
  int? to;
  int? total;

  factory Meta.fromMap(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    from: json["from"],
    lastPage: json["last_page"],
    path: json["path"],
    perPage: int.tryParse(json["per_page"]?.toString() ?? '0'),
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toMap() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}