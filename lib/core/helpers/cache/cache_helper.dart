import 'package:hive_ce/hive.dart';

class CacheHelper {
  static const String _branchesBox = 'branches_box';
  static const String _carsBox = 'cars_box';
  static const String _cacheMetaBox = 'cache_meta_box';

  // Cache expiry time (1 hour)
  static const Duration cacheValidDuration = Duration(minutes: 5);

  // Track initialization status
  static bool _isInitialized = false;

  /// Initialize Hive boxes
  static Future<void> init() async {
    if (_isInitialized) {
      print('⚠️ Cache already initialized, skipping...');
      return;
    }

    try {
      // print('🔧 Opening Hive boxes...');

      // Open all boxes sequentially
      await Hive.openBox(_branchesBox);

      await Hive.openBox(_carsBox);

      await Hive.openBox(_cacheMetaBox);

      _isInitialized = true;
      print('✅ All cache boxes initialized successfully');
    } catch (e) {
      rethrow;
    }
  }

  /// Check if cache is valid
  static bool isCacheValid(String key) {
    try {
      if (!_isInitialized) {
        print('⚠️ Cache not initialized yet');
        return false;
      }

      final metaBox = Hive.box(_cacheMetaBox);
      final cachedTime = metaBox.get('${key}_time');

      if (cachedTime == null) {
        return false;
      }

      final DateTime cached = DateTime.parse(cachedTime);
      final difference = DateTime.now().difference(cached);

      return difference < cacheValidDuration;
    } catch (e) {
      print('⚠️ Error checking cache validity: $e');
      return false;
    }
  }

  /// Save cache timestamp
  static Future<void> saveCacheTimestamp(String key) async {
    try {
      final metaBox = Hive.box(_cacheMetaBox);
      await metaBox.put('${key}_time', DateTime.now().toIso8601String());
    } catch (e) {
      print('⚠️ Error saving cache timestamp: $e');
    }
  }

  /// Clear specific cache
  static Future<void> clearCache(String boxName) async {
    try {
      final box = Hive.box(boxName);
      await box.clear();

      final metaBox = Hive.box(_cacheMetaBox);
      await metaBox.delete('${boxName}_time');

      print('🗑️ Cleared cache: $boxName');
    } catch (e) {
      print('⚠️ Error clearing cache: $e');
    }
  }

  /// Clear all caches
  static Future<void> clearAllCache() async {
    await clearCache(_branchesBox);
    await clearCache(_carsBox);
  }

  /// Get box by name (with safety check)
  static Box getBox(String boxName) {
    if (!_isInitialized) {
      throw HiveError('Cache not initialized. Call CacheHelper.init() first');
    }
    return Hive.box(boxName);
  }

  static bool get isInitialized => _isInitialized;

  static String get branchesBoxName => _branchesBox;
  static String get carsBoxName => _carsBox;
}