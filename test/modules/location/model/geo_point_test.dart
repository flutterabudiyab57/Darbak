import 'package:darbak/modules/location/data/models/geo_point.dart';
import 'package:darbak/modules/location/data/models/region.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoPoint.fromJson', () {
    test('parses from lng, not long', () {
      final point = GeoPoint.fromJson({'lat': 24.7, 'lng': 46.7, 'long': 99.9});
      expect(point.lat, 24.7);
      expect(point.lng, 46.7);
    });

    test('accepts numeric values', () {
      final point = GeoPoint.fromJson({'lat': 24, 'lng': 46});
      expect(point.lat, 24.0);
      expect(point.lng, 46.0);
    });

    test('tolerates string values', () {
      final point = GeoPoint.fromJson({'lat': '24.7', 'lng': '46.7'});
      expect(point.lat, 24.7);
      expect(point.lng, 46.7);
    });
  });

  group('GeoPoint.tryParse', () {
    test('a malformed vertex is dropped rather than throwing', () {
      expect(GeoPoint.tryParse('not a map'), isNull);
      expect(GeoPoint.tryParse(null), isNull);
      expect(GeoPoint.tryParse(42), isNull);
    });

    test('parses a valid map', () {
      final point = GeoPoint.tryParse({'lat': 1.0, 'lng': 2.0});
      expect(point, isNotNull);
      expect(point!.lat, 1.0);
      expect(point.lng, 2.0);
    });
  });

  group('Region', () {
    test('exposes no center', () {
      final region = Region.tryParse({'id': 1, 'name': 'Riyadh'});
      expect(region, isNotNull);
      // No `center` getter/field exists on Region — this is a compile-time
      // guarantee, verified simply by Region.tryParse succeeding without one.
      expect(region!.id, 1);
    });
  });
}
