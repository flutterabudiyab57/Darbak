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

  // Verified 2026-09-06 against a real PRODUCTION /branches response
  // (abudiyab-soft.com, not stage): in every branch, sat/sun/mon/tue/wed/thu
  // carry ONLY {"lock": "0"} — no morning, no afternone. Real hours live in
  // "alldays", with "fri" the one weekday key that carries its own windows.
  group('Production payload shape (real /branches response, 2026-09-06)', () {
    // The exact shape reported: six weekday keys are empty locked/unlocked
    // shells, "alldays" carries the real default hours, "fri" overrides them.
    final productionShapedPayload = {
      'openAllDays': '0',
      'alldays': {
        'morning': {'timeopen': '08:00', 'timeclose': '14:00'},
        'afternone': {'timeopen': '16:00', 'timeclose': '22:00'},
      },
      'sun': {'lock': '0'},
      'mon': {'lock': '0'},
      'tue': {'lock': '0'},
      'wed': {'lock': '0'},
      'thu': {'lock': '0'},
      'sat': {'lock': '0'},
      'fri': {
        'morning': {'timeopen': '10:00', 'timeclose': '13:00'},
        'lock': '0',
      },
    };

    // THE CRITICAL CHECK. 2026-09-06 is a Sunday.
    test('a day with only {"lock": "0"} resolves to the alldays windows', () {
      final workTime = BranchWorkTime.tryParse(productionShapedPayload)!;

      final insideAlldaysMorning = DateTime(2026, 9, 6, 9, 0); // 09:00, inside alldays morning
      final betweenAlldaysWindows = DateTime(2026, 9, 6, 15, 0); // 15:00, gap between alldays windows
      final insideAlldaysAfternoon = DateTime(2026, 9, 6, 18, 0); // 18:00, inside alldays afternoon

      expect(workTime.isOpenAt(insideAlldaysMorning), isTrue);
      expect(
        workTime.isOpenAt(betweenAlldaysWindows),
        isFalse,
        reason: 'a Sunday whose own entry is only {"lock":"0"} must fall back to alldays hours, '
            'not fail open unconditionally just because the day key is present',
      );
      expect(workTime.isOpenAt(insideAlldaysAfternoon), isTrue);
    });

    test('a day with {"lock": "1"} is closed even when alldays has windows', () {
      final payload = Map<String, dynamic>.from(productionShapedPayload);
      payload['mon'] = {'lock': '1'};
      final workTime = BranchWorkTime.tryParse(payload)!;

      // 2026-09-07 is a Monday, inside alldays' morning window (08:00-14:00).
      final monday = DateTime(2026, 9, 7, 10, 0);
      expect(workTime.isOpenAt(monday), isFalse);
    });

    test('fri uses its own windows, not alldays', () {
      final workTime = BranchWorkTime.tryParse(productionShapedPayload)!;

      // 2026-09-11 is a Friday.
      final insideFriWindow = DateTime(2026, 9, 11, 11, 0); // inside fri's 10:00-13:00
      final insideAlldaysButOutsideFri = DateTime(2026, 9, 11, 18, 0); // inside alldays' afternoon, outside fri's window

      expect(workTime.isOpenAt(insideFriWindow), isTrue);
      expect(
        workTime.isOpenAt(insideAlldaysButOutsideFri),
        isFalse,
        reason: 'Friday must resolve against its own windows only, never fall through to alldays',
      );
    });

    test('lock "1" wins even when morning/afternone windows are present (branches 5, 10, 13, 25 on Friday)', () {
      final workTime = BranchWorkTime.tryParse({
        'fri': {
          'morning': {'timeopen': '09:00', 'timeclose': '13:00'},
          'afternone': {'timeopen': '16:00', 'timeclose': '20:00'},
          'lock': '1',
        },
      });

      final insideMorningWindow = DateTime(2026, 9, 11, 10, 0); // Friday, inside morning
      final insideAfternoonWindow = DateTime(2026, 9, 11, 17, 0); // Friday, inside afternoon
      expect(workTime!.isOpenAt(insideMorningWindow), isFalse);
      expect(workTime.isOpenAt(insideAfternoonWindow), isFalse);
    });

    test('"afternone": {"timeopen": null} contributes nothing, morning still applies (branches 3, 9, 22, 32)', () {
      final workTime = BranchWorkTime.tryParse({
        'fri': {
          'morning': {'timeopen': '08:00', 'timeclose': '14:00'},
          'afternone': {'timeopen': null, 'timeclose': '22:00'},
          'lock': '0',
        },
      });

      final insideMorning = DateTime(2026, 9, 11, 10, 0); // Friday, inside morning
      final wouldBeAfternoonIfCounted = DateTime(2026, 9, 11, 18, 0); // Friday, would only be "open" if the broken afternone window counted
      expect(workTime!.isOpenAt(insideMorning), isTrue);
      expect(workTime.isOpenAt(wouldBeAfternoonIfCounted), isFalse);
    });

    // Isolated at the TimeWindow level deliberately: given the critical-check
    // finding above, a shell {"lock":"0"} day already resolves to isOpenAt ==
    // true unconditionally, which would make an isOpenAt-level airport test
    // pass for the wrong reason (the fail-open bug) rather than because the
    // 00:00-23:59 window itself is correct. This checks the window boundary
    // math independently of that day-resolution question.
    test('a 00:00-23:59 window (airports, openAllDays "1") contains every minute of the day', () {
      const window = TimeWindow(open: '00:00', close: '23:59');
      expect(window.contains(0), isTrue);
      expect(window.contains(12 * 60), isTrue);
      expect(window.contains(23 * 60 + 58), isTrue);
      expect(window.contains(23 * 60 + 59), isFalse); // 23:59 itself, exclusive close
    });

    // Now that a present-but-empty weekday shell correctly falls through to
    // allDays, this can validate something real: an airport's 00:00-23:59
    // hours reached THROUGH the fallback (a weekday shell, same shape as
    // every other branch's), rather than through the fail-open bug that
    // used to make this pass for the wrong reason regardless of the hours.
    test('an airport (openAllDays "1", alldays 00:00-23:59) is open at every hour, reached via the weekday-shell fallback', () {
      final workTime = BranchWorkTime.tryParse({
        'openAllDays': '1',
        'alldays': {
          'morning': {'timeopen': '00:00', 'timeclose': '23:59'},
        },
        'sun': {'lock': '0'},
        'mon': {'lock': '0'},
        'tue': {'lock': '0'},
        'wed': {'lock': '0'},
        'thu': {'lock': '0'},
        'fri': {'lock': '0'},
        'sat': {'lock': '0'},
      })!;

      // 2026-09-06 (Sunday) through 2026-09-12 (Saturday) covers every
      // weekday shell key exactly once.
      for (var day = 6; day <= 12; day++) {
        for (final hour in [0, 6, 12, 18, 23]) {
          final dt = DateTime(2026, 9, day, hour, 0);
          expect(workTime.isOpenAt(dt), isTrue, reason: '$dt');
        }
      }
    });

    // The exact case the bug hid: a weekday shell correctly defers to
    // alldays, and alldays itself has a gap the branch is closed during.
    test('a gap in alldays hours (e.g. closed 15:00-16:00) is reported closed on a Sunday shell day', () {
      final workTime = BranchWorkTime.tryParse({
        'alldays': {
          'morning': {'timeopen': '09:00', 'timeclose': '15:00'},
          'afternone': {'timeopen': '16:00', 'timeclose': '22:00'},
        },
        'sun': {'lock': '0'},
      })!;

      // 2026-09-06 is a Sunday.
      final insideMorning = DateTime(2026, 9, 6, 10, 0);
      final insideGap = DateTime(2026, 9, 6, 15, 30);
      final insideAfternoon = DateTime(2026, 9, 6, 18, 0);

      expect(workTime.isOpenAt(insideMorning), isTrue);
      expect(workTime.isOpenAt(insideGap), isFalse);
      expect(workTime.isOpenAt(insideAfternoon), isTrue);
    });

    group('midnight-crossing windows from the production payload', () {
      test('20:00-02:01', () {
        const window = TimeWindow(open: '20:00', close: '02:01');
        expect(window.contains(20 * 60), isTrue); // 20:00
        expect(window.contains(23 * 60 + 59), isTrue); // 23:59
        expect(window.contains(0), isTrue); // 00:00
        expect(window.contains(2 * 60), isTrue); // 02:00, still before close
        expect(window.contains(2 * 60 + 1), isFalse); // 02:01, exclusive close
        expect(window.contains(12 * 60), isFalse); // noon, clearly outside
      });

      test('21:00-03:00', () {
        const window = TimeWindow(open: '21:00', close: '03:00');
        expect(window.contains(21 * 60), isTrue); // 21:00
        expect(window.contains(0), isTrue); // 00:00
        expect(window.contains(3 * 60 - 1), isTrue); // 02:59
        expect(window.contains(3 * 60), isFalse); // 03:00, exclusive
        expect(window.contains(20 * 60 + 59), isFalse); // 20:59, just before open
      });

      test('21:30-01:30', () {
        const window = TimeWindow(open: '21:30', close: '01:30');
        expect(window.contains(21 * 60 + 30), isTrue); // 21:30
        expect(window.contains(0), isTrue); // 00:00
        expect(window.contains(1 * 60 + 29), isTrue); // 01:29
        expect(window.contains(1 * 60 + 30), isFalse); // 01:30, exclusive
        expect(window.contains(21 * 60 + 29), isFalse); // 21:29, just before open
      });
    });
  });
}
