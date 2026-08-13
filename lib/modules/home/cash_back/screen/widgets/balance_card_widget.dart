import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../../../core/constants/assets/app_colors.dart';
import '../../../../../../../language/locale.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../../../../core/style/figma_gradient_box.dart';
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
    return FigmaGradientBox(
      figmaWidth: 360,
      figmaHeight: 171,
      gradientStart: const Offset(2, 0),
      gradientEnd: const Offset(134.545, 279.041),
      colors: const [Color(0xFF021E45), Color(0xFF2172EF)],
      stops: const [0.0, 1.0],
      borderRadius: BorderRadius.circular(24.r),
      padding: EdgeInsets.all(24.w),
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
                style: AppTypography.buttonText16(context),
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
                height: 27.h,
                width: 30.w,
                color: buttonTextColor(context),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
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