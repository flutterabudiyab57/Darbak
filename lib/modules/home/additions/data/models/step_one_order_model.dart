import 'dart:convert';

StepOneOrderModel stepOneOrderModelFromMap(String str) =>
    StepOneOrderModel.fromMap(json.decode(str) as Map<String, dynamic>);

String stepOneOrderModelToMap(StepOneOrderModel data) =>
    json.encode(data.toMap());

class StepOneOrderModel {
  StepOneOrderModel({
    this.status,
    this.order,
    this.diff,
    this.features,
    this.cashActive,
    this.pointsActive,
    this.visaActive,
    this.tamaraActive,
    this.madfouActive,
    this.appleActive,
    this.mispayActive,
    this.cashback,
  });

  bool? status;
  Order? order;
  bool? visaActive;
  bool? madfouActive;
  bool? tamaraActive;
  bool? cashActive;
  bool? pointsActive;
  bool? appleActive;
  bool? mispayActive;
  int? diff;
  List<Feature?>? features;
  Cashback? cashback;

  factory StepOneOrderModel.fromMap(Map<String, dynamic> json) =>
      StepOneOrderModel(
        status: json["status"],
        cashActive: json["cash_active"],
        visaActive: json["visa_active"],
        madfouActive: json["madfou_active"],
        tamaraActive: json["tamara_active"],
        pointsActive: json["points_active"],
        appleActive: json["apple_active"],
        mispayActive: json["mispay_active"],
        diff: json["diff"],
        order: json["order"] != null ? Order.fromMap(json["order"]) : null,
        features: json["features"] != null
            ? List<Feature>.from(json["features"].map((x) => Feature.fromMap(x)))
            : null,
        cashback: json["cashback"] != null
            ? Cashback.fromMap(json["cashback"])
            : null,
      );

  Map<String, dynamic> toMap() => {
    "status": status,
    "visa_active": visaActive,
    "madfou_active": madfouActive,
    "cash_active": cashActive,
    "tamara_active": tamaraActive,
    "points_active": pointsActive,
    "apple_active": appleActive,
    "mispay_active": mispayActive,
    "diff": diff,
    "order": order?.toMap(),
    "features": features != null
        ? List<dynamic>.from(features!.map((x) => x?.toMap()))
        : null,
    "cashback": cashback?.toMap(),
  };
}

class Feature {
  Feature({
    this.id,
    this.title,
    this.subTitle,
    this.price,
    this.img,
    this.daily,
  });

  int? id;
  String? title;
  dynamic subTitle;
  String? price;
  String? img;
  bool? daily;

  factory Feature.fromMap(Map<String, dynamic> json) => Feature(
    id: json["id"],
    title: json["title"],
    subTitle: json["sub_title"],
    price: json["price"]?.toString(),
    img: json["img"],
    daily: json["daily"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "sub_title": subTitle,
    "price": price,
    "img": img,
    "daily": daily,
  };
}

class Order {
  Order({
    this.id,
    this.car,
    this.recivingDate,
    this.deliveryDate,
    this.receiveDate,
    this.receiveTime,
    this.deliverDate,
    this.deliverTime,
    this.deliveryValue,
    this.orderAdditions,
    this.additionsData,
    this.rentPrice,
    this.additions,
    this.tammPrice,
    this.total,
    this.beforeTax,
    this.taxValue,
    this.membershipDiscount,
    this.promotionalDiscount,
    this.carDiscount,
    this.netPrice,
    this.vatValue,
    this.generalTotal,
    this.shippingDiscount,
    this.paymentType,
    this.paymentStatus,
    this.price,
    this.points,
    this.qitafRedeemedAmount,
    this.couponDis,
    this.cashbackDiscount,
    this.featuresAdded,
    this.createdAt,
    this.status,
    this.visaAmout,
    this.deliveryFees,
    this.statusText,
    this.paymentStatment,
    this.canCancel,
    this.visaaaa,
    this.receivePlace,
    this.deliverPlace,
    this.diff,
    this.step,
    this.features,
    this.cashActive,
    this.visaActive,
    this.pointsActive,
    this.appleActive,
    this.kilo,
    this.orderVia,
  });

