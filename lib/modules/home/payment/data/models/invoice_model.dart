// To parse this JSON data, do
//
//     final invoiceModel = invoiceModelFromJson(jsonString);

import 'dart:convert';

InvoiceModel invoiceModelFromJson(String str) =>
    InvoiceModel.fromJson(json.decode(str));

String invoiceModelToJson(InvoiceModel data) => json.encode(data.toJson());

class InvoiceModel {
  InvoiceModel({
    this.referralPoints,
    this.status,
    this.promotionalDiscount,
    this.carDiscount,
    this.total,
    this.generalTotal,
    this.diff,
    this.taxValue,
    this.featuresPrice,
    this.price,
    this.beforeTax,
    this.areaPricing,
    this.areaDiscount,
    this.authorizationFee,
    this.membershipDiscount,
    this.membershipValue,
    this.cashbackDiscount,
    this.cashbackDiscountRequested,
    this.cashbackWasLimited,
    this.forceCashPayment,
    this.cashActive,
    this.visaActive,
    this.madfouActive,
    this.carPrice,
    this.pointsActive,
    this.appleActive,
    this.tamaraActive,
    this.referralPointsActive,
    this.order,
    this.couponValue,
    this.couponData,
    this.pointsValue,
    this.deliveryValue,
    this.cashback,
  });

  String? referralPoints;
  bool? status;
  String? promotionalDiscount;
  dynamic carDiscount;
  String? total;
  String? generalTotal;
  dynamic diff;
  String? taxValue;
  String? featuresPrice;
  dynamic price;
  String? beforeTax;
  String? areaPricing;
  String? areaDiscount;
  dynamic authorizationFee;
  String? membershipDiscount;
  dynamic membershipValue;
  String? cashbackDiscount;
  String? cashbackDiscountRequested;
  bool? cashbackWasLimited;
  bool? forceCashPayment;
  bool? cashActive;
  bool? visaActive;
  bool? madfouActive;
  bool? pointsActive;
  bool? appleActive;
  bool? tamaraActive;
  bool? referralPointsActive;
  Order? order;
  String? couponValue;
  List<dynamic>? couponData;
  String? carPrice;
  String? pointsValue;
  String? deliveryValue;
  Cashback? cashback;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
    referralPoints: json["referral_points"]?.toString(),
    status: json["status"],
    promotionalDiscount: json["promotional_discount"]?.toString(),
    carDiscount: json["car_discount"],
    total: json["total"]?.toString(),
    generalTotal: json["general_total"]?.toString(),
    diff: json["diff"],
    carPrice: json["car_price"]?.toString(),
    taxValue: json["tax_value"]?.toString(),
    featuresPrice: json["features_price"]?.toString(),
    price: json["price"] != null
        ? double.parse(json["price"].toString())
        : null,
    beforeTax: json["before_tax"]?.toString(),
    areaPricing: json["Area_pricing"]?.toString(),
    areaDiscount: json["area_discount"]?.toString(),
    authorizationFee: json["authorization_fee"],
    membershipDiscount: json["membership_discount"]?.toString(),
    membershipValue: json["membership_value"],
    cashbackDiscount: json["cashback_discount"]?.toString(),
    cashbackDiscountRequested: json["cashback_discount_requested"]?.toString(),
    cashbackWasLimited: json["cashback_was_limited"],
    forceCashPayment: json["force_cash_payment"],
    cashActive: json["cash_active"],
    visaActive: json["visa_active"],
    madfouActive: json["madfou_active"],
    pointsActive: json["points_active"],
    appleActive: json["apple_active"],
    tamaraActive: json["tamara_active"],
    referralPointsActive: json["referral_points_active"],
    order: json["order"] != null ? Order.fromJson(json["order"]) : null,
    couponValue: json["coupon_value"]?.toString(),
    couponData: json["coupon_data"] != null
        ? List<dynamic>.from(json["coupon_data"])
        : [],
    pointsValue: json["points_value"]?.toString(),
    deliveryValue: json["delivery_value"]?.toString(),
    cashback: json["cashback"] != null
        ? Cashback.fromJson(json["cashback"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "referral_points": referralPoints,
    "status": status,
    "promotional_discount": promotionalDiscount,
    "car_discount": carDiscount,
    "total": total,
    "general_total": generalTotal,
    "diff": diff,
    "tax_value": taxValue,
    "features_price": featuresPrice,
    "price": price,
    "before_tax": beforeTax,
    "Area_pricing": areaPricing,
    "area_discount": areaDiscount,
    "authorization_fee": authorizationFee,
    "membership_discount": membershipDiscount,
    "membership_value": membershipValue,
    "cashback_discount": cashbackDiscount,
    "cashback_discount_requested": cashbackDiscountRequested,
    "cashback_was_limited": cashbackWasLimited,
    "force_cash_payment": forceCashPayment,
    "cash_active": cashActive,
    "visa_active": visaActive,
    "madfou_active": madfouActive,
    "points_active": pointsActive,
    "apple_active": appleActive,
    "tamara_active": tamaraActive,
    "referral_points_active": referralPointsActive,
    "order": order?.toJson(),
    "coupon_value": couponValue,
    "coupon_data": couponData,
    "points_value": pointsValue,
    "car_price": carPrice,
    "delivery_value": deliveryValue,
    "cashback": cashback?.toJson(),
  };
}

class Cashback {
  Cashback({
    this.eligible,
    this.type,
    this.value,
    this.maxCashbackPerOrder,
    this.expectedCashbackAmount,
    this.campaignName,
    this.campaignId,
    this.availabilityDelayMinutes,
    this.message,
  });

