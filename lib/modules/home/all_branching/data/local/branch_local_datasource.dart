import 'package:darbak/core/helpers/cache/cache_helper.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:hive_ce/hive.dart';

class BranchLocalDataSource {
  static const String _branchesKey = 'all_branches';

  Future<void> cacheBranches(List<BranchModel> branches) async {
    try {
      if (!CacheHelper.isInitialized) {
        print('âš ï¸ Cache not initialized');
        return;
      }

      final box = CacheHelper.getBox(CacheHelper.branchesBoxName);

       await box.put(_branchesKey, branches);
      await CacheHelper.saveCacheTimestamp(_branchesKey);

      print('âœ… Cached ${branches.length} branches locally');
    } catch (e) {
      print('an Error caching branches: $e');
    }
  }

  Future<List<BranchModel>> getCachedBranches() async {
    try {
      if (!CacheHelper.isInitialized) {
        throw Exception('Cache not initialized');
      }

      final box = CacheHelper.getBox(CacheHelper.branchesBoxName);
      final cachedData = box.get(_branchesKey);

      if (cachedData == null) {
        throw Exception('No cached branches found');
      }

       final branches = List<BranchModel>.from(cachedData);

      print('âœ… Loaded ${branches.length} branches from cache');
      return branches;
    } catch (e) {
      print('an Error loading cached branches: $e');
      rethrow;
    }
  }
  bool isCacheValid() {
    if (!CacheHelper.isInitialized) {
      print('âš ï¸ Cache not initialized');
      return false;
    }
    return CacheHelper.isCacheValid(_branchesKey);
  }

   Future<void> clearCache() async {
    await CacheHelper.clearCache(CacheHelper.branchesBoxName);
  }

   Duration? getCacheAge() {
    if (!CacheHelper.isInitialized) {
      return null;
    }

    try {
      final box = Hive.box('cache_meta_box');
      final cachedTime = box.get('${_branchesKey}_time');

      if (cachedTime == null) return null;

      final DateTime cached = DateTime.parse(cachedTime);
      return DateTime.now().difference(cached);
    } catch (e) {
      print('âš ï¸ Error getting cache age: $e');
      return null;
    }
  }
}