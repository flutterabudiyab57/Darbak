import 'dart:convert';

enum StatusLicence { ACCEPTED, PENDING, DECLINED }

class ProfileModel {
  String? name;
  String? email;
  String? phone;
  int? points;
  String? membershipImageurl;
  Membership? membership;
  String? avatar;
  StatusLicence? stutusLicence;
  String? idNumber;
  String? date;
  String? custClass;
  String? deleteStatus;
  String? user_license;
  CustomerData? customerData;

  ProfileModel({
    this.name,
    this.email,
    this.phone,
    this.points,
    this.membershipImageurl,
    this.membership,
    this.avatar,
    this.stutusLicence,
    this.idNumber,
    this.date,
    this.custClass,
    this.deleteStatus,
    this.user_license,
    this.customerData, // Added to constructor
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'points': points,
      'membership_img': membershipImageurl,
      "membership": membership?.toMap(),
      'avatar': avatar,
      'localed_type': custClass,
      'delete_status': deleteStatus,
      'user_license': user_license,
      'customer_data': customerData?.toMap(), // Added customer_data to map
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    StatusLicence stutusLicence;

    switch (map['new_custmer_request']['is_confirmed']) {
      case "pending":
        stutusLicence = StatusLicence.PENDING;
        break;
      case "rejected":
        stutusLicence = StatusLicence.DECLINED;
        break;
      case "confirmed":
        stutusLicence = StatusLicence.ACCEPTED;
        break;
      default:
        stutusLicence = StatusLicence.PENDING;
    }

    return ProfileModel(
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      points: map['points'],
      membershipImageurl: map['membership']['image'],
      membership: Membership.fromMap(map["membership"]),
      avatar: map['avatar'],
      stutusLicence: stutusLicence,
      idNumber: map['new_custmer_request']['id_number'],
      date: map['Exp_date'],
      custClass: map['cust_class'],
      deleteStatus: map['delete_status'],
      user_license: map['user_license'],
      customerData: map['custmer_data'] != null ? CustomerData.fromMap(map['custmer_data']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source));
}

class Membership {
  Membership({
    required this.id,
    required this.name,
    required this.image,
    required this.rentalDiscount,
    required this.ratioPoints,
    required this.extraHours,
    required this.allowedKilos,
    required this.deliveryDiscountRegions,
    required this.description,
  });

  int? id;
  String? name;
  String? image;
  int? rentalDiscount;
  int? ratioPoints;
  int? extraHours;
  int? allowedKilos;
  int? deliveryDiscountRegions;
  String? description;

  factory Membership.fromMap(Map<String, dynamic> json) => Membership(
    id: json["id"],
    name: json["name"],
    image: json["member_image"],
    rentalDiscount: json["rental_discount"],
    ratioPoints: json["ratio_points"],
    extraHours: json["extra_hours"],
    allowedKilos: json["allowed_Kilos"],
    deliveryDiscountRegions: json["delivery_discount_regions"],
    description: json["description"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "member_image": image,
    "rental_discount": rentalDiscount,
    "ratio_points": ratioPoints,
    "extra_hours": extraHours,
    "allowed_Kilos": allowedKilos,
    "delivery_discount_regions": deliveryDiscountRegions,
    "description": description,
  };
}

// CustomerData class to handle customer_data
class CustomerData {
  int? id;
  String? idNumber;
  String? idExpiryDate;
  String? driverIdExpiryDate;
  String? dateOfBirth;
  String? nationality;
  String? gender;
  String? address;
  String? postBox;
  String? driverNumber;
  String? isConfirmed;
  String? description;

  CustomerData({
    this.id,
    this.idNumber,
    this.idExpiryDate,
    this.driverIdExpiryDate,
    this.dateOfBirth,
    this.nationality,
    this.gender,
    this.address,
    this.postBox,
    this.driverNumber,
    this.isConfirmed,
    this.description,
  });

  factory CustomerData.fromMap(Map<String, dynamic> map) {
    return CustomerData(
      id: map['id'],
      idNumber: map['id_number'],
      idExpiryDate: map['id_expiry_date'],
      driverIdExpiryDate: map['driver_id_expiry_date'],
      dateOfBirth: map['date_of_birth'],
      nationality: map['nationality'],
      gender: map['gender'],
      address: map['address'],
      postBox: map['post_box'],
      driverNumber: map['driver_number'],
      isConfirmed: map['is_confirmed'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_number': idNumber,
      'id_expiry_date': idExpiryDate,
      'driver_id_expiry_date': driverIdExpiryDate,
      'date_of_birth': dateOfBirth,
      'nationality': nationality,
      'gender': gender,
      'address': address,
      'post_box': postBox,
      'driver_number': driverNumber,
      'is_confirmed': isConfirmed,
      'description': description,
    };
  }
}
