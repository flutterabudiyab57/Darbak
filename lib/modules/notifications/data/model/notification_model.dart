// PROVISIONAL — replace when real API JSON arrives.
//
// The UI and cubit consume the CLEAN view-models below (`NotificationItem`,
// `NotificationsPage`). Only the `fromJson` adapters in this file should need to
// change when the real backend shape lands — keep the constructors/fields stable.
//
// Every field defaults defensively (`??`, `tryParse ?? now`) so a different real
// shape can never crash parsing.

/// One notification as the UI consumes it. Backend-shape-agnostic.
class NotificationItem {
  final int id;

  /// Raw backend type string (e.g. "cashback", "booking", "offer", "update").
  /// Mapping to icon/color/route happens at the edges, not here.
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  /// Free-form payload the backend may attach (deep-link ids, etc.). Kept raw
  /// so the routing function can read whatever it needs without a schema change.
  final Map<String, dynamic> data;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        data: data,
      );

  // PROVISIONAL adapter — assumes:
  // { id, type, title, body, is_read, created_at(ISO8601), data:{} }
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: _asInt(json['id']),
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['message'] ?? '').toString(),
      isRead: _asBool(json['is_read'] ?? json['read'] ?? json['read_at']),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString())?.toLocal() ??
              DateTime.now(),
      data: (json['data'] is Map)
          ? Map<String, dynamic>.from(json['data'] as Map)
          : const {},
    );
  }
}

/// One page of notifications + pagination meta.
class NotificationsPage {
  final List<NotificationItem> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const NotificationsPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;

  // PROVISIONAL adapter — assumes { data: [...], meta: { current_page,
  // per_page, last_page, total } }. Falls back gracefully if `meta` is absent.
  factory NotificationsPage.fromJson(Map<String, dynamic> json) {
    final rawList = (json['data'] is List) ? json['data'] as List : const [];
    final items = rawList
        .whereType<Map>()
        .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final meta = (json['meta'] is Map)
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : const <String, dynamic>{};

    final current = _asInt(meta['current_page'], fallback: 1);
    final perPage = _asInt(meta['per_page'], fallback: items.length);
    final total = _asInt(meta['total'], fallback: items.length);
    // If `last_page` is missing, treat the current page as the last one so we
    // never request a non-existent page.
    final last = _asInt(meta['last_page'], fallback: current);

    return NotificationsPage(
      items: items,
      currentPage: current,
      lastPage: last,
      perPage: perPage,
      total: total,
    );
  }
}

int _asInt(dynamic v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v?.toString().toLowerCase();
  if (s == null || s.isEmpty || s == 'null') return false;
  // A non-null `read_at` timestamp means it's read.
  if (s == 'false' || s == '0') return false;
  return true;
}