  int? id;
  Car? car;
  String? recivingDate;
  String? deliveryDate;
  String? receiveDate;
  String? receiveTime;
  String? deliverDate;
  String? deliverTime;
  dynamic deliveryValue;
  List<dynamic>? orderAdditions;
  List<AdditionData?>? additionsData;
  dynamic rentPrice;
  dynamic additions;
  dynamic tammPrice;
  dynamic total;
  dynamic beforeTax;
  dynamic taxValue;
  dynamic membershipDiscount;
  dynamic promotionalDiscount;
  dynamic carDiscount;
  dynamic netPrice;
  String? vatValue;
  String? generalTotal;
  dynamic shippingDiscount;
  dynamic paymentType;
  dynamic paymentStatus;
  dynamic price;
  dynamic points;
  dynamic qitafRedeemedAmount;
  dynamic couponDis;
  dynamic cashbackDiscount;
  dynamic featuresAdded;
  String? createdAt;
  String? status;
  String? visaAmout;
  dynamic deliveryFees;
  String? statusText;
  String? paymentStatment;
  bool? canCancel;
  String? visaaaa;
  String? receivePlace;
  String? deliverPlace;
  int? diff;
  int? step;
  List<Feature?>? features;
  bool? cashActive;
  bool? visaActive;
  bool? pointsActive;
  bool? appleActive;
  dynamic kilo;
  String? orderVia;

  factory Order.fromMap(Map<String, dynamic> json) => Order(
    id: json["id"],
    car: json["car"] != null ? Car.fromMap(json["car"]) : null,
    recivingDate: json["reciving_date"],
    deliveryDate: json["delivery_date"],
    receiveDate: json["receive_date"],
    receiveTime: json["receive_time"],
    deliverDate: json["deliver_date"],
    deliverTime: json["deliver_time"],
    deliveryValue: json["delivery_value"],
    orderAdditions: json["order_additions"] != null
        ? List<dynamic>.from(json["order_additions"])
        : null,
    additionsData: json["additions_data"] != null
        ? List<AdditionData>.from(
        json["additions_data"].map((x) => AdditionData.fromMap(x)))
        : null,
    rentPrice: json["rent_price"],
    additions: json["additions"],
    tammPrice: json["tamm_price"],
    total: json["total"],
    beforeTax: json["before_tax"],
    taxValue: json["tax_value"],
    membershipDiscount: json["membership_discount"],
    promotionalDiscount: json["promotional_discount"],
    carDiscount: json["car_discount"],
    netPrice: json["net_price"],
    vatValue: json["vat_value"],
    generalTotal: json["general_total"],
    shippingDiscount: json["shipping_discount"],
    paymentType: json["payment_type"],
    paymentStatus: json["payment_status"],
    price: json["price"],
    points: json["points"],
    qitafRedeemedAmount: json["qitaf_redeemed_amount"],
    couponDis: json["coupon_dis"],
    cashbackDiscount: json["cashback_discount"],
    featuresAdded: json["features_added"],
    createdAt: json["created_at"],
    status: json["status"],
    visaAmout: json["visa_amout"],
    deliveryFees: json["delivery_fees"],
    statusText: json["status_text"],
    paymentStatment: json["payment_statment"],
    canCancel: json["can_cancel"],
    visaaaa: json["visaaaa"],
    receivePlace: json["receivePlace"],
    deliverPlace: json["deliverPlace"],
    diff: json["diff"],
    step: json["step"],
    features: json["features"] != null
        ? List<Feature>.from(json["features"].map((x) => Feature.fromMap(x)))
        : null,
    cashActive: json["cash_active"],
    visaActive: json["visa_active"],
    pointsActive: json["points_active"],
    appleActive: json["apple_active"],
    kilo: json["kilo"],
    orderVia: json["order_via"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "car": car?.toMap(),
    "reciving_date": recivingDate,
    "delivery_date": deliveryDate,
    "receive_date": receiveDate,
    "receive_time": receiveTime,
    "deliver_date": deliverDate,
    "deliver_time": deliverTime,
    "delivery_value": deliveryValue,
    "order_additions": orderAdditions,
    "additions_data": additionsData != null
        ? List<dynamic>.from(additionsData!.map((x) => x?.toMap()))
        : null,
    "rent_price": rentPrice,
    "additions": additions,
    "tamm_price": tammPrice,
    "total": total,
    "before_tax": beforeTax,
    "tax_value": taxValue,
    "membership_discount": membershipDiscount,
    "promotional_discount": promotionalDiscount,
    "car_discount": carDiscount,
    "net_price": netPrice,
    "vat_value": vatValue,
    "general_total": generalTotal,
    "shipping_discount": shippingDiscount,
    "payment_type": paymentType,
    "payment_status": paymentStatus,
    "price": price,
    "points": points,
    "qitaf_redeemed_amount": qitafRedeemedAmount,
    "coupon_dis": couponDis,
    "cashback_discount": cashbackDiscount,
    "features_added": featuresAdded,
    "created_at": createdAt,
    "status": status,
    "visa_amout": visaAmout,
    "delivery_fees": deliveryFees,
    "status_text": statusText,
    "payment_statment": paymentStatment,
    "can_cancel": canCancel,
    "visaaaa": visaaaa,
    "receivePlace": receivePlace,
    "deliverPlace": deliverPlace,
    "diff": diff,
    "step": step,
    "features": features != null
        ? List<dynamic>.from(features!.map((x) => x?.toMap()))
        : null,
    "cash_active": cashActive,
    "visa_active": visaActive,
    "points_active": pointsActive,
    "apple_active": appleActive,
    "kilo": kilo,
    "order_via": orderVia,
  };
}

class AdditionData {
  AdditionData({
    this.id,
    this.type,
    this.icon,
    this.name,
    this.miniDes,
    this.img,
    this.price,
  });

