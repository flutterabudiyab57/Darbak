bool _asLocked(dynamic value) {
  if (value == null) return false;
  if (value == 1 || value == '1' || value == true) return true;
  return false;
}

/// A single open/close window. `open`/`close` are raw "HH:mm" strings and may
/// be null — a null half makes the whole window unusable.
class TimeWindow {
  final String? open;
  final String? close;

  const TimeWindow({this.open, this.close});

  factory TimeWindow.fromJson(Map<String, dynamic> json) => TimeWindow(
    open: json['timeopen']?.toString(),
    close: json['timeclose']?.toString(),
  );

  Map<String, dynamic> toJson() => {'timeopen': open, 'timeclose': close};

  /// Minutes since midnight, or null if unparseable.
  int? _minutes(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  bool get isUsable => _minutes(open) != null && _minutes(close) != null;

  /// Whether [minuteOfDay] falls inside this window. Only call when
  /// [isUsable] is true. A window that crosses midnight (close <= open) is
  /// one continuous period, not an empty or inverted one.
  bool contains(int minuteOfDay) {
    final openM = _minutes(open)!;
    final closeM = _minutes(close)!;
    if (closeM > openM) {
      return minuteOfDay >= openM && minuteOfDay < closeM;
    }
    // close <= open: crosses midnight (or open == close, treated as open all day)
    return minuteOfDay >= openM || minuteOfDay < closeM;
  }
}

/// One day's schedule. `afternoon` is parsed from the API's misspelled
/// `afternone` key — read verbatim, named correctly in Dart (FR-036).
class BranchWorkDay {
  final int? period;
  final TimeWindow? morning;
  final TimeWindow? afternoon;
  final bool locked;

  const BranchWorkDay({this.period, this.morning, this.afternoon, this.locked = false});

  factory BranchWorkDay.fromJson(Map<String, dynamic> json) {
    final periodRaw = json['period'];
    return BranchWorkDay(
      period: periodRaw is int
          ? periodRaw
          : (periodRaw is String ? int.tryParse(periodRaw) : null),
      morning: json['morning'] is Map<String, dynamic>
          ? TimeWindow.fromJson(json['morning'])
          : null,
      afternoon: json['afternone'] is Map<String, dynamic>
          ? TimeWindow.fromJson(json['afternone'])
          : null,
      locked: _asLocked(json['lock']),
    );
  }

  /// Usable windows only — one with a null/unparseable half contributes
  /// nothing, while the other window on the same day still applies.
  List<TimeWindow> get usableWindows =>
      [morning, afternoon].whereType<TimeWindow>().where((w) => w.isUsable).toList();

  Map<String, dynamic> toJson() => {
    'period': period,
    'morning': morning?.toJson(),
    'afternone': afternoon?.toJson(),
    'lock': locked ? '1' : '0',
  };
}

/// Parses the `work_time` object. Missing, null, or unparseable input is
/// handled entirely through `isOpenAt`'s fail-open resolution — Constitution
/// Principle IV.
class BranchWorkTime {
  final bool openAllDays;
  final BranchWorkDay? allDays;
  final Map<int, BranchWorkDay> byWeekday;

  const BranchWorkTime({
    required this.openAllDays,
    this.allDays,
    required this.byWeekday,
  });

  static const Map<String, int> _weekdayKeys = {
    'fri': DateTime.friday,
    'sat': DateTime.saturday,
    'sun': DateTime.sunday,
    'mon': DateTime.monday,
    'tue': DateTime.tuesday,
    'wed': DateTime.wednesday,
    'thu': DateTime.thursday,
  };

  /// Returns null if [json] cannot be parsed at all, which `isOpenAt` treats
  /// as "no data" and fails open.
  static BranchWorkTime? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;

    final byWeekday = <int, BranchWorkDay>{};
    for (final entry in _weekdayKeys.entries) {
      final raw = json[entry.key];
      if (raw is Map<String, dynamic>) {
        byWeekday[entry.value] = BranchWorkDay.fromJson(raw);
      }
    }

    final allDaysRaw = json['alldays'];
    final allDays = allDaysRaw is Map<String, dynamic> ? BranchWorkDay.fromJson(allDaysRaw) : null;

    final openAllDaysRaw = json['openAllDays'];
    final openAllDays = openAllDaysRaw == 1 || openAllDaysRaw == '1' || openAllDaysRaw == true;

    return BranchWorkTime(openAllDays: openAllDays, allDays: allDays, byWeekday: byWeekday);
  }

  /// Round-trips back to the original `work_time` JSON shape, so caching a
  /// parsed [Branch] and re-parsing it later is lossless.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'openAllDays': openAllDays ? '1' : '0'};
    if (allDays != null) json['alldays'] = allDays!.toJson();
    for (final entry in _weekdayKeys.entries) {
      final day = byWeekday[entry.value];
      if (day != null) json[entry.key] = day.toJson();
    }
    return json;
  }

  /// Resolution order (data-model.md#branchworktime):
  /// 1. workTime == null -> true
  /// 2. resolve the day (byWeekday, falling back to allDays); no entry -> true
  /// 3. day locked -> false
  /// 4. collect usable windows; discard null/unparseable halves
  /// 5. no usable window -> true (fail open, regardless of openAllDays)
  /// 6. otherwise -> true iff dt's time-of-day falls inside a surviving window
  bool isOpenAt(DateTime dt) {
    final day = byWeekday[dt.weekday] ?? allDays;
    if (day == null) return true;
    if (day.locked) return false;

    final windows = day.usableWindows;
    if (windows.isEmpty) return true;

    final minuteOfDay = dt.hour * 60 + dt.minute;
    return windows.any((w) => w.contains(minuteOfDay));
  }
}
