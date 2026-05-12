import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/style/style.dart';
import '../../language/locale.dart';
import '../home/search_screen/presentaion/widget/select_day_and_time.dart';

Widget time_select_twoBox(BuildContext context) {
  final locale = AppLocalizations.of(context);
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale!.selectDateAndTime.toString(),
          style: AppTypography.headingColor18(context),
        ),
        SizedBox(height: 14.h),
        SelectDayAndTimeWidget(isReceive: true),
        SizedBox(height: 10.h),
        // Center(
        //   child: Cont ainer(
        //     padding: EdgeInsets.all(6.r),
        //     decoration: BoxDecoration(
        //       color: mainTypographyColor(context).withOpacity(0.08),
        //       shape: BoxShape.circle,
        //     ),
        //     child: Icon(
        //       Icons.arrow_downward_rounded,
        //       size: 35.r,
        //       color: mainTypographyColor(context),
        //     ),
        //   ),
        // ),
        SizedBox(height: 10.h),
        SelectDayAndTimeWidget(isReceive: false),
      ],
    ),
  );
}