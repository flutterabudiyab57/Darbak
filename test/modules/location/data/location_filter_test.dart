import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocationFilter.cacheKey', () {
    test('is stable and fixed-order', () {
      const a = LocationFilter.region(7);
      const b = LocationFilter.region(7);
      expect(a.cacheKey, b.cacheKey);
      expect(a.cacheKey, 'r=7|hd=0|ap=0|car=_');
    });

    test('equal filters produce one key', () {
      expect(const LocationFilter.delivery().cacheKey, const LocationFilter.delivery().cacheKey);
    });

    test('region 7 and region 8 produce different keys', () {
      expect(
        const LocationFilter.region(7).cacheKey,
        isNot(const LocationFilter.region(8).cacheKey),
      );
    });

    test('home delivery and airport produce different keys', () {
      expect(
        const LocationFilter.delivery().cacheKey,
        isNot(const LocationFilter.airport().cacheKey),
      );
    });

    test('a car filter produces a different key from a region filter', () {
      expect(
        const LocationFilter.car(42).cacheKey,
        isNot(const LocationFilter.region(42).cacheKey),
      );
    });
  });

  group('LocationFilter equality', () {
    test('two filters with identical values are equal', () {
      expect(const LocationFilter.region(7), const LocationFilter.region(7));
      expect(
        const LocationFilter.region(7).hashCode,
        const LocationFilter.region(7).hashCode,
      );
    });

    test('allRegions is distinct from a specific region', () {
      expect(const LocationFilter.allRegions(), isNot(const LocationFilter.region(7)));
    });
  });

  group('Named constructors structurally exclude regionId', () {
    test('delivery() exposes no way to set regionId', () {
      expect(const LocationFilter.delivery().regionId, isNull);
    });

    test('airport() exposes no way to set regionId', () {
      expect(const LocationFilter.airport().regionId, isNull);
    });

    test('car() exposes no way to set regionId', () {
      expect(const LocationFilter.car(9).regionId, isNull);
    });
  });
}
