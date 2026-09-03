import 'package:dio/dio.dart';

import '../../../core/constants/api_path.dart';
import '../../../core/helpers/interceptors/app_interceptor.dart';
import 'location_language.dart';
import 'location_filter.dart';
import 'models/branch.dart';
import 'models/paginated.dart';
import 'models/region.dart';

/// Talks to `/regions`, `/branches`, and `/available/branches/{carId}` using
/// the app's shared configured Dio — never `package:http`, never a bare
/// `Dio()`. The shared instance already carries auth headers and timeouts
/// via `AppInterceptors`; this class adds only an explicit `Accept-Language`
/// per request, since the interceptor's own header can be stale/empty at
/// boot (research.md R5).
class LocationRemoteDataSource {
  final Dio _dio;

  LocationRemoteDataSource(this._dio);

  static const int _perPage = 100;
  static const int _hardPageCap = 10;

  Map<String, String> get _headers => {
    AppInterceptors.acceptLangHeader: currentLocationLanguage(),
  };

  /// `GET {mainApi}/regions` — envelope `{data, links, meta}`, single page,
  /// no pagination loop. Elements without a usable integer id are dropped.
  Future<List<Region>> getRegions() async {
    final response = await _dio.get<dynamic>(
      '$mainApi/regions',
      options: Options(headers: _headers),
    );

    final paginated = Paginated<Region?>.fromJson(response.data, Region.tryParse);
    return paginated.data.whereType<Region>().toList();
  }

  Future<List<Branch>> getBranches(LocationFilter filter) async {
    if (filter.carId != null) {
      return _getCarBranches(filter.carId!);
    }
    if (filter.homeDelivery) {
      return _getPaginatedBranches('$mainApi/branches', {'home_delivery': 1, 'perPage': _perPage});
    }
    if (filter.airport) {
      return _getPaginatedBranches('$mainApi/branches', {'airport': 1, 'perPage': _perPage});
    }

    final query = <String, dynamic>{'home_delivery': 0, 'perPage': _perPage};
    if (filter.regionId != null) {
      query['regions'] = filter.regionId;
    }
    return _getPaginatedBranches('$mainApi/branches', query);
  }

  Future<List<Branch>> _getCarBranches(int carId) async {
    final response = await _dio.get<dynamic>(
      '$mainApi/available/branches/$carId',
      options: Options(headers: _headers),
    );

    final paginated = Paginated<Branch>.fromJson(response.data, Branch.fromCarBranchesApi);
    return paginated.data;
  }

  /// Pagination driven by `meta.last_page` read from page 1. Hard cap of 10
  /// pages — a runaway `last_page` from the server must not spin the client.
  /// Dedupes by id across pages, since equality is on id.
  Future<List<Branch>> _getPaginatedBranches(String url, Map<String, dynamic> baseQuery) async {
    final firstResponse = await _dio.get<dynamic>(
      url,
      queryParameters: baseQuery,
      options: Options(headers: _headers),
    );

    final firstPage = Paginated<Branch>.fromJson(firstResponse.data, Branch.fromBranchesApi);
    final collected = <int, Branch>{for (final b in firstPage.data) b.id: b};

    final lastPage = firstPage.lastPage.clamp(1, _hardPageCap);
    for (var page = 2; page <= lastPage; page++) {
      final response = await _dio.get<dynamic>(
        url,
        queryParameters: {...baseQuery, 'page': page},
        options: Options(headers: _headers),
      );
      final paginated = Paginated<Branch>.fromJson(response.data, Branch.fromBranchesApi);
      for (final b in paginated.data) {
        collected[b.id] = b;
      }
    }

    return collected.values.toList();
  }
}
