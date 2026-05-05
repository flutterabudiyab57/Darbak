import 'dart:developer';
import 'package:darbak/modules/home/all_branching/bloc/all_branching_state.dart';
import 'package:darbak/modules/home/all_branching/data/models/branch_model.dart';
import 'package:bloc/bloc.dart';

import '../data/BranchRepository.dart';

class AllBranchCubit extends Cubit<AllBranchState> {
  final BranchRepository branchRepository;

  AllBranchCubit(this.branchRepository) : super(AllBranchInitial());

  List<BranchModel> branchesData = [];

  Future<void> getAllBranch({bool forceRefresh = false}) async {
    emit(AllBranchLoading());

    try {
      branchesData = await branchRepository.getBranches(
        forceRefresh: forceRefresh,
      );

      if (branchesData.isEmpty) {
        emit(AllBranchError(error: 'لا توجد فروع متاحة'));
        return;
      }

      emit(AllBranchLoaded(branchModel: branchesData));
      log('✅ Loaded ${branchesData.length} branches');

      // Show cache age in console
      final cacheAge = branchRepository.getCacheAge();
      if (cacheAge != null) {
        log('📅 Cache age: ${cacheAge.inMinutes} minutes');
      }
    } catch (e, stackTrace) {
      log('❌ Error in AllBranchCubit: $e\n$stackTrace');

      // Provide user-friendly error messages
      String errorMessage;
      if (e.toString().contains('لا يوجد اتصال')) {
        errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى';
      } else if (e.toString().contains('No cached')) {
        errorMessage = 'لا توجد بيانات محفوظة. يرجى الاتصال بالإنترنت';
      } else {
        errorMessage = 'حدث خطأ أثناء تحميل الفروع: ${e.toString()}';
      }

      emit(AllBranchError(error: errorMessage));
    }
  }

  /// Force refresh (for pull to refresh)
  Future<void> refreshBranches() async {
    await getAllBranch(forceRefresh: true);
  }

  /// Clear cache
  Future<void> clearBranchesCache() async {
    try {
      await branchRepository.clearCache();
      branchesData.clear();
      emit(AllBranchInitial());
      log('🗑️ Branches cache cleared');
    } catch (e) {
      log('❌ Error clearing cache: $e');
    }
  }

  /// Get cache information for UI
  String getCacheInfo() {
    final age = branchRepository.getCacheAge();
    if (age == null) return 'لا توجد بيانات مخزنة';

    if (age.inMinutes < 1) {
      return 'آخر تحديث: الآن';
    } else if (age.inMinutes < 60) {
      return 'آخر تحديث: منذ ${age.inMinutes} دقيقة';
    } else if (age.inHours < 24) {
      return 'آخر تحديث: منذ ${age.inHours} ساعة';
    } else {
      return 'آخر تحديث: منذ ${age.inDays} يوم';
    }
  }
}