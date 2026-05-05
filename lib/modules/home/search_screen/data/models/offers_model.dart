class OffersModel {
  int? id;
  String? name;
  String? description;
  String? from;
  String? to;
  String? coupon;
  int? isWork;
  int? couponIsWork;
  int? discountValue;
  String? image;

  OffersModel({
    this.id,
    this.name,
    this.description,
    this.from,
    this.to,
    this.coupon,
    this.isWork,
    this.couponIsWork,
    this.discountValue,
    this.image,
  });

  factory OffersModel.fromJson(Map<String, dynamic> json) => OffersModel(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    from: json['from'],
    to: json['to'],
    coupon: json['coupon'],
    isWork: json['is_work'],
    couponIsWork: json['coupon_is_work'],
    discountValue: json['discount_value'],
    image: json['image'],
  );
}

class OffersResponse {
  List<OffersModel> data;

  OffersResponse({required this.data});

  factory OffersResponse.fromJson(Map<String, dynamic> json) => OffersResponse(
    data: (json['data'] as List)
        .map((item) => OffersModel.fromJson(item))
        .toList(),
  );
}
