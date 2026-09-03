import 'dart:convert';

import 'package:darbak/core/constants/langCode.dart' as global_lang;
import 'package:darbak/modules/location/data/location_cache.dart';
import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:darbak/modules/location/data/location_remote_datasource.dart';
import 'package:darbak/modules/location/data/location_repository.dart';
import 'package:darbak/modules/location/data/models/branch.dart';
import 'package:darbak/modules/location/data/models/region.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationRemoteDataSource extends Mock implements LocationRemoteDataSource {}

class MockLocationCache extends Mock implements LocationCache {}

Region _fakeRegion({int id = 1}) => Region(id: id, name: 'Region $id');

Branch _fakeBranch({int id = 1}) => Branch(id: id, name: 'Branch $id', isPartial: false);

String _cachedRegionsJson(List<Region> regions) => json.encode(regions
    .map((r) => {'id': r.id, 'name': r.name, 'city': r.city, 'polygon': null})
    .toList());

void main() {
  setUpAll(() {
    registerFallbackValue(const LocationFilter.allRegions());
  });

  late MockLocationRemoteDataSource remote;
  late MockLocationCache cache;
  late LocationRepository repo;

  setUp(() {
    remote = MockLocationRemoteDataSource();
    cache = MockLocationCache();
    repo = LocationRepository(remote, cache);
    global_lang.langCode = 'ar';
  });

  group('getRegions', () {
    test('cache hit skips the network', () async {
      when(() => cache.read(any())).thenAnswer((_) async => _cachedRegionsJson([_fakeRegion()]));

      final regions = await repo.getRegions();

      expect(regions.single.id, 1);
      verifyNever(() => remote.getRegions());
    });

    test('cache miss fetches and writes the raw payload', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getRegions()).thenAnswer((_) async => [_fakeRegion()]);
      when(() => cache.write(any(), any())).thenAnswer((_) async {});

      final regions = await repo.getRegions();

      expect(regions.single.id, 1);
      verify(() => remote.getRegions()).called(1);
      verify(() => cache.write(any(), any())).called(1);
    });

    test('an expired entry (cache.read returning null) refetches from the network', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getRegions()).thenAnswer((_) async => [_fakeRegion()]);
      when(() => cache.write(any(), any())).thenAnswer((_) async {});

      await repo.getRegions();

      verify(() => remote.getRegions()).called(1);
    });

    test('forceRefresh bypasses a fresh cache entry', () async {
      when(() => cache.read(any())).thenAnswer((_) async => _cachedRegionsJson([_fakeRegion()]));
      when(() => remote.getRegions()).thenAnswer((_) async => [_fakeRegion(id: 2)]);
      when(() => cache.write(any(), any())).thenAnswer((_) async {});

      final regions = await repo.getRegions(forceRefresh: true);

      expect(regions.single.id, 2);
      verifyNever(() => cache.read(any()));
      verify(() => remote.getRegions()).called(1);
    });

    test('network failure with an expired/stale entry present returns the stale data', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getRegions()).thenThrow(Exception('network down'));
      when(() => cache.readStale(any())).thenAnswer((_) async => _cachedRegionsJson([_fakeRegion(id: 9)]));

      final regions = await repo.getRegions();

      expect(regions.single.id, 9);
    });

    test('network failure with no stale entry rethrows', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getRegions()).thenThrow(Exception('network down'));
      when(() => cache.readStale(any())).thenAnswer((_) async => null);

      expect(() => repo.getRegions(), throwsA(isA<Exception>()));
    });

    test('different languages use different cache keys', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getRegions()).thenAnswer((_) async => [_fakeRegion()]);
      when(() => cache.write(any(), any())).thenAnswer((_) async {});

      global_lang.langCode = 'ar';
      await repo.getRegions();
      final arKey = verify(() => cache.read(captureAny())).captured.single as String;

      global_lang.langCode = 'en';
      await repo.getRegions();
      final enKey = verify(() => cache.read(captureAny())).captured.single as String;

      expect(arKey, isNot(enKey));
    });
  });

  group('getBranches', () {
    test('cache read throwing is treated as a miss, falls through to remote', () async {
      when(() => cache.read(any())).thenThrow(Exception('box exploded'));
      when(() => remote.getBranches(any())).thenAnswer((_) async => [_fakeBranch()]);
      when(() => cache.write(any(), any())).thenAnswer((_) async {});

      final branches = await repo.getBranches(const LocationFilter.allRegions());

      expect(branches.single.id, 1);
    });

    test('cache write throwing is swallowed; caller still receives the fetched data', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getBranches(any())).thenAnswer((_) async => [_fakeBranch()]);
      when(() => cache.write(any(), any())).thenThrow(Exception('box exploded'));
      when(() => cache.readStale(any())).thenAnswer((_) async => null);

      final branches = await repo.getBranches(const LocationFilter.allRegions());

      expect(branches.single.id, 1);
    });

    test('different filters (region 7 vs region 8) use different cache keys', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getBranches(any())).thenAnswer((_) async => [_fakeBranch()]);
      when(() => cache.write(any(), any())).thenAnswer((_) async {});

      await repo.getBranches(const LocationFilter.region(7));
      final key7 = verify(() => cache.read(captureAny())).captured.single as String;

      await repo.getBranches(const LocationFilter.region(8));
      final key8 = verify(() => cache.read(captureAny())).captured.single as String;

      expect(key7, isNot(key8));
    });

    test('delivery and airport filters use different cache keys', () async {
      when(() => cache.read(any())).thenAnswer((_) async => null);
      when(() => remote.getBranches(any())).thenAnswer((_) async => [_fakeBranch()]);
      when(() => cache.write(any(), any())).thenAnswer((_) async {});

      await repo.getBranches(const LocationFilter.delivery());
      final deliveryKey = verify(() => cache.read(captureAny())).captured.single as String;

      await repo.getBranches(const LocationFilter.airport());
      final airportKey = verify(() => cache.read(captureAny())).captured.single as String;

      expect(deliveryKey, isNot(airportKey));
    });
  });
}
