import 'dart:convert';

Cars carsFromMap(String str) => Cars.fromMap(json.decode(str));

String carsToMap(Cars data) => json.encode(data.toMap());

class Cars {
  Cars({
    required this.data,
    this.meta,
  });

  List<DataCars>? data;
  Meta? meta;

  Cars copyWith({
    required List<DataCars> data,
    required Meta meta,
  }) =>
      Cars(
        data: data,
        meta: meta,
      );

  factory Cars.fromMap(Map<String, dynamic> json) => Cars(
    data: List<DataCars>.from(
        json["data"]?.map((x) => DataCars.fromMap(x))),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toMap() => {
    "data": List<dynamic>.from(data?.map((x) => x.toMap()) ?? []),
    "meta": meta?.toJson(),
  };
}

// ✅ NEW: Coupon class to handle the coupon list from API
class Coupon {
  Coupon({
    this.name,
    this.referralName,
  });

  String? name;
  String? referralName;

  factory Coupon.fromMap(Map<String, dynamic> json) => Coupon(
    name: json["name"],
    referralName: json["referral_name"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "referral_name": referralName,
  };
}

class DataCars {
  DataCars({
    required this.id,
    required this.name,
    required this.model,
    required this.fuel,
    required this.kilo,
    required this.categoryId,
    required this.category,
    required this.manufactory,
    required this.priceBefore,
    required this.priceAfter,
    required this.totalpriceafter,
    required this.totalpricebefore,
    required this.discount,
    required this.doors,
    required this.luggage,
    required this.transmission,
    required this.isFavorite,
    required this.description,
    required this.photo,
    required this.photos,
    required this.available,
    required this.availableBranches,
    required this.offer,
    required this.price1Month,
    required this.price3Month,
    required this.price6Month,
    required this.price9Month,
    required this.price12Month,
    required this.priceAfter1Month,
    required this.priceAfter3Month,
    required this.priceAfter6Month,
    required this.priceAfter9Month,
    required this.priceAfter12Month,
    this.coupons,
  });

  num id;
  String name;
  num model;
  String fuel;
  num kilo;
  num categoryId;
  String category;
  String manufactory;
  int priceBefore;
  int priceAfter;
  int totalpriceafter;
  int totalpricebefore;
  num discount;
  num doors;
  num luggage;
  String transmission;
  bool isFavorite;
  String description;
  String photo;
  List<Photo> photos;
  num available;
  List<Branch> availableBranches;
  num offer;
  num price1Month;
  num price3Month;
  num price6Month;
  num price9Month;
  num price12Month;
  num priceAfter1Month;
  num priceAfter3Month;
  num priceAfter6Month;
  num priceAfter9Month;
  num priceAfter12Month;
  // ✅ FIXED: Changed from String? to List<Coupon>?
  List<Coupon>? coupons;

  DataCars copyWith({
    required num id,
    required String name,
    required num model,
    required String fuel,
    required num kilo,
    required num categoryId,
    required String category,
    required String manufactory,
    required int priceBefore,
    required int priceAfter,
    required int totalpriceafter,
    required int totalpricebefore,
    required num discount,
    required num doors,
    required num luggage,
    required String transmission,
    required bool isFavorite,
    required String description,
    required String photo,
    required List<Photo> photos,
    required num available,
    required List<Branch> availableBranches,
    required num offer,
    required num price1Month,
    required num price3Month,
    required num price6Month,
    required num price9Month,
    required num price12Month,
    required num priceAfter1Month,
    required num priceAfter3Month,
    required num priceAfter6Month,
    required num priceAfter9Month,
    required num priceAfter12Month,
    List<Coupon>? coupons,
  }) =>
      DataCars(
        id: id,
        name: name,
        model: model,
        fuel: fuel,
        kilo: kilo,
        categoryId: categoryId,
        category: category,
        manufactory: manufactory,
        priceBefore: priceBefore,
        priceAfter: priceAfter,
        totalpriceafter: totalpriceafter,
        totalpricebefore: totalpricebefore,
        discount: discount,
        doors: doors,
        luggage: luggage,
        transmission: transmission,
        isFavorite: isFavorite,
        description: description,
        photo: photo,
        photos: photos,
        available: available,
        availableBranches: availableBranches,
        offer: offer,
        price1Month: price1Month,
        price3Month: price3Month,
        price6Month: price6Month,
        price9Month: price9Month,
        price12Month: price12Month,
        priceAfter1Month: priceAfter1Month,
        priceAfter3Month: priceAfter3Month,
        priceAfter6Month: priceAfter6Month,
        priceAfter9Month: priceAfter9Month,
        priceAfter12Month: priceAfter12Month,
        coupons: coupons,
      );

