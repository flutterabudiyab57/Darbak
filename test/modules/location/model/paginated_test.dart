import 'package:darbak/modules/location/data/models/paginated.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _item(int id) => {'id': id};

void main() {
  group('Paginated.fromJson', () {
    test('parses a data+meta envelope', () {
      final result = Paginated<Map<String, dynamic>>.fromJson({
        'data': [_item(1), _item(2)],
        'meta': {'current_page': 2, 'last_page': 5, 'total': 48},
      }, (j) => j);

      expect(result.data.length, 2);
      expect(result.currentPage, 2);
      expect(result.lastPage, 5);
      expect(result.total, 48);
    });

    test('parses a data-only envelope with no meta as a single page', () {
      final result = Paginated<Map<String, dynamic>>.fromJson({
        'data': [_item(1), _item(2), _item(3)],
      }, (j) => j);

      expect(result.data.length, 3);
      expect(result.currentPage, 1);
      expect(result.lastPage, 1);
      expect(result.total, 3);
    });

    test('parses a bare list as a single page', () {
      final result = Paginated<Map<String, dynamic>>.fromJson(
        [_item(1), _item(2)],
        (j) => j,
      );

      expect(result.data.length, 2);
      expect(result.currentPage, 1);
      expect(result.lastPage, 1);
      expect(result.total, 2);
    });

    test('lastPage and total default when meta fields are missing', () {
      final result = Paginated<Map<String, dynamic>>.fromJson({
        'data': [_item(1)],
        'meta': <String, dynamic>{},
      }, (j) => j);

      expect(result.lastPage, 1);
      expect(result.total, 1);
    });

    test('malformed top-level input yields an empty single page', () {
      final result = Paginated<Map<String, dynamic>>.fromJson('nonsense', (j) => j);

      expect(result.data, isEmpty);
      expect(result.currentPage, 1);
      expect(result.lastPage, 1);
      expect(result.total, 0);
    });
  });
}
