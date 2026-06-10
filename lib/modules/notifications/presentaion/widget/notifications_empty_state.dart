import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    // Reuses the shared empty-state illustration (no dedicated asset in Figma).
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/emptystate.png', width: 220.w),
          SizedBox(height: 15.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              locale.notificationsEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: paragraphColor(context),
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