  factory DataCars.fromMap(Map<String, dynamic> json) => DataCars(
    id: json["id"],
    name: json["name"],
    model: json["model"],
    fuel: json["fuel"],
    kilo: json["kilo"],
    categoryId: json["category_id"],
    category: json["category"],
    manufactory: json["manufactory"],
    priceBefore: (json["total_price_before"] ?? 0).toInt(),
    priceAfter: (json["total_price_after"] ?? 0).toInt(),
    totalpriceafter: (json["total_price_after"] ?? 0).toInt(),
    totalpricebefore: (json["total_price_before"] ?? 0).toInt(),
    discount: json["discount"],
    doors: json["doors"],
    luggage: json["luggage"],
    transmission: json["transmission"],
    isFavorite: json["is_favorite"],
    description: json["description"],
    photo: json["photo"],
    photos: List<Photo>.from(
        json["photos"].map((x) => Photo.fromMap(x))),
    available: json["available"],
    availableBranches: List<Branch>.from(
        json["available_branches"].map((x) => Branch.fromMap(x))),
    offer: json["offer"],
    price1Month: json["price_1month"] ?? 0,
    price3Month: json["price_3month"] ?? 0,
    price6Month: json["price_6month"] ?? 0,
    price9Month: json["price_9month"] ?? 0,
    price12Month: json["price_12month"] ?? 0,
    priceAfter1Month: json["price_after_1month"] ?? 0,
    priceAfter3Month: json["price_after_3month"] ?? 0,
    priceAfter6Month: json["price_after_6month"] ?? 0,
    priceAfter9Month: json["price_after_9month"] ?? 0,
    priceAfter12Month: json["price_after_12month"] ?? 0,
    // ✅ FIXED: Parse coupon as List<Coupon> safely
    coupons: json["coupon"] != null && json["coupon"] is List
        ? List<Coupon>.from(
        (json["coupon"] as List).map((x) => Coupon.fromMap(x)))
        : null,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "model": model,
    "fuel": fuel,
    "kilo": kilo,
    "category_id": categoryId,
    "category": category,
    "manufactory": manufactory,
    "total_price_before": totalpricebefore,
    "total_price_after": totalpriceafter,
    "discount": discount,
    "doors": doors,
    "luggage": luggage,
    "transmission": transmission,
    "is_favorite": isFavorite,
    "description": description,
    "photo": photo,
    "photos": List<dynamic>.from(photos.map((x) => x.toMap())),
    "available": available,
    "available_branches":
    List<dynamic>.from(availableBranches.map((x) => x.toMap())),
    "offer": offer,
    "price_1month": price1Month,
    "price_3month": price3Month,
    "price_6month": price6Month,
    "price_9month": price9Month,
    "price_12month": price12Month,
    "price_after_1month": priceAfter1Month,
    "price_after_3month": priceAfter3Month,
    "price_after_6month": priceAfter6Month,
    "price_after_9month": priceAfter9Month,
    "price_after_12month": priceAfter12Month,
    // ✅ FIXED: Serialize coupon list properly
    "coupon": coupons != null
        ? List<dynamic>.from(coupons!.map((x) => x.toMap()))
        : null,
  };
}

class Photo {
  Photo({
    required this.id,
    required this.url,
    required this.preview,
    required this.name,
    required this.fileName,
    required this.type,
    required this.mimeType,
    required this.size,
    required this.humanReadableSize,
    required this.details,
    required this.status,
    this.progress,
  });

  num? id;
  String? url;
  String? preview;
  String? name;
  String? fileName;
  String? type;
  String? mimeType;
  num size;
  String? humanReadableSize;
  Details? details;
  String? status;
  num? progress;

  Photo copyWith({
    required num id,
    required String url,
    required String preview,
    required String name,
    required String fileName,
    required String type,
    required String mimeType,
    required num size,
    required String humanReadableSize,
    required Details details,
    required String status,
    num? progress,
  }) =>
      Photo(
        id: id,
        url: url,
        preview: preview,
        name: name,
        fileName: fileName,
        type: type,
        mimeType: mimeType,
        size: size,
        humanReadableSize: humanReadableSize,
        details: details,
        status: status,
        progress: progress,
      );

  factory Photo.fromMap(Map<String, dynamic> json) => Photo(
    id: json["id"],
    url: json["url"],
    preview: json["preview"],
    name: json["name"],
    fileName: json["file_name"],
    type: json["type"],
    mimeType: json["mime_type"],
    size: json["size"],
    humanReadableSize: json["human_readable_size"],
    details: Details.fromMap(json["details"]),
    status: json["status"] ?? "",
    progress: json["progress"] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "url": url,
    "preview": preview,
    "name": name,
    "file_name": fileName,
    "type": type,
    "mime_type": mimeType,
    "size": size,
    "human_readable_size": humanReadableSize,
    "details": details?.toMap(),
    "status": status,
    "progress": progress,
  };
}

class Details {
  Details({
    required this.width,
    required this.height,
    required this.ratio,
  });

  num width;
  num height;
  num ratio;

  Details copyWith({
    required num width,
    required num height,
    required num ratio,
  }) =>
      Details(
        width: width,
        height: height,
        ratio: ratio,
      );

  factory Details.fromMap(Map<String, dynamic> json) => Details(
    width: json["width"] ?? 0,
    height: json["height"] ?? 0,
    ratio: (json["ratio"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "width": width,
    "height": height,
    "ratio": ratio,
  };
}

class Branch {
  Branch({
    required this.id,
    required this.text,
    this.image,
    this.canBookToday,
    this.availableCount,
  });

  num id;
  String text;
  String? image;
  num? canBookToday;
  num? availableCount;

  Branch copyWith({
    required num id,
    required String text,
    String? image,
    num? canBookToday,
    num? availableCount,
  }) =>
      Branch(
        id: id,
        text: text,
        image: image,
        canBookToday: canBookToday,
        availableCount: availableCount,
      );

  factory Branch.fromMap(Map<String, dynamic> json) => Branch(
    id: json["id"],
    text: json["text"],
    image: json["image"] ?? "",
    canBookToday: json["can_book_today"],
    availableCount: json["available_count"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "text": text,
    "image": image,
    "can_book_today": canBookToday,
    "available_count": availableCount,
  };
}

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    path = json['path'];
    perPage = int.tryParse(json['per_page']?.toString() ?? '0');
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['current_page'] = currentPage;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['path'] = path;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class Delete {
  Delete({
    required this.href,
    required this.method,
  });

  String? href;
  String? method;

  Delete copyWith({
    required String href,
    required String method,
  }) =>
      Delete(
        href: href,
        method: method,
      );

  factory Delete.fromMap(Map<String, dynamic> json) => Delete(
    href: json["href"],
    method: json["method"],
  );

  Map<String, dynamic> toMap() => {
    "href": href,
    "method": method,
  };
}