  bool? eligible;
  String? type;
  String? value;
  dynamic maxCashbackPerOrder;
  double? expectedCashbackAmount;
  String? campaignName;
  int? campaignId;
  int? availabilityDelayMinutes;
  String? message;

  factory Cashback.fromJson(Map<String, dynamic> json) => Cashback(
    eligible: json["eligible"],
    type: json["type"],
    value: json["value"]?.toString(),
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

  Map<String, dynamic> toJson() => {
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

class Order {
  Order({
    this.id,
    this.car,
    this.recivingDate,
    this.receiveDate,
    this.deliverDate,
    this.deliverTime,
    this.receiveTime,
    this.deliveryDate,
    this.receivePlace,
    this.deliverPlace,
    this.deliveryValue,
    this.orderAdditions = const [],
    this.additionsData = const [],
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
    this.diff,
    this.step,
    this.features = const [],
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
  String? deliverDate;
  String? receiveTime;
  String? deliverTime;
  String? receivePlace;
  String? deliverPlace;
  dynamic deliveryValue;
  List<OrderAddition> orderAdditions;
  List<AdditionsData> additionsData;
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
  dynamic vatValue;
  dynamic generalTotal;
  dynamic shippingDiscount;
  dynamic paymentType;
  dynamic paymentStatus;
  dynamic price;
  dynamic points;
  dynamic qitafRedeemedAmount;
  dynamic couponDis;
  String? cashbackDiscount;
  List<dynamic>? featuresAdded;
  String? createdAt;
  String? status;
  dynamic visaAmout;
  dynamic deliveryFees;
  String? statusText;
  String? paymentStatment;
  bool? canCancel;
  String? visaaaa;
  dynamic diff;
  dynamic step;
  List<Feature> features;
  bool? cashActive;
  bool? visaActive;
  bool? pointsActive;
  bool? appleActive;
  dynamic kilo;
  String? orderVia;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    car: json["car"] != null ? Car.fromJson(json["car"]) : null,
    receiveDate: json["receive_date"],
    deliverDate: json["deliver_date"],
    receiveTime: json["receive_time"],
    deliverTime: json["deliver_time"],
    deliverPlace: json["deliverPlace"],
    receivePlace: json["receivePlace"],
    deliveryValue: json["delivery_value"],
    orderAdditions: json["order_additions"] != null
        ? List<OrderAddition>.from(
        json["order_additions"].map((x) => OrderAddition.fromMap(x)))
        : [],
    additionsData: json["additions_data"] != null
        ? List<AdditionsData>.from(
        json["additions_data"].map((x) => AdditionsData.fromMap(x)))
        : [],
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
    recivingDate: json["reciving_date"],
    deliveryDate: json["delivery_date"],
    paymentType: json["payment_type"],
    paymentStatus: json["payment_status"],
    price: json["price"],
    points: json["points"],
    qitafRedeemedAmount: json["qitaf_redeemed_amount"],
    couponDis: json["coupon_dis"],
    cashbackDiscount: json["cashback_discount"]?.toString(),
    featuresAdded: json["features_added"] != null
        ? List<dynamic>.from(json["features_added"].map((x) => x))
        : [],
    createdAt: json["created_at"],
    status: json["status"],
    visaAmout: json["visa_amout"],
    deliveryFees: json["delivery_fees"],
    statusText: json["status_text"],
    paymentStatment: json["payment_statment"],
    canCancel: json["can_cancel"],
    visaaaa: json["visaaaa"],
    diff: json["diff"],
    step: json["step"],
    features: json["features"] != null
        ? List<Feature>.from(
        json["features"].map((x) => Feature.fromMap(x)))
        : [],
    cashActive: json["cash_active"],
    visaActive: json["visa_active"],
    pointsActive: json["points_active"],
    appleActive: json["apple_active"],
    kilo: json["kilo"],
    orderVia: json["order_via"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "car": car?.toJson(),
    "receive_date": receiveDate,
    "deliver_date": deliverDate,
    "receive_time": receiveTime,
    "deliver_time": deliverTime,
    "deliverPlace": deliverPlace,
    "receivePlace": receivePlace,
    "delivery_value": deliveryValue,
    "order_additions":
    List<dynamic>.from(orderAdditions.map((x) => x.toMap())),
    "additions_data":
    List<dynamic>.from(additionsData.map((x) => x.toMap())),
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
    "reciving_date": recivingDate,
    "delivery_date": deliveryDate,
    "payment_type": paymentType,
    "payment_status": paymentStatus,
    "price": price,
    "points": points,
    "qitaf_redeemed_amount": qitafRedeemedAmount,
    "coupon_dis": couponDis,
    "cashback_discount": cashbackDiscount,
    "features_added": featuresAdded != null
        ? List<dynamic>.from(featuresAdded!.map((x) => x))
        : [],
    "created_at": createdAt,
    "status": status,
    "visa_amout": visaAmout,
    "delivery_fees": deliveryFees,
    "status_text": statusText,
    "payment_statment": paymentStatment,
    "can_cancel": canCancel,
    "visaaaa": visaaaa,
    "diff": diff,
    "step": step,
    "features": List<dynamic>.from(features.map((x) => x.toMap())),
    "cash_active": cashActive,
    "visa_active": visaActive,
    "points_active": pointsActive,
    "apple_active": appleActive,
    "kilo": kilo,
    "order_via": orderVia,
  };
}

class OrderAddition {
  final String name;
  final int price;

  OrderAddition({required this.name, required this.price});

  factory OrderAddition.fromMap(Map<String, dynamic> json) {
    return OrderAddition(
      name: json["name"],
      price: int.tryParse(json["price"].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    "name": name,
    "price": price,
  };
}

class AdditionsData {
  final int id;
  final String type;
  final Icon icon;
  final String name;
  final String? miniDes;
  final String img;
  final String price;

  AdditionsData({
    required this.id,
    required this.type,
    required this.icon,
    required this.name,
    this.miniDes,
    required this.img,
    required this.price,
  });

  factory AdditionsData.fromMap(Map<String, dynamic> json) {
    return AdditionsData(
      id: json["id"],
      type: json["type"],
      icon: Icon.fromMap(json["icon"]),
      name: json["name"],
      miniDes: json["mini_des"],
      img: json["img"],
      price: json["price"]?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "type": type,
    "icon": icon.toMap(),
    "name": name,
    "mini_des": miniDes,
    "img": img,
    "price": price,
  };
}

class Icon {
  final String name;
  final String type;

  Icon({required this.name, required this.type});

  factory Icon.fromMap(Map<String, dynamic> json) {
    return Icon(
      name: json["name"],
      type: json["type"],
    );
  }

  Map<String, dynamic> toMap() => {
    "name": name,
    "type": type,
  };
}

class Feature {
  final int id;
  final String title;
  final String? subTitle;
  final String price;
  final String img;
  final bool daily;

  Feature({
    required this.id,
    required this.title,
    this.subTitle,
    required this.price,
    required this.img,
    required this.daily,
  });

  factory Feature.fromMap(Map<String, dynamic> json) {
    return Feature(
      id: json["id"],
      title: json["title"],
      subTitle: json["sub_title"],
      price: json["price"]?.toString() ?? '0',
      img: json["img"],
      daily: json["daily"],
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "sub_title": subTitle,
    "price": price,
    "img": img,
    "daily": daily,
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
    this.price1month,
    this.price3month,
    this.price6month,
    this.price12month,
    this.price9month,
    this.priceAfter1month,
    this.priceAfter3month,
    this.priceAfter6month,
    this.priceAfter12month,
    this.priceAfter9month,
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

  dynamic id;
  String? name;
  dynamic model;
  String? fuel;
  dynamic kilo;
  dynamic categoryId;
  String? category;
  String? manufactory;
  dynamic priceBefore;
  dynamic priceAfter;
  dynamic totalPriceBefore;
  dynamic totalPriceAfter;
  dynamic price1month;
  dynamic price3month;
  dynamic price6month;
  dynamic price12month;
  dynamic price9month;
  dynamic priceAfter1month;
  dynamic priceAfter3month;
  dynamic priceAfter6month;
  dynamic priceAfter12month;
  dynamic priceAfter9month;
  dynamic discount;
  dynamic doors;
  dynamic luggage;
  String? transmission;
  bool? isFavorite;
  String? description;
  String? photo;
  List<dynamic>? photos;
  dynamic available;
  List<dynamic>? availableBranches;
  dynamic offer;
  dynamic coupon;

  factory Car.fromJson(Map<String, dynamic> json) => Car(
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
    price1month: json["price_1month"],
    price3month: json["price_3month"],
    price6month: json["price_6month"],
    price12month: json["price_12month"],
    price9month: json["price_9month"],
    priceAfter1month: json["price_after_1month"],
    priceAfter3month: json["price_after_3month"],
    priceAfter6month: json["price_after_6month"],
    priceAfter12month: json["price_after_12month"],
    priceAfter9month: json["price_after_9month"],
    discount: json["discount"],
    doors: json["doors"],
    luggage: json["luggage"],
    transmission: json["transmission"],
    isFavorite: json["is_favorite"],
    description: json["description"],
    photo: json["photo"],
    photos:
    json["photos"] != null ? List<dynamic>.from(json["photos"]) : [],
    available: json["available"],
    availableBranches: json["available_branches"] != null
        ? List<dynamic>.from(json["available_branches"])
        : [],
    offer: json["offer"],
    coupon: json["coupon"],
  );

  Map<String, dynamic> toJson() => {
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
    "price_1month": price1month,
    "price_3month": price3month,
    "price_6month": price6month,
    "price_12month": price12month,
    "price_9month": price9month,
    "price_after_1month": priceAfter1month,
    "price_after_3month": priceAfter3month,
    "price_after_6month": priceAfter6month,
    "price_after_12month": priceAfter12month,
    "price_after_9month": priceAfter9month,
    "discount": discount,
    "doors": doors,
    "luggage": luggage,
    "transmission": transmission,
    "is_favorite": isFavorite,
    "description": description,
    "photo": photo,
    "photos": photos,
    "available": available,
    "available_branches": availableBranches,
    "offer": offer,
    "coupon": coupon,
  };
}