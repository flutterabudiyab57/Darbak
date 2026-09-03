int _asInt(dynamic value, int fallback) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

/// A tolerant parse of the `{data, links, meta}` envelope.
///
/// Accepts three shapes:
///  - a data-wrapped object with `meta`
///  - a data-wrapped object with no `meta` (the car endpoint) -> single page
///  - a bare JSON list -> single page, total = length
///
/// `links` is not modelled — it is unused, and the car endpoint omits it
/// entirely.
class Paginated<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;

  const Paginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory Paginated.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    if (json is List) {
      final items = json.whereType<Map<String, dynamic>>().map(itemParser).toList();
      return Paginated<T>(
        data: items,
        currentPage: 1,
        lastPage: 1,
        total: items.length,
      );
    }

    if (json is Map<String, dynamic>) {
      final rawData = json['data'];
      final items = rawData is List
          ? rawData.whereType<Map<String, dynamic>>().map(itemParser).toList()
          : <T>[];

      final meta = json['meta'];
      if (meta is Map<String, dynamic>) {
        return Paginated<T>(
          data: items,
          currentPage: _asInt(meta['current_page'], 1),
          lastPage: _asInt(meta['last_page'], 1),
          total: _asInt(meta['total'], items.length),
        );
      }

      return Paginated<T>(
        data: items,
        currentPage: 1,
        lastPage: 1,
        total: items.length,
      );
    }

    return Paginated<T>(data: const [], currentPage: 1, lastPage: 1, total: 0);
  }
}
