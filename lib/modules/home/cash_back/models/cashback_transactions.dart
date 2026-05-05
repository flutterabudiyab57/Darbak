class CashbackTransactions {
  final bool success;
  final TransactionsData data;

  CashbackTransactions({
    required this.success,
    required this.data,
  });

  factory CashbackTransactions.fromMap(Map<String, dynamic> map) {
    return CashbackTransactions(
      success: map['success'] ?? false,
      data: TransactionsData.fromMap(map['data'] ?? {}),
    );
  }
}

class TransactionsData {
  final List<TransactionEntry> entries;
  final TransactionFilters filters;
  final Pagination pagination;

  TransactionsData({
    required this.entries,
    required this.filters,
    required this.pagination,
  });

  factory TransactionsData.fromMap(Map<String, dynamic> map) {
    return TransactionsData(
      entries: (map['entries'] as List<dynamic>?)
          ?.map((e) => TransactionEntry.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      filters: TransactionFilters.fromMap(map['filters'] ?? {}),
      pagination: Pagination.fromMap(map['pagination'] ?? {}),
    );
  }
}

class TransactionEntry {
  final int id;
  final int recordId;
  final String recordUuid;
  final String recordState;
  final String campaignName;
  final String eventType;
  final String eventLabel;
  final double amount;
  final bool isCredit;
  final String sign;
  final String reference;
  final Map<String, dynamic> meta;
  final String createdAt;
  final String createdAtLocal;
  final String currency;

  TransactionEntry({
    required this.id,
    required this.recordId,
    required this.recordUuid,
    required this.recordState,
    required this.campaignName,
    required this.eventType,
    required this.eventLabel,
    required this.amount,
    required this.isCredit,
    required this.sign,
    required this.reference,
    required this.meta,
    required this.createdAt,
    required this.createdAtLocal,
    required this.currency,
  });

  factory TransactionEntry.fromMap(Map<String, dynamic> map) {
    return TransactionEntry(
      id: map['id'] ?? 0,
      recordId: map['record_id'] ?? 0,
      recordUuid: map['record_uuid'] ?? '',
      recordState: map['record_state'] ?? '',
      campaignName: map['campaign_name'] ?? '',
      eventType: map['event_type'] ?? '',
      eventLabel: map['event_label'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      isCredit: map['is_credit'] ?? false,
      sign: map['sign'] ?? '',
      reference: map['reference'] ?? '',
      meta: map['meta'] ?? {},
      createdAt: map['created_at'] ?? '',
      createdAtLocal: map['created_at_local'] ?? '',
      currency: map['currency'] ?? '',
    );
  }
}

class TransactionFilters {
  final String? eventType;
  final String? recordState;
  final String direction;

  TransactionFilters({
    this.eventType,
    this.recordState,
    required this.direction,
  });

  factory TransactionFilters.fromMap(Map<String, dynamic> map) {
    return TransactionFilters(
      eventType: map['event_type'],
      recordState: map['record_state'],
      direction: map['direction'] ?? 'desc',
    );
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromMap(Map<String, dynamic> map) {
    return Pagination(
      currentPage: map['current_page'] ?? 1,
      lastPage: map['last_page'] ?? 1,
      perPage: map['per_page'] ?? 30,
      total: map['total'] ?? 0,
    );
  }
}