  int? id;
  String? type;
  Icon? icon;
  String? name;
  dynamic miniDes;
  String? img;
  String? price;

  factory AdditionData.fromMap(Map<String, dynamic> json) => AdditionData(
    id: json["id"],
    type: json["type"],
    icon: json["icon"] != null ? Icon.fromMap(json["icon"]) : null,
    name: json["name"],
    miniDes: json["mini_des"],
    img: json["img"],
    price: json["price"]?.toString(),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "type": type,
    "icon": icon?.toMap(),
    "name": name,
    "mini_des": miniDes,
    "img": img,
    "price": price,
  };
}

class Icon {
  Icon({
    this.name,
    this.type,
  });

  String? name;
  String? type;

  factory Icon.fromMap(Map<String, dynamic> json) => Icon(
    name: json["name"],
    type: json["type"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "type": type,
  };
}

class Car {
  Car({
    this.id,
    this.name,
    this.model,
    this.fuel,
    this.kilo,
    this.categoryId,
    this.category,
    this.manufactory,
    this.priceBefore,
    this.priceAfter,
    this.totalPriceBefore,
    this.totalPriceAfter,
    this.price1Month,
    this.price3Month,
    this.price6Month,
    this.price12Month,
    this.price9Month,
    this.priceAfter1Month,
    this.priceAfter3Month,
    this.priceAfter6Month,
    this.priceAfter12Month,
    this.priceAfter9Month,
    this.discount,
    this.doors,
    this.luggage,
    this.transmission,
    this.isFavorite,
    this.description,
    this.photo,
    this.photos,
    this.available,
    this.availableBranches,
    this.offer,
    this.coupon,
  });

  int? id;
  String? name;
  int? model;
  String? fuel;
  dynamic kilo;
  int? categoryId;
  String? category;
  String? manufactory;
  num? priceBefore;
  num? priceAfter;
  num? totalPriceBefore;
  num? totalPriceAfter;
  num? price1Month;
  num? price3Month;
  num? price6Month;
  num? price12Month;
  num? price9Month;
  num? priceAfter1Month;
  num? priceAfter3Month;
  num? priceAfter6Month;
  num? priceAfter12Month;
  num? priceAfter9Month;
  int? discount;
  int? doors;
  int? luggage;
  String? transmission;
  bool? isFavorite;
  String? description;
  String? photo;
  List<Photo?>? photos;
  dynamic available;
  List<AvailableBranch?>? availableBranches;
  int? offer;
  dynamic coupon;

  factory Car.fromMap(Map<String, dynamic> json) => Car(
    id: json["id"],
    name: json["name"],
    model: json["model"],
    fuel: json["fuel"],
    kilo: json["kilo"],
    categoryId: json["category_id"],
    category: json["category"],
    manufactory: json["manufactory"],
    priceBefore: json["price_before"],
    priceAfter: json["price_after"],
    totalPriceBefore: json["total_price_before"],
    totalPriceAfter: json["total_price_after"],
    price1Month: json["price_1month"],
    price3Month: json["price_3month"],
    price6Month: json["price_6month"],
    price12Month: json["price_12month"],
    price9Month: json["price_9month"],
    priceAfter1Month: json["price_after_1month"],
    priceAfter3Month: json["price_after_3month"],
    priceAfter6Month: json["price_after_6month"],
    priceAfter12Month: json["price_after_12month"],
    priceAfter9Month: json["price_after_9month"],
    discount: json["discount"],
    doors: json["doors"],
    luggage: json["luggage"],
    transmission: json["transmission"],
    isFavorite: json["is_favorite"],
    description: json["description"],
    photo: json["photo"],
    photos: json["photos"] != null
        ? List<Photo>.from(json["photos"].map((x) => Photo.fromMap(x)))
        : null,
    available: json["available"],
    availableBranches: json["available_branches"] != null
        ? List<AvailableBranch>.from(
        json["available_branches"].map((x) => AvailableBranch.fromMap(x)))
        : null,
    offer: json["offer"],
    coupon: json["coupon"],
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
    "price_before": priceBefore,
    "price_after": priceAfter,
    "total_price_before": totalPriceBefore,
    "total_price_after": totalPriceAfter,
    "price_1month": price1Month,
    "price_3month": price3Month,
    "price_6month": price6Month,
    "price_12month": price12Month,
    "price_9month": price9Month,
    "price_after_1month": priceAfter1Month,
    "price_after_3month": priceAfter3Month,
    "price_after_6month": priceAfter6Month,
    "price_after_12month": priceAfter12Month,
    "price_after_9month": priceAfter9Month,
    "discount": discount,
    "doors": doors,
    "luggage": luggage,
    "transmission": transmission,
    "is_favorite": isFavorite,
    "description": description,
    "photo": photo,
    "photos": photos != null
        ? List<dynamic>.from(photos!.map((x) => x?.toMap()))
        : null,
    "available": available,
    "available_branches": availableBranches != null
        ? List<dynamic>.from(availableBranches!.map((x) => x?.toMap()))
        : null,
    "offer": offer,
    "coupon": coupon,
  };
}

class AvailableBranch {
  AvailableBranch({
    this.id,
    this.text,
    this.image,
    this.canBookToday,
  });

