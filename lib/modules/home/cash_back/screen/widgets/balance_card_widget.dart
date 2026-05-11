import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../models/cashbackbalance.dart';


class BalanceCardWidget extends StatelessWidget {
  final BalanceData balance;
  final AppLocalizations locale;

  const BalanceCardWidget({
    super.key,
    required this.balance,
    required this.locale,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: ShapeDecoration(
        color: strokeMainColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        shadows: [
          BoxShadow(
            color: const Color(0x3300BC7D),
            blurRadius: 6,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                Assets.icon_wallet,
                height: 20.h,
                width: 21.w,
                color: backgroundColor(context),
              ),
              SizedBox(width: 8.w),
              Text(
                locale.availableBalance,
                style: AppTypography.buttonText20(context),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                balance.availableBalance.toString(),
                style: AppTypography.buttonText36(context),
              ),
              SizedBox(width: 10.w),
              SvgPicture.asset(
                Assets.icon_riyal,
                height: 28.h,
                width: 30.w,
                color: buttonTextColor(context),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.w,
              vertical: 9.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xff00FF8B),
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    locale.autoDeductBalance,
                    style: AppTypography.buttonText14(context),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}