import 'dart:convert';
import 'dart:developer';
import 'package:hive_ce/hive.dart';
part 'branch_model.g.dart';
Data branchModelFromMap(String str) => Data.fromMap(json.decode(str));
String dataModelToMap(Data data) => json.encode(data.toMap());

int? _safeParseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed == null) log('⚠️ Failed to parse int from string: "$value"');
    return parsed;
  }
  log('⚠️ Unexpected type for int parsing: ${value.runtimeType}');
  return null;
}

class Data {
  Data({required this.data, required this.links, required this.meta});
  List<BranchModel> data;
  Links links;
  Meta meta;

  factory Data.fromMap(Map<String, dynamic> json) => Data(
    data: List<BranchModel>.from(json["data"].map((x) => BranchModel.fromMap(x))),
    links: Links.fromMap(json["links"]),
    meta: Meta.fromMap(json["meta"]),
  );

  Map<String, dynamic> toMap() => {
    "data": data.map((x) => x.toMap()).toList(),
    "links": links.toMap(),
    "meta": meta.toMap(),
  };
}

@HiveType(typeId: 0)
class BranchModel extends HiveObject {
  @HiveField(0)
  int? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? region;
  @HiveField(3)
  int? regionId;
  @HiveField(4)
  String? address;
  @HiveField(5)
  String? lat;
  @HiveField(6)
  String? long;
  @HiveField(7)
  String? phone;
  @HiveField(8)
  String? locationUrl;
  @HiveField(9)
  WorkTime? workTime;
  @HiveField(10)
  int? bookToday;
  @HiveField(11)
  int? deliveryPrice;
  @HiveField(12)
  List<PolygonPoint>? polygon;
  @HiveField(13)
  BranchCenter ? center;

  BranchModel({
    this.id,
    this.name,
    this.region,
    this.regionId,
    this.address,
    this.lat,
    this.long,
    this.phone,
    this.locationUrl,
    this.workTime,
    this.bookToday,
    this.deliveryPrice,
    this.polygon,
    this.center,
  });

