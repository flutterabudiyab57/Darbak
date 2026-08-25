import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final locale = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/Monthly_Packages.svg',
              width: 60.w,
              height: 60.h,
            ),
            SizedBox(height: 6.h),
            AutoSizeText(
              locale.monthlyPackages,
              textAlign: TextAlign.center,
              style: AppTypography.headingColor20(context).copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
            ),
            SizedBox(height: 6.h),
            AutoSizeText(
              locale.chooseMonthlyPackage,
              textAlign: TextAlign.center,
              style: AppTypography.paragraphColor16(context),
              maxLines: 1,
            ),
            SizedBox(height: 6.h),
            Container(
              width: 156.w,
              height: 40.h,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2.w,
                    color: headingColor(context),
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: headingColor(context),
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      locale.discover,
                      textAlign: TextAlign.center,
                      style: AppTypography.headingColor16(context).copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
