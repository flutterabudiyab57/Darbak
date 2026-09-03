import 'package:darbak/core/constants/api_path.dart';
import 'package:darbak/core/constants/langCode.dart' as global_lang;
import 'package:darbak/core/helpers/interceptors/app_interceptor.dart';
import 'package:darbak/modules/location/data/location_filter.dart';
import 'package:darbak/modules/location/data/location_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> _resp(dynamic data) =>
    Response<dynamic>(data: data, requestOptions: RequestOptions(path: ''));

Map<String, dynamic> _regionJson(int id) => {'id': id, 'name': 'Region $id', 'city': 'City'};

Map<String, dynamic> _branchJson(int id) => {'id': id, 'name': 'Branch $id'};

Map<String, dynamic> _paginatedEnvelope(List<Map<String, dynamic>> items, int page, int lastPage) => {
  'data': items,
  'meta': {'current_page': page, 'last_page': lastPage, 'total': items.length},
};

void main() {
  setUpAll(() {
    registerFallbackValue(Options());
  });

  late MockDio dio;
  late LocationRemoteDataSource ds;

  setUp(() {
    dio = MockDio();
    ds = LocationRemoteDataSource(dio);
    global_lang.langCode = '';
  });

  group('getBranches query routing', () {
    test('region filter sends regions and perPage', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp(_paginatedEnvelope([_branchJson(1)], 1, 1)));

      await ds.getBranches(const LocationFilter.region(7));

      verify(() => dio.get<dynamic>(
            '$mainApi/branches',
            queryParameters: any(
              named: 'queryParameters',
              that: equals({'home_delivery': 0, 'perPage': 100, 'regions': 7}),
            ),
            options: any(named: 'options'),
          )).called(1);
    });

    test('no-region filter omits the regions key (absent, not present-and-null)', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp(_paginatedEnvelope([_branchJson(1)], 1, 1)));

      await ds.getBranches(const LocationFilter.allRegions());

      final captured = verify(() => dio.get<dynamic>(
            '$mainApi/branches',
            queryParameters: captureAny(named: 'queryParameters'),
            options: any(named: 'options'),
          )).captured.single as Map<String, dynamic>;

      expect(captured.containsKey('regions'), isFalse);
      expect(captured, {'home_delivery': 0, 'perPage': 100});
    });

    test('delivery filter never sends regions', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp(_paginatedEnvelope([_branchJson(1)], 1, 1)));

      await ds.getBranches(const LocationFilter.delivery());

      verify(() => dio.get<dynamic>(
            '$mainApi/branches',
            queryParameters: any(
              named: 'queryParameters',
              that: equals({'home_delivery': 1, 'perPage': 100}),
            ),
            options: any(named: 'options'),
          )).called(1);
    });

    test('airport filter never sends regions', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp(_paginatedEnvelope([_branchJson(1)], 1, 1)));

      await ds.getBranches(const LocationFilter.airport());

      verify(() => dio.get<dynamic>(
            '$mainApi/branches',
            queryParameters: any(
              named: 'queryParameters',
              that: equals({'airport': 1, 'perPage': 100}),
            ),
            options: any(named: 'options'),
          )).called(1);
    });

    test('car filter hits the car path with no query', () async {
      when(() => dio.get<dynamic>(any(), options: any(named: 'options')))
          .thenAnswer((_) async => _resp(_paginatedEnvelope([_branchJson(42)], 1, 1)));

      await ds.getBranches(const LocationFilter.car(42));

      verify(() => dio.get<dynamic>(
            '$mainApi/available/branches/42',
            options: any(named: 'options'),
          )).called(1);
      verifyNever(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          ));
    });

    test('car filter marks results partial', () async {
      when(() => dio.get<dynamic>(any(), options: any(named: 'options'))).thenAnswer(
        (_) async => _resp(_paginatedEnvelope([
          {'id': 1, 'text': 'A'},
          {'id': 2, 'text': 'B'},
        ], 1, 1)),
      );

      final branches = await ds.getBranches(const LocationFilter.car(1));

      expect(branches, isNotEmpty);
      expect(branches.every((b) => b.isPartial), isTrue);
    });

    test('branches filter marks results complete', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp(_paginatedEnvelope([_branchJson(1), _branchJson(2)], 1, 1)));

      final branches = await ds.getBranches(const LocationFilter.delivery());

      expect(branches, isNotEmpty);
      expect(branches.every((b) => !b.isPartial), isTrue);
    });
  });

  group('getBranches pagination', () {
    test('pagination follows meta.last_page: last_page 3 issues 3 requests, pages 2/3 appended', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        final query = invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
        final page = query['page'] ?? 1;
        return _resp(_paginatedEnvelope([_branchJson(page as int)], page, 3));
      });

      final branches = await ds.getBranches(const LocationFilter.allRegions());

      verify(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).called(3);
      expect(branches.map((b) => b.id).toSet(), {1, 2, 3});
    });

    test('pagination caps at 10 pages when last_page is 50', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        final query = invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
        final page = query['page'] ?? 1;
        return _resp(_paginatedEnvelope([_branchJson(page as int)], page, 50));
      });

      await ds.getBranches(const LocationFilter.allRegions());

      verify(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).called(10);
    });

    test('single page issues one request (last_page 1, no second request)', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp(_paginatedEnvelope([_branchJson(1)], 1, 1)));

      await ds.getBranches(const LocationFilter.allRegions());

      verify(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).called(1);
    });

    test('duplicate ids across pages collapse into one entry', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((invocation) async {
        final query = invocation.namedArguments[#queryParameters] as Map<String, dynamic>;
        final page = query['page'] ?? 1;
        // Same id (1) reported on both page 1 and page 2.
        return _resp(_paginatedEnvelope([_branchJson(1)], page as int, 2));
      });

      final branches = await ds.getBranches(const LocationFilter.allRegions());

      expect(branches.length, 1);
    });
  });

  group('getBranches response shape tolerance', () {
    test('a bare list response parses into branches, one page', () async {
      when(() => dio.get<dynamic>(
            any(),
            queryParameters: any(named: 'queryParameters'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => _resp([_branchJson(1), _branchJson(2)]));

      final branches = await ds.getBranches(const LocationFilter.allRegions());

      expect(branches.length, 2);
    });
  });

  group('getRegions', () {
    test('parses the {data, links, meta} envelope with no pagination loop', () async {
      when(() => dio.get<dynamic>(any(), options: any(named: 'options'))).thenAnswer(
        (_) async => _resp(_paginatedEnvelope([_regionJson(1), _regionJson(2)], 1, 1)),
      );

      final regions = await ds.getRegions();

      expect(regions.length, 2);
      verify(() => dio.get<dynamic>('$mainApi/regions', options: any(named: 'options'))).called(1);
    });
  });

  group('Accept-Language header', () {
    test('is sent explicitly using the resolver value, not an empty string', () async {
      global_lang.langCode = 'en';
      when(() => dio.get<dynamic>(any(), options: any(named: 'options'))).thenAnswer(
        (_) async => _resp(_paginatedEnvelope([_regionJson(1)], 1, 1)),
      );

      await ds.getRegions();

      final captured = verify(() => dio.get<dynamic>(
            any(),
            options: captureAny(named: 'options'),
          )).captured.single as Options;

      expect(captured.headers?[AppInterceptors.acceptLangHeader], 'en');
    });

    test('defaults to "ar" when the global langCode is empty, never sends an empty string', () async {
      global_lang.langCode = '';
      when(() => dio.get<dynamic>(any(), options: any(named: 'options'))).thenAnswer(
        (_) async => _resp(_paginatedEnvelope([_regionJson(1)], 1, 1)),
      );

      await ds.getRegions();

      final captured = verify(() => dio.get<dynamic>(
            any(),
            options: captureAny(named: 'options'),
          )).captured.single as Options;

      expect(captured.headers?[AppInterceptors.acceptLangHeader], 'ar');
      expect(captured.headers?[AppInterceptors.acceptLangHeader], isNot(''));
    });
  });
}
