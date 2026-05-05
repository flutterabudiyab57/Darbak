
class CreditCardModel {
  String? orderId;
  String? nameOnCard;
  String? cardNumber;
  dynamic expiryMonth;
  dynamic expiryYear;
  int? securityCode;
  String? paymentType;


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
        paymentType: json["payment_type"],
        nameOnCard: json["nameOnCard"],
        cardNumber: json["CardNumber"],
        expiryMonth: json["expiry_month"],
        expiryYear: json["expiry_year"],
        securityCode: json["securityCode"],
      );

  Map<String, dynamic> toJson() {
    final json;

    print("toJson paymentType ${paymentType}");

    switch (paymentType) {
      case "visa":
        json = toVisaJson();
        break;
      case "بطاقة إئتمان":
        json = toVisaJson();
        break;
      case "cash":
        json = toCashJson();
        break;
      case "نقدي":
        json = toCashJson();
        break;
      case "madfou":
        json = toMadfouJson();
        print("paymentType madfou: ${paymentType}");
        break;
      case "مدفوع":
        json = toMadfouJson();
        print("paymentType مدفوع: ${paymentType}");
        break;
      case "tamara":
        json = toTamaraJson();
        print("paymentType tamara: ${paymentType}");
        break;
      case "تمارا":
        json = toTamaraJson();
        print("paymentType تمارا: ${paymentType}");
        break;
      case "points":
        json = toPointsJson();
        break;
      case "نقاط":
        json = toPointsJson();
        break;
      default:
        json = toCashJson();
        print("paymentType model1: ${paymentType}");
        break;
    }

    return json;


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
