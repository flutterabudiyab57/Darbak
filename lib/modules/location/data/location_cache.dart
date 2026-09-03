import 'dart:convert';
import 'dart:developer';

import 'package:hive_ce/hive.dart';

/// A single Hive CE box (`hive_ce`, never `package:hive`) of raw JSON
/// strings — no TypeAdapters, no `@HiveType`, so a model change never needs
/// `build_runner`.
///
/// Opened lazily on first use rather than in `initializeHive()`: `main.dart`'s
/// boot block swallows exceptions silently in release, so an `openBox`
/// failure there would be invisible. Opening here puts the failure inside
/// the try/catch every operation already wraps.
///
/// Every operation is wrapped in try/catch. A cache failure NEVER reaches
/// the caller — `read`/`readStale` return null, `write` does nothing.
class LocationCache {
  static const String _boxName = 'location_cache';

  static const Duration _regionsTtl = Duration(hours: 24);
  static const Duration _branchesTtl = Duration(hours: 6);

  Future<Box> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  /// TTL is derived from the key's own prefix (`regions:` vs `branches:`) so
  /// the public signature matches the contract exactly — the caller never
  /// has to know or pass a TTL.
  Duration _ttlFor(String key) => key.startsWith('regions:') ? _regionsTtl : _branchesTtl;

  /// Returns null on miss, expiry, or any failure.
  Future<String?> read(String key) async {
    try {
      final box = await _box();
      final raw = box.get(key);
      if (raw == null) return null;

      final decoded = json.decode(raw as String) as Map<String, dynamic>;
      final ts = decoded['ts'] as int?;
      final payload = decoded['payload'] as String?;
      if (ts == null || payload == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > _ttlFor(key).inMilliseconds) return null;

      return payload;
    } catch (e) {
      log('⚠️ LocationCache.read failed for "$key": $e');
      return null;
    }
  }

  /// Ignores TTL entirely — used only on the network-failure fallback path.
  /// An entry is never deleted on expiry, so this can still find it.
  Future<String?> readStale(String key) async {
    try {
      final box = await _box();
      final raw = box.get(key);
      if (raw == null) return null;

      final decoded = json.decode(raw as String) as Map<String, dynamic>;
      return decoded['payload'] as String?;
    } catch (e) {
      log('⚠️ LocationCache.readStale failed for "$key": $e');
      return null;
    }
  }

  Future<void> write(String key, String payloadJson) async {
    try {
      final box = await _box();
      final envelope = json.encode({
        'ts': DateTime.now().millisecondsSinceEpoch,
        'payload': payloadJson,
      });
      await box.put(key, envelope);
    } catch (e) {
      log('⚠️ LocationCache.write failed for "$key": $e');
    }
  }
}
