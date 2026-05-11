import 'package:darbak/modules/home/cars/data/models/cars_model.dart';

class OfferModel {
  final int id;
  final String name;
  final String from;
  final String to;
  final String image;
  final String description;
  final String coupon;
  final int discountValue;
  final int couponIsWork;
  final List<DataCars> cars;
  final List<Branch> branches;

  OfferModel(

      {required this.description,
      required this.image,
      required this.coupon,
      required this.id,
      required this.name,
      required this.from,
      required this.to,
      required this.discountValue,
      required this.cars,
      required this.branches,
        required this.couponIsWork,});

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      from: json['from'],
      description: json['description'],
      coupon: json['coupon'],
      couponIsWork: json['coupon_is_work'],
      to: json['to'],
      discountValue: json['discount_value'],
      cars: List<DataCars>.from(json['cars'].map((x) => DataCars.fromMap(x))),
      branches: json['branches'] != null
          ? List<Branch>.from(json['branches'].map((x) => Branch.fromJson(x)))
          : [],
    );
  }
}

class Car {
  final int id;
  final String name;
  final int model;
  final String fuel;
  final int kilo;
  final int categoryId;
  final String category;
  final String manufactory;
  final double priceBefore;
  final double priceAfter;
  final double discount;
  final int doors;
  final int luggage;
  final String transmission;
  final String imageUrl;

  Car({
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
    required this.discount,
    required this.doors,
    required this.luggage,
    required this.transmission,
    required this.imageUrl,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'],
      name: json['name'],
      model: json['model'],
      fuel: json['fuel'],
      kilo: json['kilo'],
      categoryId: json['category_id'],
      category: json['category'],
      manufactory: json['manufactory'],
      priceBefore: (json['price_before'] ?? 0).toDouble(),
      priceAfter: (json['price_after'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      doors: json['doors'],
      luggage: json['luggage'],
      transmission: json['transmission'],
      imageUrl: json['photo'] ?? '',
    );
  }
}

class WorkTime {
  final String period;
  final TimePeriod morning;
  final TimePeriod afternoon;
  final bool isLocked;

  WorkTime({
    required this.period,
    required this.morning,
    required this.afternoon,
    required this.isLocked,
  });

  factory WorkTime.fromJson(Map<String, dynamic> json) {
    return WorkTime(
      period: json['period'],
      morning: TimePeriod.fromJson(json['morning']),
      afternoon: TimePeriod.fromJson(json['afternone']),
      isLocked: json['lock'] == "1",
    );
  }
}

class TimePeriod {
  final String? timeOpen;
  final String? timeClose;

  TimePeriod({
    this.timeOpen,
    this.timeClose,
  });

  factory TimePeriod.fromJson(Map<String, dynamic> json) {
    return TimePeriod(
      timeOpen: json['timeopen'],
      timeClose: json['timeclose'],
    );
  }
}

class Branch {
  final int id;
  final String name;
  final String region;
  final int regionId;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String locationUrl;
  final Map<String, WorkTime> workTime;
  final bool bookToday;

  Branch({
    required this.id,
    required this.name,
    required this.region,
    required this.regionId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.locationUrl,
    required this.workTime,
    required this.bookToday,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    Map<String, WorkTime> parsedWorkTime = {};
    if (json['work_time'] != null) {
      json['work_time'].forEach((day, schedule) {
        parsedWorkTime[day] = WorkTime.fromJson(schedule);
      });
    }

    return Branch(
      id: json['id'],
      name: json['name'],
      region: json['region'],
      regionId: json['region_id'],
      address: json['address'],
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['long']),
      phone: json['phone'],
      locationUrl: json['location_url'],
      workTime: parsedWorkTime,
      bookToday: json['book_today'] == 1,
    );
  }
}
