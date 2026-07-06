import 'package:darbak/modules/notifications/data/model/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── NotificationItem ───────────────────────────────────────────────────────

  group('NotificationItem', () {
    group('fromJson', () {
      test('parses all standard fields', () {
        final json = {
          'id': 42,
          'type': 'cashback',
          'title': 'You got cashback',
          'body': 'SAR 50 added',
          'is_read': false,
          'created_at': '2025-06-01T10:00:00Z',
          'data': {'amount': 50},
        };
        final item = NotificationItem.fromJson(json);

        expect(item.id, 42);
        expect(item.type, 'cashback');
        expect(item.title, 'You got cashback');
        expect(item.body, 'SAR 50 added');
        expect(item.isRead, false);
        expect(item.data['amount'], 50);
      });

      test('reads body from "message" key when "body" is absent', () {
        final json = {
          'id': 1,
          'type': 'booking',
          'title': 'Title',
          'message': 'body via message key',
          'is_read': false,
          'created_at': '2025-01-01T00:00:00Z',
        };
        final item = NotificationItem.fromJson(json);
        expect(item.body, 'body via message key');
      });

      test('treats non-null read_at string as isRead = true', () {
        final json = {
          'id': 1,
          'type': 'offer',
          'title': '',
          'body': '',
          'read_at': '2025-05-01T00:00:00Z',
          'created_at': '2025-05-01T00:00:00Z',
        };
        final item = NotificationItem.fromJson(json);
        expect(item.isRead, true);
      });

      test('treats is_read: true bool as isRead = true', () {
        final json = {
          'id': 1,
          'type': 'update',
          'title': '',
          'body': '',
          'is_read': true,
          'created_at': '2025-01-01T00:00:00Z',
        };
        expect(NotificationItem.fromJson(json).isRead, true);
      });

      test('falls back gracefully on completely empty json', () {
        final item = NotificationItem.fromJson({});

        expect(item.id, 0);
        expect(item.type, '');
        expect(item.title, '');
        expect(item.body, '');
        expect(item.isRead, false);
        expect(item.data, isEmpty);
        // createdAt defaults to DateTime.now() — just check it doesn't throw
        expect(item.createdAt, isA<DateTime>());
      });

      test('ignores non-Map data field', () {
        final json = {
          'id': 1,
          'type': 't',
          'title': 't',
          'body': 'b',
          'is_read': false,
          'created_at': '2025-01-01T00:00:00Z',
          'data': 'not a map',
        };
        final item = NotificationItem.fromJson(json);
        expect(item.data, isEmpty);
      });

      test('parses id from a string number', () {
        final json = {
          'id': '99',
          'type': 't',
          'title': 't',
          'body': 'b',
          'is_read': false,
          'created_at': '2025-01-01T00:00:00Z',
        };
        expect(NotificationItem.fromJson(json).id, 99);
      });
    });

    group('copyWith', () {
      final original = NotificationItem(
        id: 7,
        type: 'offer',
        title: 'Original',
        body: 'Body',
        isRead: false,
        createdAt: DateTime(2025, 3, 15),
      );

      test('flips isRead to true', () {
        final copy = original.copyWith(isRead: true);
        expect(copy.isRead, true);
      });

      test('preserves all other fields when flipping isRead', () {
        final copy = original.copyWith(isRead: true);
        expect(copy.id, original.id);
        expect(copy.type, original.type);
        expect(copy.title, original.title);
        expect(copy.body, original.body);
        expect(copy.createdAt, original.createdAt);
      });

      test('preserves isRead when called with no argument', () {
        expect(original.copyWith().isRead, false);
      });

      test('returns a new instance, not the same reference', () {
        final copy = original.copyWith(isRead: true);
        expect(identical(copy, original), false);
      });
    });
  });

  // ── NotificationsPage ──────────────────────────────────────────────────────

  group('NotificationsPage', () {
    group('fromJson', () {
      test('parses items list and meta correctly', () {
        final json = {
          'data': [
            {
              'id': 1,
              'type': 'booking',
              'title': 'Booked',
              'body': 'Car booked',
              'is_read': true,
              'created_at': '2025-06-01T00:00:00Z',
            }
          ],
          'meta': {
            'current_page': 1,
            'last_page': 3,
            'per_page': 15,
            'total': 42,
          },
        };
        final page = NotificationsPage.fromJson(json);

        expect(page.items.length, 1);
        expect(page.items.first.type, 'booking');
        expect(page.currentPage, 1);
        expect(page.lastPage, 3);
        expect(page.perPage, 15);
        expect(page.total, 42);
      });

      test('falls back gracefully on completely empty json', () {
        final page = NotificationsPage.fromJson({});

        expect(page.items, isEmpty);
        expect(page.currentPage, 1); // fallback
        expect(page.lastPage, 1); // fallback to current
        expect(page.hasMore, false);
      });

      test('handles string numbers in meta', () {
        final json = {
          'data': <dynamic>[],
          'meta': {
            'current_page': '2',
            'last_page': '5',
            'per_page': '15',
            'total': '75',
          },
        };
        final page = NotificationsPage.fromJson(json);

        expect(page.currentPage, 2);
        expect(page.lastPage, 5);
        expect(page.perPage, 15);
        expect(page.total, 75);
      });

      test('skips non-Map entries in the data list', () {
        final json = {
          'data': ['not a map', 42, null],
          'meta': {'current_page': 1, 'last_page': 1},
        };
        final page = NotificationsPage.fromJson(json);
        expect(page.items, isEmpty);
      });

      test('treats absent meta as single page', () {
        final json = {
          'data': <dynamic>[],
          // no meta key
        };
        final page = NotificationsPage.fromJson(json);
        expect(page.hasMore, false);
      });
    });

    group('hasMore', () {
      test('is true when currentPage < lastPage', () {
        const page = NotificationsPage(
          items: [],
          currentPage: 1,
          lastPage: 3,
          perPage: 15,
          total: 42,
        );
        expect(page.hasMore, true);
      });

      test('is false when currentPage == lastPage', () {
        const page = NotificationsPage(
          items: [],
          currentPage: 3,
          lastPage: 3,
          perPage: 15,
          total: 42,
        );
        expect(page.hasMore, false);
      });

      test('is false when currentPage > lastPage', () {
        const page = NotificationsPage(
          items: [],
          currentPage: 4,
          lastPage: 3,
          perPage: 15,
          total: 42,
        );
        expect(page.hasMore, false);
      });
    });
  });
}
