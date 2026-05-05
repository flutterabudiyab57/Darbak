// pending_card_widget.dart
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../language/locale.dart';
import '../../models/cashbackbalance.dart';

class PendingCardWidget extends StatelessWidget {
  final BalanceData balance;

  const PendingCardWidget({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final isRTL = locale.isDirectionRTL(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF007A55).withOpacity(.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF007A55),
          width: 1.5.w,
        ),
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: Color(0xFFD0FAE5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: const Color(0xFF007A55),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: isRTL
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Text(
                      "🎉",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        isRTL
                            ? "رصيد قيد الإضافة"
                            : "Pending Balance",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'IBMPlexSansArabic',
                          color: const Color(0xFF2D6A3E),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  isRTL
                      ? "ستحصل على ${balance.summary.pending.total.toStringAsFixed(0)} ${balance.currency} كاش باك قريباً"
                      : "You will receive ${balance.summary.pending.total.toStringAsFixed(0)} ${balance.currency} cashback soon",
                  style: AppTypography.paragraphColor14(context),
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}