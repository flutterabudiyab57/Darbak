import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';

import '../../../../../core/constants/assets/app_colors.dart';

class MonthlyPackageWidget extends StatelessWidget {
  final VoidCallback onTap;

  const MonthlyPackageWidget({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: strokeGrayColor(context), width: 2.w),
          image: DecorationImage(
            image: AssetImage(
              Theme.of(context).brightness == Brightness.light
                  ? "assets/images/back_ground_packat.png"
                  : "assets/images/back_ground_packat_dark.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Row(
          children: [
            Image.asset(
              locale!.isDirectionRTL(context)
                  ? "assets/images/monthly_ar.png"
                  : "assets/images/monthly_en.png",
              width: 85.w,
              height: 38.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    Directionality.of(context) == TextDirection.rtl
                        ? "الباقات الشهرية"
                        : "Monthly packages",
                    style: AppTypography.mainTypographyColor16(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  AutoSizeText(
                    Directionality.of(context) == TextDirection.rtl
                        ? "أختر باقتك الشهرية المناسبة لك"
                        : "Choose the monthly package that suits you",
                    style: AppTypography.headingColor16(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}