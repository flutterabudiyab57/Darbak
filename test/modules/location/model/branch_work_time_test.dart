import 'package:darbak/modules/location/data/models/branch_work_time.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeWindow.contains', () {
    test('a normal window contains times inside it and excludes times outside', () {
      const window = TimeWindow(open: '09:00', close: '17:00');
      expect(window.contains(9 * 60), isTrue); // 09:00, inclusive
      expect(window.contains(12 * 60), isTrue);
      expect(window.contains(17 * 60), isFalse); // 17:00, exclusive
      expect(window.contains(8 * 60 + 59), isFalse);
    });

    test('a midnight-crossing window (21:00-03:00) is one continuous period', () {
      const window = TimeWindow(open: '21:00', close: '03:00');
      expect(window.contains(22 * 60), isTrue); // 22:00
      expect(window.contains(0), isTrue); // 00:00
      expect(window.contains(2 * 60), isTrue); // 02:00
      expect(window.contains(3 * 60), isFalse); // 03:00, exclusive
      expect(window.contains(12 * 60), isFalse); // 12:00, clearly outside
    });

    test('open == close is treated as open all day', () {
      const window = TimeWindow(open: '00:00', close: '00:00');
      expect(window.contains(0), isTrue);
      expect(window.contains(12 * 60), isTrue);
      expect(window.contains(23 * 60 + 59), isTrue);
    });
  });

  group('BranchWorkDay.usableWindows', () {
    test('null/unparseable timeopen discards only that window, the other still applies', () {
      final day = BranchWorkDay.fromJson({
        'morning': {'timeopen': null, 'timeclose': '12:00'},
        'afternone': {'timeopen': '14:00', 'timeclose': '22:00'},
      });

      expect(day.usableWindows.length, 1);
      expect(day.usableWindows.single.open, '14:00');
    });

    test('afternone is the key read, exposed as afternoon', () {
      final day = BranchWorkDay.fromJson({
        'afternone': {'timeopen': '14:00', 'timeclose': '22:00'},
      });

      expect(day.afternoon, isNotNull);
      expect(day.afternoon!.open, '14:00');
      expect(day.afternoon!.close, '22:00');
    });
  });

  group('BranchWorkTime.isOpenAt', () {
    test('explicit lock:"1" makes the day closed regardless of windows', () {
      final workTime = BranchWorkTime.tryParse({
        'mon': {
          'morning': {'timeopen': '09:00', 'timeclose': '17:00'},
          'lock': '1',
        },
      });

      // 2026-09-07 is a Monday.
      final noon = DateTime(2026, 9, 7, 12, 0);
      expect(workTime!.isOpenAt(noon), isFalse);
    });

    test('a missing day with no alldays fallback fails open (true)', () {
      final workTime = BranchWorkTime.tryParse({
        'tue': {
          'morning': {'timeopen': '09:00', 'timeclose': '17:00'},
        },
      });

      // 2026-09-07 is a Monday, not present, and no 'alldays' key given.
      final monday = DateTime(2026, 9, 7, 12, 0);
      expect(workTime!.isOpenAt(monday), isTrue);
    });

    test('entirely absent or malformed work_time fails open (true)', () {
      expect(BranchWorkTime.tryParse(null), isNull);
      expect(BranchWorkTime.tryParse('not a map'), isNull);
      expect(BranchWorkTime.tryParse(42), isNull);
      // Callers apply: workTime?.isOpenAt(dt) ?? true
      expect(BranchWorkTime.tryParse(null)?.isOpenAt(DateTime.now()) ?? true, isTrue);
    });

    test('a day with only unusable windows fails open (true)', () {
      final workTime = BranchWorkTime.tryParse({
        'mon': {
          'morning': {'timeopen': null, 'timeclose': null},
        },
      });

      final monday = DateTime(2026, 9, 7, 12, 0);
      expect(workTime!.isOpenAt(monday), isTrue);
    });

    test('resolves against the matched weekday window', () {
      final workTime = BranchWorkTime.tryParse({
        'mon': {
          'morning': {'timeopen': '09:00', 'timeclose': '17:00'},
        },
      });

      final insideWindow = DateTime(2026, 9, 7, 10, 0); // Monday 10:00
      final outsideWindow = DateTime(2026, 9, 7, 20, 0); // Monday 20:00
      expect(workTime!.isOpenAt(insideWindow), isTrue);
      expect(workTime.isOpenAt(outsideWindow), isFalse);
    });
  });

  group('BranchWorkTime round-trip (toJson -> fromJson is lossless)', () {
    // Guards against toJson writing a key that fromJson does not read (e.g.
    // "afternoon" instead of the API's "afternone"), which would silently
    // drop working hours on every cache hit and fail open (Principle IV) —
    // but only sometimes, depending on whether the answer came from cache.
    final payload = {
      'openAllDays': '0',
      'mon': {
        'morning': {'timeopen': '09:00', 'timeclose': '13:00'},
        'afternone': {'timeopen': '14:00', 'timeclose': '22:00'},
        'lock': '0',
      },
      'fri': {
        'lock': '1',
      },
      // Midnight-crossing window on Saturday.
      'sat': {
        'morning': {'timeopen': '21:00', 'timeclose': '03:00'},
        'lock': '0',
      },
      'alldays': {
        'morning': {'timeopen': '10:00', 'timeclose': '18:00'},
      },
    };

    final samples = [
      DateTime(2026, 9, 7, 10, 0), // Monday, inside morning
      DateTime(2026, 9, 7, 13, 30), // Monday, gap between windows
      DateTime(2026, 9, 7, 15, 0), // Monday, inside afternoon
      DateTime(2026, 9, 11, 10, 0), // Friday, locked
      DateTime(2026, 9, 12, 23, 0), // Saturday, inside midnight-crossing window
      DateTime(2026, 9, 12, 2, 0), // Saturday, inside midnight-crossing window (past midnight)
      DateTime(2026, 9, 12, 12, 0), // Saturday, outside the window
      DateTime(2026, 9, 8, 11, 0), // Tuesday, falls back to alldays, inside
      DateTime(2026, 9, 8, 20, 0), // Tuesday, falls back to alldays, outside
    ];

    test('parse -> toJson -> parse gives identical isOpenAt answers at every sample', () {
      final original = BranchWorkTime.tryParse(payload)!;
      final roundTripped = BranchWorkTime.tryParse(original.toJson())!;

      for (final dt in samples) {
        expect(
          roundTripped.isOpenAt(dt),
          equals(original.isOpenAt(dt)),
          reason: 'mismatch at $dt',
        );
      }
    });

    test('round-trip preserves the locked day as closed', () {
      final original = BranchWorkTime.tryParse(payload)!;
      final roundTripped = BranchWorkTime.tryParse(original.toJson())!;

      final friday = DateTime(2026, 9, 11, 10, 0);
      expect(original.isOpenAt(friday), isFalse);
      expect(roundTripped.isOpenAt(friday), isFalse);
    });

    test('round-trip preserves the midnight-crossing window', () {
      final original = BranchWorkTime.tryParse(payload)!;
      final roundTripped = BranchWorkTime.tryParse(original.toJson())!;

      final pastMidnight = DateTime(2026, 9, 12, 2, 0);
      final outside = DateTime(2026, 9, 12, 12, 0);
      expect(original.isOpenAt(pastMidnight), isTrue);
      expect(roundTripped.isOpenAt(pastMidnight), isTrue);
      expect(original.isOpenAt(outside), isFalse);
      expect(roundTripped.isOpenAt(outside), isFalse);
    });
  });
}
