import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/language/locale.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/constants/assets/assets.dart';

class CashbackReward extends StatelessWidget {
  final int cashbackAmount;

  const CashbackReward({
    Key? key,
    required this.cashbackAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: backgroundColor(context).withOpacity(0.1),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.w,
            color: strokeGrayColor(context),
          ),
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35.w,
            height: 35.h,
            decoration: ShapeDecoration(
              color: buttonWhiteColor(context),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1.5.w,
                  color: strokeGrayColor(context),
                ),
                borderRadius: BorderRadius.circular(50.r),
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                Assets.icon_wallet,
                height: 16.h,
                width: 17.w,
                color: iconDefaultColor(context),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  locale.isDirectionRTL(context)
                      ? "مكافأتك بعد الرحلة 🎉"
                      : "Your reward after the trip 🎉",
                  style: AppTypography.headingColor12(context)),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Text(
                      locale.isDirectionRTL(context)
                          ? "خلص رحلتك واستمتع بـ"
                          : "Finish your trip and enjoy",
                      style: AppTypography.mainTypographyColor14(context)),
                  SizedBox(width: 6.w),
                  Text(
                    cashbackAmount.toString(),
                    style: TextStyle(
                      color: mainTypographyColor(context),
                      fontSize: 14.sp,
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SvgPicture.asset(
                    Assets.icon_riyal,
                    height: 14.h,
                    width: 14.w,
                    color: mainTypographyColor(context),
                  ),
                  SizedBox(width: 6.w),
                  Text(locale.isDirectionRTL(context) ? "كاش باك" : "Cashback",
                      style: AppTypography.mainTypographyColor14(context)),
                ],
              ),
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }
}
