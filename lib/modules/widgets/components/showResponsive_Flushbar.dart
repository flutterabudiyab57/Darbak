import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveFlushbar {
  static void show(
      BuildContext context, {
        required String message,
        Color textColor = Colors.white,
        Color backgroundColor = Colors.green,
        double fontSize = 14,
        int maxLines = 3,
        Duration duration = const Duration(seconds: 3),
      }) {
    Flushbar(
      message: message,
      messageSize: fontSize.sp,
      messageColor: textColor,
      duration: duration,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      backgroundColor: backgroundColor,
      margin: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      icon: Icon(
        (backgroundColor == Colors.red || backgroundColor == const Color(0xffF6A9A9))
            ? Icons.error_outline
            : Icons.check_circle_outline,
        color: textColor,
        size: 24.sp,
      ),
    )..show(context);
  }
}