  int? id;
  String? text;
  String? image;
  int? canBookToday;

  factory AvailableBranch.fromMap(Map<String, dynamic> json) =>
      AvailableBranch(
        id: json["id"],
        text: json["text"],
        image: json["image"],
        canBookToday: json["can_book_today"],
      );

  Map<String, dynamic> toMap() => {
    "id": id,
    "text": text,
    "image": image,
    "can_book_today": canBookToday,
  };
}

class Photo {
  Photo({
    this.id,
    this.url,
    this.preview,
    this.name,
    this.fileName,
    this.type,
    this.mimeType,
    this.size,
    this.humanReadableSize,
    this.details,
    this.status,
    this.progress,
    this.links,
  });

  int? id;
  String? url;
  String? preview;
  String? name;
  String? fileName;
  String? type;
  String? mimeType;
  int? size;
  String? humanReadableSize;
  Details? details;
  dynamic status;
  dynamic progress;
  Links? links;

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
    details: json["details"] != null
        ? Details.fromMap(json["details"])
        : null,
    status: json["status"],
    progress: json["progress"],
    links: json["links"] != null ? Links.fromMap(json["links"]) : null,
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
    "links": links?.toMap(),
  };
}

class Details {
  Details({
    this.width,
    this.height,
    this.ratio,
  });

  dynamic width;
  dynamic height;
  dynamic ratio;

  factory Details.fromMap(Map<String, dynamic> json) => Details(
    width: json["width"],
    height: json["height"],
    ratio: json["ratio"],
  );

  Map<String, dynamic> toMap() => {
    "width": width,
    "height": height,
    "ratio": ratio,
  };
}

class Links {
  Links({
    this.delete,
  });

  Delete? delete;

  factory Links.fromMap(Map<String, dynamic> json) => Links(
    delete: json["delete"] != null ? Delete.fromMap(json["delete"]) : null,
  );

  Map<String, dynamic> toMap() => {
    "delete": delete?.toMap(),
  };
}

class Delete {
  Delete({
    this.href,
    this.method,
  });

  String? href;
  String? method;

  factory Delete.fromMap(Map<String, dynamic> json) => Delete(
    href: json["href"],
    method: json["method"],
  );

  Map<String, dynamic> toMap() => {
    "href": href,
    "method": method,
  };
}

class Cashback {
  Cashback({
    this.eligible,
    this.type,
    this.value,
    this.maxCashbackPerOrder,
    this.expectedCashbackAmount,  // إضافة الحقل الجديد
    this.campaignName,
    this.campaignId,
    this.availabilityDelayMinutes,
    this.message,
  });

  bool? eligible;
  String? type;
  String? value;
  dynamic maxCashbackPerOrder;
  double? expectedCashbackAmount;  // الحقل الجديد
  String? campaignName;
  int? campaignId;
  int? availabilityDelayMinutes;
  String? message;

  factory Cashback.fromMap(Map<String, dynamic> json) => Cashback(
    eligible: json["eligible"],
    type: json["type"],
    value: json["value"],
    maxCashbackPerOrder: json["max_cashback_per_order"],
    expectedCashbackAmount: json["expected_cashback_amount"] != null
        ? (json["expected_cashback_amount"] is int
        ? (json["expected_cashback_amount"] as int).toDouble()
        : json["expected_cashback_amount"].toDouble())
        : null,
    campaignName: json["campaign_name"],
    campaignId: json["campaign_id"],
    availabilityDelayMinutes: json["availability_delay_minutes"],
    message: json["message"],
  );

  Map<String, dynamic> toMap() => {
    "eligible": eligible,
    "type": type,
    "value": value,
    "max_cashback_per_order": maxCashbackPerOrder,
    "expected_cashback_amount": expectedCashbackAmount,
    "campaign_name": campaignName,
    "campaign_id": campaignId,
    "availability_delay_minutes": availabilityDelayMinutes,
    "message": message,
  };
}