  factory BranchModel.fromMap(Map<String, dynamic> json) => BranchModel(
    id: _safeParseInt(json["id"]),
    name: json["text"]?.toString() ?? json["name"]?.toString(),
    region: json["region"]?.toString(),
    regionId: _safeParseInt(json["region_id"]),
    address: json["address"]?.toString(),
    lat: json["lat"]?.toString(),
    long: json["long"]?.toString(),
    phone: json["phone"]?.toString(),
    locationUrl: json["location_url"]?.toString(),
    workTime: json["work_time"] != null ? WorkTime.fromMap(json["work_time"]) : null,
    bookToday: _safeParseInt(json["can_book_today"] ?? json["book_today"]),
    deliveryPrice: _safeParseInt(json["delivery_price"]),
    polygon: json["polygon"] != null
        ? List<PolygonPoint>.from(json["polygon"].map((x) => PolygonPoint.fromMap(x)))
        : null,
    center: json["center"] != null ? BranchCenter.fromMap(json["center"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "region": region,
    "region_id": regionId,
    "address": address,
    "lat": lat,
    "long": long,
    "phone": phone,
    "location_url": locationUrl,
    "work_time": workTime?.toMap(),
    "book_today": bookToday,
    "delivery_price": deliveryPrice,
    "polygon": polygon?.map((x) => x.toMap()).toList(),
    "center": center?.toMap(),
  };
}

@HiveType(typeId: 1)
class WorkTime {
  @HiveField(0)
  Alldays? alldays;
  @HiveField(1)
  Fri? fri;
  @HiveField(2)
  Mon? sat;
  @HiveField(3)
  Mon? sun;
  @HiveField(4)
  Mon? mon;
  @HiveField(5)
  Mon? tue;
  @HiveField(6)
  Mon? wed;
  @HiveField(7)
  Mon? thu;
  @HiveField(8)
  int? openAllDays;

  WorkTime({this.alldays, this.fri, this.sat, this.sun, this.mon, this.tue, this.wed, this.thu, this.openAllDays});

  factory WorkTime.fromMap(Map<String, dynamic> json) => WorkTime(
    alldays: json["alldays"] != null ? Alldays.fromMap(json["alldays"]) : null,
    fri: json["fri"] != null ? Fri.fromMap(json["fri"]) : null,
    sat: json["sat"] != null ? Mon.fromMap(json["sat"]) : null,
    sun: json["sun"] != null ? Mon.fromMap(json["sun"]) : null,
    mon: json["mon"] != null ? Mon.fromMap(json["mon"]) : null,
    tue: json["tue"] != null ? Mon.fromMap(json["tue"]) : null,
    wed: json["wed"] != null ? Mon.fromMap(json["wed"]) : null,
    thu: json["thu"] != null ? Mon.fromMap(json["thu"]) : null,
    openAllDays: _safeParseInt(json["openAllDays"]),
  );

  Map<String, dynamic> toMap() => {
    "alldays": alldays?.toMap(),
    "fri": fri?.toMap(),
    "sat": sat?.toMap(),
    "sun": sun?.toMap(),
    "mon": mon?.toMap(),
    "tue": tue?.toMap(),
    "wed": wed?.toMap(),
    "thu": thu?.toMap(),
    "openAllDays": openAllDays,
  };
}

@HiveType(typeId: 2)
class Alldays {
  @HiveField(0)
  int? period;
  @HiveField(1)
  Afternone? morning;
  @HiveField(2)
  Afternone? afternone;

  Alldays({this.period, this.morning, this.afternone});

  factory Alldays.fromMap(Map<String, dynamic> json) => Alldays(
    period: _safeParseInt(json["period"]),
    morning: json["morning"] != null ? Afternone.fromMap(json["morning"]) : null,
    afternone: json["afternone"] != null ? Afternone.fromMap(json["afternone"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "period": period,
    "morning": morning?.toMap(),
    "afternone": afternone?.toMap(),
  };
}

@HiveType(typeId: 3)
class Fri {
  @HiveField(0)
  int? period;
  @HiveField(1)
  Afternone? morning;
  @HiveField(2)
  Afternone? afternone;
  @HiveField(3)
  int? lock;

  Fri({this.period, this.morning, this.afternone, this.lock});

  factory Fri.fromMap(Map<String, dynamic> json) => Fri(
    period: _safeParseInt(json["period"]),
    morning: json["morning"] != null ? Afternone.fromMap(json["morning"]) : null,
    afternone: json["afternone"] != null ? Afternone.fromMap(json["afternone"]) : null,
    lock: _safeParseInt(json["lock"]),
  );

  Map<String, dynamic> toMap() => {
    "period": period,
    "morning": morning?.toMap(),
    "afternone": afternone?.toMap(),
    "lock": lock,
  };
}

@HiveType(typeId: 4)
class Afternone {
  @HiveField(0)
  String? timeopen;
  @HiveField(1)
  String? timeclose;

  Afternone({this.timeopen, this.timeclose});

  factory Afternone.fromMap(Map<String, dynamic> json) => Afternone(
    timeopen: json["timeopen"]?.toString(),
    timeclose: json["timeclose"]?.toString(),
  );

  Map<String, dynamic> toMap() => {
    "timeopen": timeopen,
    "timeclose": timeclose,
  };
}

@HiveType(typeId: 5)
class Mon {
  @HiveField(0)
  int? lock;

  Mon({this.lock});

  factory Mon.fromMap(Map<String, dynamic> json) => Mon(
    lock: _safeParseInt(json["lock"]),
  );

  Map<String, dynamic> toMap() => {"lock": lock};
}

@HiveType(typeId: 6)
class PolygonPoint {
  @HiveField(0)
  double? lat;
  @HiveField(1)
  double? lng;

  PolygonPoint({this.lat, this.lng});

  factory PolygonPoint.fromMap(Map<String, dynamic> json) => PolygonPoint(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {"lat": lat, "lng": lng};
}

@HiveType(typeId: 7)
@HiveType(typeId: 7)
class BranchCenter {
  @HiveField(0)
  double? lat;
  @HiveField(1)
  double? lng;

  BranchCenter({this.lat, this.lng});

  factory BranchCenter.fromMap(Map<String, dynamic> json) => BranchCenter(
    lat: json["lat"]?.toDouble(),
    lng: json["lng"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {"lat": lat, "lng": lng};
}
class Links {
  String? first;
  String? last;
  dynamic prev;
  String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromMap(Map<String, dynamic> json) => Links(
    first: json["first"]?.toString(),
    last: json["last"]?.toString(),
    prev: json["prev"],
    next: json["next"]?.toString(),
  );

  Map<String, dynamic> toMap() => {"first": first, "last": last, "prev": prev, "next": next};
}

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<Link>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta({this.currentPage, this.from, this.lastPage, this.links, this.path, this.perPage, this.to, this.total});

  factory Meta.fromMap(Map<String, dynamic> json) => Meta(
    currentPage: _safeParseInt(json["current_page"]),
    from: _safeParseInt(json["from"]),
    lastPage: _safeParseInt(json["last_page"]),
    links: json["links"] != null ? List<Link>.from(json["links"].map((x) => Link.fromMap(x))) : null,
    path: json["path"]?.toString(),
    perPage: _safeParseInt(json["per_page"]),
    to: _safeParseInt(json["to"]),
    total: _safeParseInt(json["total"]),
  );

  Map<String, dynamic> toMap() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    "links": links?.map((x) => x.toMap()).toList(),
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}

class Link {
  String? url;
  String? label;
  bool? active;

  Link({this.url, this.label, this.active});

  factory Link.fromMap(Map<String, dynamic> json) => Link(
    url: json["url"]?.toString(),
    label: json["label"]?.toString(),
    active: json["active"],
  );

  Map<String, dynamic> toMap() => {"url": url, "label": label, "active": active};
}