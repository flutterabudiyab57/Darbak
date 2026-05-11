

class AllCouponsModel {
  final int id;
  final String name;
  final String discountType;
  final String reservationType;
  final int discountValue;

  AllCouponsModel( {
    required this.id,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.reservationType,
  });

  factory AllCouponsModel.fromJson(Map<String, dynamic> json) {
    return AllCouponsModel(
      id: json['id'] as int,
      name: json['name'] as String,
      discountType: json['discount_type'],
      discountValue: json['discount_value'],
      reservationType: json['reservation_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'discount_type': discountType,
      'discount_value': discountValue,
      'reservation_type': reservationType,
    };
  }
}
