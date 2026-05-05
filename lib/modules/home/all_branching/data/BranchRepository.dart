import 'package:darbak/modules/home/all_branching/data/all_branching_remote_datasource.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'local/branch_local_datasource.dart';

class BranchRepository {
  final AllBranchRemoteDataSource remoteDataSource;
  final BranchLocalDataSource localDataSource;

  BranchRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  Future<List<BranchModel>> getBranches({
    bool forceRefresh = false,
  }) async {
    try {
      final hasInternet = await _hasInternetConnection();

      if (forceRefresh && hasInternet) {
        return await _fetchFromRemoteAndCache();
      }

      if (localDataSource.isCacheValid()) {
        try {
          final cachedBranches = await localDataSource.getCachedBranches();
          print('📦 Using cached branches (${cachedBranches.length} items)');

          if (hasInternet) {
            _silentRefresh();
          }

          return cachedBranches;
        } catch (e) {
          print('⚠️ Cache read failed, fetching from remote: $e');
        }
      }

      if (hasInternet) {
        return await _fetchFromRemoteAndCache();
      }

      try {
        final cachedBranches = await localDataSource.getCachedBranches();
        print('📴 Offline: Using stale cache (${cachedBranches.length} items)');
        return cachedBranches;
      } catch (e) {
        print('❌ No cache and no internet: $e');
        throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة');
      }
    } catch (e) {
      print('❌ Repository error: $e');
      rethrow;
    }
  }

  Future<List<BranchModel>> _fetchFromRemoteAndCache() async {
    try {
      print('🌐 Fetching branches from server...');
      final Data responseData = await remoteDataSource.getBranches();

      if (responseData.data.isNotEmpty) {
        print('✅ Fetched ${responseData.data.length} branches from server');

        try {
          await localDataSource.cacheBranches(responseData.data);
        } catch (cacheError) {
        }

        return responseData.data;
      }

      return [];
    } catch (e) {
      print('❌ Remote fetch failed: $e');
      rethrow;
    }
  }

  void _silentRefresh() {
    Future.delayed(Duration.zero, () async {
      try {
        await _fetchFromRemoteAndCache();
        print('✅ Silent refresh completed');
      } catch (e) {
        print('⚠️ Silent refresh failed (non-critical): $e');
      }
    });
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      print('📡 Internet connection: ${hasConnection ? "Available" : "Not available"}');
      return hasConnection;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }
  Duration? getCacheAge() {
    return localDataSource.getCacheAge();
  }
}