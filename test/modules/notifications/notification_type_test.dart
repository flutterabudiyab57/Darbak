import 'package:darbak/modules/notifications/presentaion/widget/notification_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationType.fromString', () {
    test('parses cashback', () {
      expect(NotificationType.fromString('cashback'), NotificationType.cashback);
    });

    test('parses booking', () {
      expect(NotificationType.fromString('booking'), NotificationType.booking);
    });

    test('parses offer', () {
      expect(NotificationType.fromString('offer'), NotificationType.offer);
    });

    test('parses update', () {
      expect(NotificationType.fromString('update'), NotificationType.update);
    });

    test('is case-insensitive', () {
      expect(NotificationType.fromString('CASHBACK'), NotificationType.cashback);
      expect(NotificationType.fromString('Booking'), NotificationType.booking);
      expect(NotificationType.fromString('OFFER'), NotificationType.offer);
      expect(NotificationType.fromString('UPDATE'), NotificationType.update);
    });

    test('trims surrounding whitespace before matching', () {
      expect(NotificationType.fromString('  offer  '), NotificationType.offer);
      expect(NotificationType.fromString('\tcashback\n'), NotificationType.cashback);
    });

    test('unknown fallback for unrecognised string', () {
      expect(NotificationType.fromString('promo'), NotificationType.unknown);
      expect(NotificationType.fromString('xyz'), NotificationType.unknown);
    });

    test('unknown fallback for null', () {
      expect(NotificationType.fromString(null), NotificationType.unknown);
    });

    test('unknown fallback for empty string', () {
      expect(NotificationType.fromString(''), NotificationType.unknown);
    });

    test('unknown fallback for whitespace-only string', () {
      expect(NotificationType.fromString('   '), NotificationType.unknown);
    });
  });

  group('NotificationType getters', () {
    test('every value has a non-null backgroundColor', () {
      for (final type in NotificationType.values) {
        expect(type.backgroundColor, isA<Color>(),
            reason: '${type.name}.backgroundColor should not be null');
      }
    });

    test('every value has a non-null iconColor', () {
      for (final type in NotificationType.values) {
        expect(type.iconColor, isA<Color>(),
            reason: '${type.name}.iconColor should not be null');
      }
    });

    test('every value has a non-null icon', () {
      for (final type in NotificationType.values) {
        expect(type.icon, isA<IconData>(),
            reason: '${type.name}.icon should not be null');
      }
    });

    test('each type has a distinct backgroundColor', () {
      final colors = NotificationType.values.map((t) => t.backgroundColor).toList();
      final unique = colors.toSet();
      expect(unique.length, NotificationType.values.length,
          reason: 'every type should have a unique background color');
    });

    test('unknown type has neutral grey background', () {
      expect(
        NotificationType.unknown.backgroundColor,
        const Color(0xFFE5E7EB),
      );
    });

    test('cashback type has green background', () {
      expect(
        NotificationType.cashback.backgroundColor,
        const Color(0xFFD0FAE5),
      );
    });
  });
}
