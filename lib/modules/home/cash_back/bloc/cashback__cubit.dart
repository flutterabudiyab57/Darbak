import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/cashbackbalance.dart';
import '../models/cashback_transactions.dart';
import '../models/apply_cashback_response.dart';
import '../repository/applycashback.dart';
import '../repository/cashback_balance.dart';

part 'cashback__state.dart';

class CashbackCubit extends Cubit<CashbackState> {
  final CashbackRemoteDataSource _remoteDataSource;
  final ApplyCashbackRemoteDataSource _applyCashbackDataSource;

  CashbackCubit(this._remoteDataSource, this._applyCashbackDataSource)
      : super(const CashbackInitial());

  Future<void> initialize() async {
    emit(const CashbackLoading());
    try {
      final results = await Future.wait([
        _remoteDataSource.getCashbackBalance(),
        _remoteDataSource.getCashbackTransactions(),
      ]);

      emit(CashbackDataState(
        cashbackBalance: results[0] as CashbackBalance,
        transactions: results[1] as CashbackTransactions,
        isLoadingBalance: false,
        isLoadingTransactions: false,
      ));
    } catch (error) {
      print('Initialize error: $error');
      emit(CashbackError(message: error.toString()));
    }
  }

  Future<void> getCashbackBalance() async {
    if (state is CashbackDataState) {
      final currentState = state as CashbackDataState;
      emit(currentState.copyWith(isLoadingBalance: true, balanceError: null));
    } else {
      emit(const CashbackLoading());
    }

    try {
      final cashbackBalance = await _remoteDataSource.getCashbackBalance();

      if (state is CashbackDataState) {
        final currentState = state as CashbackDataState;
        emit(currentState.copyWith(
          cashbackBalance: cashbackBalance,
          isLoadingBalance: false,
        ));
      } else {
        emit(CashbackDataState(
          cashbackBalance: cashbackBalance,
          isLoadingBalance: false,
        ));
      }
    } catch (error) {
      print('Get balance error: $error');
      if (state is CashbackDataState) {
        final currentState = state as CashbackDataState;
        emit(currentState.copyWith(
          isLoadingBalance: false,
          balanceError: error.toString(),
        ));
      } else {
        emit(CashbackError(message: error.toString()));
      }
    }
  }

  Future<void> refreshCashbackBalance() async {
    await getCashbackBalance();
  }

  Future<void> getCashbackTransactions({
    String? eventType,
    String? recordState,
    String direction = 'desc',
  }) async {
    if (state is CashbackDataState) {
      final currentState = state as CashbackDataState;
      emit(currentState.copyWith(
        isLoadingTransactions: true,
        transactionsError: null,
      ));
      try {
        final transactions = await _remoteDataSource.getCashbackTransactions(
          eventType: eventType,
          recordState: recordState,
          direction: direction,
        );
        emit(currentState.copyWith(
          transactions: transactions,
          isLoadingTransactions: false,
        ));
      } catch (error) {
        print('Get transactions error: $error');
        emit(currentState.copyWith(
          isLoadingTransactions: false,
          transactionsError: error.toString(),
        ));
      }
    } else {
      emit(const CashbackLoading());
      try {
        final transactions = await _remoteDataSource.getCashbackTransactions(
          eventType: eventType,
          recordState: recordState,
          direction: direction,
        );
        emit(CashbackDataState(
          transactions: transactions,
          isLoadingTransactions: false,
        ));
      } catch (error) {
        print('Get transactions error: $error');
        emit(CashbackError(message: error.toString()));
      }
    }
  }

  Future<void> refreshCashbackTransactions({
    String? eventType,
    String? recordState,
    String direction = 'desc',
  }) async {
    await getCashbackTransactions(
      eventType: eventType,
      recordState: recordState,
      direction: direction,
    );
  }

  Future<void> refreshAll() async {
    if (state is CashbackDataState) {
      final currentState = state as CashbackDataState;
      emit(currentState.copyWith(
        isLoadingBalance: true,
        isLoadingTransactions: true,
      ));

      try {
        // Fetch both in parallel for better performance
        final results = await Future.wait([
          _remoteDataSource.getCashbackBalance(),
          _remoteDataSource.getCashbackTransactions(),
        ]);

        emit(currentState.copyWith(
          cashbackBalance: results[0] as CashbackBalance,
          transactions: results[1] as CashbackTransactions,
          isLoadingBalance: false,
          isLoadingTransactions: false,
        ));
      } catch (error) {
        print('Refresh all error: $error');
        emit(currentState.copyWith(
          isLoadingBalance: false,
          isLoadingTransactions: false,
          balanceError: error.toString(),
        ));
      }
    } else {
      await initialize();
    }
  }

  Future<void> applyCashbackToOrder({
    required String orderId,
    required double amount,
  }) async {
    if (state is CashbackDataState) {
      final currentState = state as CashbackDataState;

      emit(currentState.copyWith(
        isApplyingCashback: true,
        applyCashbackError: null,
        applyCashbackResponse: null,
      ));

      try {
        final response = await _applyCashbackDataSource.applyCashbackToOrder(
          orderId: orderId,
          amount: amount,
        );

        emit(currentState.copyWith(
          isApplyingCashback: false,
          applyCashbackResponse: response,
        ));

        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState.copyWith(
          applyCashbackResponse: null,
        ));

        await refreshCashbackBalance();
      } catch (error) {
        print('Apply cashback error: $error');
        emit(currentState.copyWith(
          isApplyingCashback: false,
          applyCashbackError: error.toString(),
        ));

        await Future.delayed(const Duration(milliseconds: 100));
        emit(currentState.copyWith(
          applyCashbackError: null,
        ));
      }
    }
  }
}