import 'package:darbak/core/style/style.dart';
import 'package:darbak/modules/home/cash_back/screen/widgets/balance_card_widget.dart';
import 'package:darbak/modules/home/cash_back/screen/widgets/pending_card_widget.dart';
import 'package:darbak/modules/home/cash_back/screen/widgets/transaction_item_widget.dart';
import 'package:darbak/modules/home/cash_back/screen/widgets/transactions_bottom_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../language/locale.dart';
import '../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../widgets/Dashed_divider.dart';
import '../../../widgets/components/appbar.dart';
import '../../profile/page/widget/container_tile.dart';
import '../bloc/cashback__cubit.dart';
import '../models/cashback_transactions.dart';
import '../repository/applycashback.dart';
import '../repository/cashback_balance.dart';


class CashbackScreen extends StatelessWidget {
  const CashbackScreen({super.key});

  void _showAllTransactions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: double.infinity,),
      builder: (context) => const TransactionsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => CashbackCubit(
        CashbackRemoteDataSource(
          Dio(),
          SharedPreferencesHelper(),
        ),
        ApplyCashbackRemoteDataSource(
          Dio(),
          SharedPreferencesHelper(),
        ),
      )..initialize(),
      child: Scaffold(
        backgroundColor: backgroundColor(context),
        appBar: CustomAppBar(
          title: locale.wallet.toString(),
          showBackButton: true,
          // showThemeToggle: true,
        ),
        body: BlocBuilder<CashbackCubit, CashbackState>(
          builder: (context, state) {
            print('Current state: $state');

            if (state is CashbackLoading) {
              return const Center(
                child: LoadingIndicator(),
              );
            }

            if (state is CashbackError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'حدث خطأ أثناء تحميل البيانات',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: headingColor(context),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CashbackCubit>().initialize();
                      },
                      child:  Text(locale.retry),
                    ),
                  ],
                ),
              );
            }

            if (state is CashbackDataState) {
              if (state.cashbackBalance == null && state.isLoadingBalance) {
                return const Center(child: LoadingIndicator());
              }

              if (state.cashbackBalance == null && state.balanceError != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'حدث خطأ في تحميل الرصيد',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: headingColor(context),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: Text(
                          state.balanceError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: paragraphColor(context),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CashbackCubit>().initialize();
                        },
                        child:   Text(locale.retry),
                      ),
                    ],
                  ),
                );
              }

              if (state.cashbackBalance == null) {
                return const Center(child: LoadingIndicator());
              }

              final balance = state.cashbackBalance!.data;

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<CashbackCubit>().refreshAll();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.isDirectionRTL(context)?
                        "تابع رصيدك ومدفوعاتك في مكان واحد":"Track your balance and payments in one place",
                        textAlign: TextAlign.center,
                        style: AppTypography.paragraphColor16(context),
                      ),
                      SizedBox(height: 15.h),

                      BalanceCardWidget(balance: balance, locale: locale),
                      SizedBox(height: 12.h),

                      if (balance.summary.pending.total > 0)
                        PendingCardWidget(balance: balance),
                      if (balance.summary.pending.total > 0) SizedBox(height: 24.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale.transactionsrecord.toString(),
                            style: AppTypography.mainTypographyColor18(context),
                          ),
                          TextButton(
                            onPressed: () => _showAllTransactions(context),
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.r),
                                  side: BorderSide(
                                    color: strokeGrayColor(context),
                                    width: 1.w,
                                  ),
                                ),
                                backgroundColor:buttonWhiteColor(context)

                            ),
                            child: Text(
                                locale.viewAll.toString(),
                                style: AppTypography.paragraphColor14(context)
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      _buildTransactionsList(context, state),

                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              );
            }

            return const Center(child: LoadingIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, CashbackDataState state) {
    final locale = AppLocalizations.of(context)!;
    if (state.isLoadingTransactions) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: const LoadingIndicator(),
        ),
      );
    }

    if (state.transactionsError != null) {
      return Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Colors.red,
            ),
            SizedBox(height: 8.h),
            Text(
              'حدث خطأ في تحميل العمليات',
              style: TextStyle(
                fontSize: 14.sp,
                color: headingColor(context),
              ),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () {
                context.read<CashbackCubit>().getCashbackTransactions();
              },
              child:   Text(locale.retry),
            ),
          ],
        ),
      );
    }

    if (state.transactions == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: const LoadingIndicator(),
        ),
      );
    }

    final transactions = state.transactions!.data.entries;

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64.sp,
                color: paragraphColor(context).withOpacity(0.5),
              ),
              SizedBox(height: 16.h),
              Text(
                "لا توجد عمليات حتى الآن",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: paragraphColor(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final limitedTransactions = transactions.take(4).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedTransactions.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final transaction = limitedTransactions[index];

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: strokeGrayColor(context),
              width: 1.5.w,
            ),
          ),
          child: ContainerTileWidget(
            widgets: [
              TransactionItemWidget(
                title: _getTransactionTitle(transaction.eventType),
                date: _formatDate(transaction.createdAtLocal),
                amount: "${transaction.sign}${transaction.amount.toStringAsFixed(0)}",
                isPositive: transaction.isCredit,
                icon: _getTransactionIcon(transaction.eventType),
                iconColor: _getTransactionColor(transaction.eventType),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length == 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');

        if (dateParts.length == 3 && timeParts.length >= 2) {
          final month = _getArabicMonth(int.parse(dateParts[1]));
          final day = dateParts[2];
          final hour = int.parse(timeParts[0]);
          final minute = timeParts[1];

          final period = hour >= 12 ? 'م' : 'ص';
          final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

          return '$day $month، $displayHour:$minute $period';
        }
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _getArabicMonth(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return months[month - 1];
  }

  String _getTransactionTitle(String eventType) {
    switch (eventType) {
      case 'redeemed':
        return 'استخدام رصيد';
      case 'issued':
        return 'كاش باك';
      case 'revoked':
        return 'تعويض - خدمة العملاء';
      default:
        return 'عملية أخرى';
    }
  }

  IconData _getTransactionIcon(String eventType) {
    switch (eventType) {
      case 'issued':
        return Icons.arrow_downward;
      case 'redeemed':
        return Icons.arrow_upward;
      case 'revoked':
        return Icons.refresh;
      default:
        return Icons.headset_mic_outlined;
    }
  }

  Color _getTransactionColor(String eventType) {
    switch (eventType) {
      case 'redeemed':
        return buttonRedLight;
      case 'issued':
        return buttongreenLight;
      case 'revoked':
        return const Color(0xFF155DFC);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}