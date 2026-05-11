part of 'cashback__cubit.dart';

@immutable
abstract class CashbackState extends Equatable {
  const CashbackState();

  @override
  List<Object?> get props => [];
}

class CashbackInitial extends CashbackState {
  const CashbackInitial();
}

class CashbackLoading extends CashbackState {
  const CashbackLoading();
}

class CashbackDataState extends CashbackState {
  final CashbackBalance? cashbackBalance;
  final CashbackTransactions? transactions;
  final bool isLoadingBalance;
  final bool isLoadingTransactions;
  final String? balanceError;
  final String? transactionsError;
  final bool isApplyingCashback;
  final ApplyCashbackResponse? applyCashbackResponse;
  final String? applyCashbackError;

  const CashbackDataState({
    this.cashbackBalance,
    this.transactions,
    this.isLoadingBalance = false,
    this.isLoadingTransactions = false,
    this.balanceError,
    this.transactionsError,
    this.isApplyingCashback = false,
    this.applyCashbackResponse,
    this.applyCashbackError,
  });
  CashbackDataState copyWith({
    CashbackBalance? cashbackBalance,
    CashbackTransactions? transactions,
    bool? isLoadingBalance,
    bool? isLoadingTransactions,
    String? balanceError,
    String? transactionsError,
    bool? isApplyingCashback,
    ApplyCashbackResponse? applyCashbackResponse,
    String? applyCashbackError,
  }) {
    return CashbackDataState(
      cashbackBalance: cashbackBalance ?? this.cashbackBalance,
      transactions: transactions ?? this.transactions,
      isLoadingBalance: isLoadingBalance ?? this.isLoadingBalance,
      isLoadingTransactions: isLoadingTransactions ?? this.isLoadingTransactions,
      balanceError: balanceError,
      transactionsError: transactionsError,
      isApplyingCashback: isApplyingCashback ?? this.isApplyingCashback,
      applyCashbackResponse: applyCashbackResponse,
      applyCashbackError: applyCashbackError,
    );
  }


  @override
  List<Object?> get props => [
    cashbackBalance,
    transactions,
    isLoadingBalance,
    isLoadingTransactions,
    balanceError,
    transactionsError,
    isApplyingCashback,
    applyCashbackResponse,
    applyCashbackError,
  ];
}

class CashbackError extends CashbackState {
  final String message;

  const CashbackError({required this.message});

  @override
  List<Object?> get props => [message];
}