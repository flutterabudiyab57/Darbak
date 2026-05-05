import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/assets/app_colors.dart';
import '../../core/style/style.dart';
import '../../language/locale.dart';

void showErrorAlertDialog(BuildContext context, String text) {
  final locale = AppLocalizations.of(context);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/anim/error_anim.json',
              height: 80.h,
              width: 100.w,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.mainTypographyColor16(context),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: buttonPrimaryBgColor(context),
                padding: EdgeInsets.symmetric(vertical: 4.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                locale!.isDirectionRTL(context) ? "حسنأ" : "OK",
                style: AppTypography.buttonText18(context),
              ),
            ),
          ),
        ],
      );
    },
  );
}
