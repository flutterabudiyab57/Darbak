import 'dart:convert';
import 'dart:developer';

import 'location_cache.dart';
import 'location_filter.dart';
import 'location_language.dart';
import 'location_remote_datasource.dart';
import 'models/branch.dart';
import 'models/region.dart';

/// Cache-first, network on miss or expiry.
///
/// If the network fails AND an expired entry exists, returns the stale data
/// rather than throwing — only in that case. A fresh miss with a dead
/// network still throws, so the screen can show the retry FR-038 requires.
class LocationRepository {
  final LocationRemoteDataSource _remote;
  final LocationCache _cache;

  LocationRepository(this._remote, this._cache);

  String get _lang => currentLocationLanguage();

  Future<List<Region>> getRegions({bool forceRefresh = false}) async {
    final key = 'regions:$_lang';

    if (!forceRefresh) {
      final cached = await _safeCacheRead(key);
      if (cached != null) {
        final decoded = _tryDecodeRegions(cached);
        if (decoded != null) return decoded;
      }
    }

    final List<Region> regions;
    try {
      regions = await _remote.getRegions();
    } catch (e) {
      final stale = await _safeCacheReadStale(key);
      if (stale != null) {
        final decoded = _tryDecodeRegions(stale);
        if (decoded != null) return decoded;
      }
      rethrow;
    }

    // The fetch already succeeded — a cache write failure must never affect
    // what the caller receives, so it is guarded independently of the fetch.
    await _safeCacheWrite(key, json.encode(regions.map(_regionToJson).toList()));
    return regions;
  }

  Future<List<Branch>> getBranches(LocationFilter filter, {bool forceRefresh = false}) async {
    final key = 'branches:$_lang:${filter.cacheKey}';

    if (!forceRefresh) {
      final cached = await _safeCacheRead(key);
      if (cached != null) {
        final decoded = _tryDecodeBranches(cached);
        if (decoded != null) return decoded;
      }
    }

    final List<Branch> branches;
    try {
      branches = await _remote.getBranches(filter);
    } catch (e) {
      final stale = await _safeCacheReadStale(key);
      if (stale != null) {
        final decoded = _tryDecodeBranches(stale);
        if (decoded != null) return decoded;
      }
      rethrow;
    }

    // The fetch already succeeded — a cache write failure must never affect
    // what the caller receives, so it is guarded independently of the fetch.
    await _safeCacheWrite(key, json.encode(branches.map(_branchToJson).toList()));
    return branches;
  }

  // A second, repository-level guard against a throwing LocationCache — the
  // contract requires this independently of LocationCache's own try/catch,
  // so a future regression in that layer degrades to a cache miss here
  // rather than turning into an unhandled exception or a wrong fallback path.

  Future<String?> _safeCacheRead(String key) async {
    try {
      return await _cache.read(key);
    } catch (e) {
      log('⚠️ LocationRepository: cache.read threw for "$key", treating as a miss: $e');
      return null;
    }
  }

  Future<String?> _safeCacheReadStale(String key) async {
    try {
      return await _cache.readStale(key);
    } catch (e) {
      log('⚠️ LocationRepository: cache.readStale threw for "$key", treating as a miss: $e');
      return null;
    }
  }

  Future<void> _safeCacheWrite(String key, String payload) async {
    try {
      await _cache.write(key, payload);
    } catch (e) {
      log('⚠️ LocationRepository: cache.write threw for "$key", ignoring: $e');
    }
  }

  // A decode failure on cached JSON is treated as a miss — indistinguishable
  // from one — and falls through to the network / rethrows, per contract.

  List<Region>? _tryDecodeRegions(String raw) {
    try {
      final list = json.decode(raw) as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Region.tryParse)
          .whereType<Region>()
          .toList();
    } catch (e) {
      log('⚠️ LocationRepository: cached regions payload failed to decode: $e');
      return null;
    }
  }

  List<Branch>? _tryDecodeBranches(String raw) {
    try {
      final list = json.decode(raw) as List;
      return list.whereType<Map<String, dynamic>>().map(_branchFromCacheJson).toList();
    } catch (e) {
      log('⚠️ LocationRepository: cached branches payload failed to decode: $e');
      return null;
    }
  }

  // The cache stores the module's own serialization, not the raw API
  // envelope, so round-tripping uses fromBranchesApi/toBranchesApi-shaped
  // maps that carry isPartial explicitly rather than re-deriving it.

  Map<String, dynamic> _regionToJson(Region r) => {
    'id': r.id,
    'name': r.name,
    'city': r.city,
    'polygon': r.polygon?.map((p) => {'lat': p.lat, 'lng': p.lng}).toList(),
  };

  Map<String, dynamic> _branchToJson(Branch b) => {
    'id': b.id,
    'name': b.name,
    'region_id': b.regionId,
    'region': b.regionName,
    'address': b.address,
    'lat': b.lat,
    'long': b.lng,
    'phone': b.phone,
    'location_url': b.locationUrl,
    'work_time': b.workTime?.toJson(),
    'book_today': b.bookToday ? 1 : 0,
    'delivery_price': b.deliveryPrice,
    'image': b.image,
    'is_partial': b.isPartial,
    'polygon': b.polygon?.map((p) => {'lat': p.lat, 'lng': p.lng}).toList(),
    'center': b.center != null ? {'lat': b.center!.lat, 'lng': b.center!.lng} : null,
  };

  Branch _branchFromCacheJson(Map<String, dynamic> json) {
    final isPartial = json['is_partial'] == true;
    return isPartial ? Branch.fromCarBranchesApi(json) : Branch.fromBranchesApi(json);
  }
}
