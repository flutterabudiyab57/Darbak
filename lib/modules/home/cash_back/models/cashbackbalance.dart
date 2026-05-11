class CashbackBalance {
  final bool success;
  final BalanceData data;

  CashbackBalance({
    required this.success,
    required this.data,
  });

  factory CashbackBalance.fromMap(Map<String, dynamic> map) {
    return CashbackBalance(
      success: map['success'] ?? false,
      data: BalanceData.fromMap(map['data']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'data': data.toMap(),
    };
  }
}

class BalanceData {
  final double availableBalance;
  final String currency;
  final Summary summary;

  BalanceData({
    required this.availableBalance,
    required this.currency,
    required this.summary,
  });

  factory BalanceData.fromMap(Map<String, dynamic> map) {
    return BalanceData(
      availableBalance: _parseDouble(map['available_balance']) ?? 0.0,
      currency: map['currency'] ?? '',
      summary: Summary.fromMap(map['summary']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'available_balance': availableBalance,
      'currency': currency,
      'summary': summary.toMap(),
    };
  }
}

class Summary {
  final Pending pending;
  final Available available;
  final Used used;
  final Expired expired;

  Summary({
    required this.pending,
    required this.available,
    required this.used,
    required this.expired,
  });

  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      pending: Pending.fromMap(map['pending']),
      available: Available.fromMap(map['available']),
      used: Used.fromMap(map['used']),
      expired: Expired.fromMap(map['expired']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pending': pending.toMap(),
      'available': available.toMap(),
      'used': used.toMap(),
      'expired': expired.toMap(),
    };
  }
}

class Pending {
  final int count;
  final double total;  // Changed from int to double for consistency

  Pending({
    required this.count,
    required this.total,
  });

  factory Pending.fromMap(Map<String, dynamic> map) {
    return Pending(
      count: map['count'] ?? 0,
      total: _parseDouble(map['total']) ?? 0.0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'count': count,
      'total': total,
    };
  }
}

class Available {
  final int count;
  final double total;

  Available({
    required this.count,
    required this.total,
  });

  factory Available.fromMap(Map<String, dynamic> map) {
    return Available(
      count: map['count'] ?? 0,
      total: _parseDouble(map['total']) ?? 0.0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'count': count,
      'total': total,
    };
  }
}

class Used {
  final int count;

  Used({required this.count});

  factory Used.fromMap(Map<String, dynamic> map) {
    return Used(
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'count': count,
    };
  }
}

class Expired {
  final int count;

  Expired({required this.count});

  factory Expired.fromMap(Map<String, dynamic> map) {
    return Expired(
      count: map['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'count': count,
    };
  }
}