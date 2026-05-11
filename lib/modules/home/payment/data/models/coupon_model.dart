
class CouponModel {
  final String? success;
  final String? error;
  final List<PaymentSetting>? paymentSettings;

  CouponModel({
    this.success,
    this.error,
    this.paymentSettings,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
    success: json["success"],
    error: json["error"],
    paymentSettings: json["payment_settings"] != null
        ? List<PaymentSetting>.from(
        json["payment_settings"].map((x) => PaymentSetting.fromJson(x)))
        : null,
  );

  bool get visaActive =>
      paymentSettings?.any((p) => p.name?.toLowerCase() == "visa") ?? false;

  bool get cashActive =>
      paymentSettings?.any((p) => p.name?.toLowerCase() == "cash") ?? false;

  bool get pointsActive =>
      paymentSettings?.any((p) => p.name?.toLowerCase() == "points") ?? false;

  bool get madfouActive =>
      paymentSettings?.any((p) => p.name?.toLowerCase() == "madfou") ?? false;

  bool get tamaraActive =>
      paymentSettings?.any((p) => p.name?.toLowerCase() == "tamara") ?? false;

  bool get appleActive =>
      paymentSettings?.any((p) => p.name?.toLowerCase() == "apple") ?? false;

  bool get mispayActive =>
      paymentSettings?.any((p) => p.name?.toLowerCase() == "mispay") ?? false;
}

class PaymentSetting {
  final String? name;

  PaymentSetting({this.name});

  factory PaymentSetting.fromJson(Map<String, dynamic> json) =>
      PaymentSetting(name: json["name"]);
}