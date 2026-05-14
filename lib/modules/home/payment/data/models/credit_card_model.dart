/// Stable internal identifier for the user-selected payment method.
/// Display strings come from `AppLocalizations` — never compare those against
/// these values. The switch in [CreditCardModel.toJson] is intentionally
/// exhaustive: adding a new method here forces every dispatch site to handle
/// it instead of silently falling back to cash.
enum PaymentMethod {
  visa,
  cash,
  madfou,
  tamara,
  points;

  String get wire => name;

  static PaymentMethod? fromWire(String? value) {
    if (value == null) return null;
    final v = value.toLowerCase().trim();
    for (final m in PaymentMethod.values) {
      if (m.wire == v) return m;
    }
    return null;
  }
}

class CreditCardModel {
  String? orderId;
  String? nameOnCard;
  String? cardNumber;
  dynamic expiryMonth;
  dynamic expiryYear;
  int? securityCode;
  PaymentMethod? paymentType;


  CreditCardModel({
    this.orderId,
    this.nameOnCard,
    this.cardNumber,
    this.expiryMonth,
    this.expiryYear,
    this.securityCode,
    this.paymentType,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) =>
      CreditCardModel(
        orderId: json["order_id"],
        paymentType: PaymentMethod.fromWire(json["payment_type"]),
        nameOnCard: json["nameOnCard"],
        cardNumber: json["CardNumber"],
        expiryMonth: json["expiry_month"],
        expiryYear: json["expiry_year"],
        securityCode: json["securityCode"],
      );

  Map<String, dynamic> toJson() {
    switch (paymentType) {
      case PaymentMethod.visa:
        return toVisaJson();
      case PaymentMethod.cash:
        return toCashJson();
      case PaymentMethod.madfou:
        return toMadfouJson();
      case PaymentMethod.tamara:
        return toTamaraJson();
      case PaymentMethod.points:
        return toPointsJson();
      case null:
        throw StateError(
            'CreditCardModel.toJson called with null paymentType — '
            'caller must set paymentType before submission.');
    }
  }

  Map<String, dynamic> toVisaJson() => {
    "order_id": orderId,
    "payment_type": "visa",
    "nameOnCard": nameOnCard,
    "CardNumber": cardNumber,
    "expiry_month": expiryMonth,
    "expiry_year": expiryYear,
    "securityCode": securityCode,

  };

  Map<String, dynamic> toCashJson() => {
    "order_id": orderId,
    "payment_type": "cash",
  };

  Map<String, dynamic> toMadfouJson() => {
    "order_id": orderId,
    "payment_type": "madfou",
  };

  Map<String, dynamic> toTamaraJson() => {
    "order_id": orderId,
    "payment_type": "tamara",
  };

  Map<String, dynamic> toPointsJson() => {
    "order_id": orderId,
    "payment_type": "points",
  };
}

/// Short-lived buffer for credit-card form input.
/// PCI-DSS req. 3.2.2: CVV must not persist past authorization — every payment
/// submission site MUST call [clear] in a `finally` block.
class CardInput {
  CardInput._();
  static final CardInput instance = CardInput._();

  String? holderName;
  String? number;
  int? cvv;
  int? expiryMonth;
  int? expiryYear;
  bool isValid = false;

  void clear() {
    holderName = null;
    number = null;
    cvv = null;
    expiryMonth = null;
    expiryYear = null;
    isValid = false;
  }
}
