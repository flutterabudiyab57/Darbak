import 'package:darbak/core/style/style.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../../../../core/helpers/SharedPreference/pereferences.dart';
import '../../../../../core/helpers/interceptors/loading_indicator.dart';
import '../../../../../language/locale.dart';
import '../../bloc/cashback__cubit.dart';
import '../../models/cashback_transactions.dart';
import '../../repository/cashback_balance.dart';
import '../../repository/applycashback.dart';

class TransactionsBottomSheet extends StatelessWidget {
  const TransactionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
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
      )..getCashbackTransactions(),
      child: const _TransactionsBottomSheetContent(),
    );
  }
}

class _TransactionsBottomSheetContent extends StatefulWidget {
  const _TransactionsBottomSheetContent();

  @override
  State<_TransactionsBottomSheetContent> createState() =>
      _TransactionsBottomSheetContentState();
}

class _TransactionsBottomSheetContentState
    extends State<_TransactionsBottomSheetContent> {
  String _selectedFilter = 'all';

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (filter == 'all') {
      context.read<CashbackCubit>().getCashbackTransactions();
    } else {
      context.read<CashbackCubit>().getCashbackTransactions(eventType: filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final isRTL = locale!.isDirectionRTL(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: ShapeDecoration(
        color: backgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.w,
                  color: strokeGrayColor(context),
                ),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 60.w,
                  height: 6.h,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFB1B1B1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                // Title and close button
                Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale.transactionsrecord.toString(),
                      style: AppTypography.mainTypographyColor18(context),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: headingColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Expanded(
                  child: _buildFilterChip(
                    isRTL ? 'الكل' : 'All',
                    'all',
                    isRTL,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildFilterChip(
                    isRTL ? 'كاش باك' : 'Cashback',
                    'issued',
                    isRTL,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildFilterChip(
                    isRTL ? 'استخدام رصيد' : 'Redeemed',
                    'redeemed',
                    isRTL,
                  ),
                ),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: BlocBuilder<CashbackCubit, CashbackState>(
              builder: (context, state) {
                if (state is CashbackLoading) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }

                if (state is CashbackDataState) {
                  if (state.isLoadingTransactions) {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  }

                  if (state.transactionsError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: Colors.red,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            isRTL
                                ? 'حدث خطأ في تحميل العمليات'
                                : 'Error loading transactions',
                            style: AppTypography.headingColor14(context),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => _applyFilter(_selectedFilter),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: iconDefaultColor(context),
                              foregroundColor: buttonTextColor(context),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              locale.retry,
                              style: AppTypography.buttonText14(context),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.transactions == null) {
                    return const Center(
                      child: LoadingIndicator(),
                    );
                  }

                  final transactions = state.transactions!.data.entries;

                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64.sp,
                            color: paragraphColor(context).withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            isRTL ? 'لا توجد عمليات' : 'No Transactions',
                            style: AppTypography.mainTypographyColor20(context),
                          ),
                        ],
                      ),
                    );
                  }

                  final groupedTransactions =
                  _groupTransactionsByMonth(transactions, isRTL);

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    itemCount: groupedTransactions.length,
                    itemBuilder: (context, index) {
                      final monthKey =
                      groupedTransactions.keys.elementAt(index);
                      final monthTransactions = groupedTransactions[monthKey]!;

                      return Column(
                        crossAxisAlignment: isRTL
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          // Month header
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Text(
                              monthKey,
                              style: AppTypography.paragraphColor14(context),
                            ),
                          ),
                          // Month transactions
                          ...monthTransactions.map((transaction) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: buttonWhiteColor(context),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  width: 1.5.w,
                                  color: strokeGrayColor(context),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _TransactionItem(
                                transaction: transaction,
                                isRTL: isRTL,
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filter, bool isRTL) {
    final isSelected = _selectedFilter == filter;

    return InkWell(
      onTap: () => _applyFilter(filter),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
        decoration: ShapeDecoration(
          color: isSelected
              ? iconDefaultColor(context)
              : buttonWhiteColor(context),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.4.w,
              color: isSelected
                  ? iconDefaultColor(context)
                  : strokeGrayColor(context),
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: isSelected
                ? AppTypography.buttonText14(context)
                : AppTypography.paragraphColor14(context),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Map<String, List<TransactionEntry>> _groupTransactionsByMonth(
      List<TransactionEntry> transactions, bool isRTL) {
    final Map<String, List<TransactionEntry>> grouped = {};

    for (var transaction in transactions) {
      final monthKey = _getMonthKey(transaction.createdAtLocal, isRTL);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }

    return grouped;
  }

  String _getMonthKey(String dateStr, bool isRTL) {
    try {
      final parts = dateStr.split(' ');
      if (parts.isNotEmpty) {
        final dateParts = parts[0].split('-');
        if (dateParts.length == 3) {
          final year = dateParts[0];
          final month = isRTL
              ? _getArabicMonth(int.parse(dateParts[1]))
              : _getEnglishMonth(int.parse(dateParts[1]));
          return '$month $year';
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

  String _getEnglishMonth(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionEntry transaction;
  final bool isRTL;

  const _TransactionItem({
    required this.transaction,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icon and details
        Expanded(
          child: Row(
            textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: ShapeDecoration(
                  color: _getTransactionColor(transaction.eventType)
                      .withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1.w,
                      color: _getTransactionColor(transaction.eventType),
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Icon(
                  _getTransactionIcon(transaction.eventType),
                  color: _getTransactionColor(transaction.eventType),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: isRTL
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTransactionTitle(transaction.eventType, isRTL),
                      style: AppTypography.headingColor14(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(transaction.createdAtLocal, isRTL),
                      style: AppTypography.paragraphColor12(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        // Amount
        Row(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${transaction.sign}${transaction.amount.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'ThmanyahSans',
                color: _getTransactionColor(transaction.eventType),
              ),
            ),
            SizedBox(width: 4.w),
            SvgPicture.asset(
              Assets.icon_riyal,
              height: 16.h,
              width: 16.w,
              color: _getTransactionColor(transaction.eventType),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(String dateStr, bool isRTL) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length == 2) {
        final dateParts = parts[0].split('-');
        final timeParts = parts[1].split(':');

        if (dateParts.length == 3 && timeParts.length >= 2) {
          final month = isRTL
              ? _getArabicMonth(int.parse(dateParts[1]))
              : _getEnglishMonth(int.parse(dateParts[1]));
          final day = dateParts[2];
          final hour = int.parse(timeParts[0]);
          final minute = timeParts[1];

          if (isRTL) {
            final period = hour >= 12 ? 'م' : 'ص';
            final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
            return '$day $month، $displayHour:$minute $period';
          } else {
            final period = hour >= 12 ? 'PM' : 'AM';
            final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
            return '$month $day, $displayHour:$minute $period';
          }
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

  String _getEnglishMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getTransactionTitle(String eventType, bool isRTL) {
    if (isRTL) {
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
    } else {
      switch (eventType) {
        case 'redeemed':
          return 'Balance Used';
        case 'issued':
          return 'Cashback Earned';
        case 'revoked':
          return 'Refund - Customer Service';
        default:
          return 'Other Transaction';
      }
    }
  }

  IconData _getTransactionIcon(String eventType) {
    switch (eventType) {
      case 'issued':
        return Icons.arrow_downward_rounded;
      case 'redeemed':
        return Icons.arrow_upward_rounded;
      case 'revoked':
        return Icons.refresh_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Color _getTransactionColor(String eventType) {
    switch (eventType) {
      case 'redeemed':
        return const Color(0xFFBA1B1B);
      case 'issued':
        return const Color(0xFF007A55);
      case 'revoked':
        return const Color(0xFF155DFC);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}