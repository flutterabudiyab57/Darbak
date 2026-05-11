class ApplyCashbackResponse {
  final bool success;
  final String message;
  final ApplyCashbackData data;

  ApplyCashbackResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApplyCashbackResponse.fromMap(Map<String, dynamic> map) {
    return ApplyCashbackResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: ApplyCashbackData.fromMap(map['data'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'data': data.toMap(),
    };
  }
}

class ApplyCashbackData {
  // For apply cashback response
  final double? appliedAmount;
  final double? requestedAmount;
  final bool? wasCapped;
  final double? previousAmount;
  final double remainingBalance;
  final double? orderTotal;
  final double? orderBeforeTax;

  // For clear cashback response
  final double? clearedAmount;

  ApplyCashbackData({
    this.appliedAmount,
    this.requestedAmount,
    this.wasCapped,
    this.previousAmount,
    required this.remainingBalance,
    this.orderTotal,
    this.orderBeforeTax,
    this.clearedAmount,
  });

  factory ApplyCashbackData.fromMap(Map<String, dynamic> map) {
    return ApplyCashbackData(
      appliedAmount: _parseDouble(map['applied_amount']),
      requestedAmount: _parseDouble(map['requested_amount']),
      wasCapped: map['was_capped'] as bool?,
      previousAmount: _parseDouble(map['previous_amount']),
      remainingBalance: _parseDouble(map['remaining_balance']) ?? 0.0,
      orderTotal: _parseDouble(map['order_total']),
      orderBeforeTax: _parseDouble(map['order_before_tax']),
      clearedAmount: _parseDouble(map['cleared_amount']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'remaining_balance': remainingBalance,
    };

    if (appliedAmount != null) map['applied_amount'] = appliedAmount;
    if (requestedAmount != null) map['requested_amount'] = requestedAmount;
    if (wasCapped != null) map['was_capped'] = wasCapped;
    if (previousAmount != null) map['previous_amount'] = previousAmount;
    if (orderTotal != null) map['order_total'] = orderTotal;
    if (orderBeforeTax != null) map['order_before_tax'] = orderBeforeTax;
    if (clearedAmount != null) map['cleared_amount'] = clearedAmount;

    return map;
  }

  // Helper getter to check if this is an apply response
  bool get isApplyResponse => appliedAmount != null;

  // Helper getter to check if this is a clear response
  bool get isClearResponse => clearedAmount != null;
}