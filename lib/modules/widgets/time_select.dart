import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/assets/app_colors.dart';
import '../../core/style/style.dart';
import '../../language/locale.dart';
import '../home/search_screen/presentaion/widget/select_day_and_time.dart';

class TimeSelectTwoBox extends StatelessWidget {
  const TimeSelectTwoBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale!.selectDateAndTime.toString(),
          style: AppTypography.headingColor18(context),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: bg2Color(context),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0x2D000000),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: SelectDayAndTimeWidget(isReceive: true)),
              SizedBox(width: 6.w),
              Expanded(child: SelectDayAndTimeWidget(isReceive: false)),
            ],
          ),
        ),
      ],
    );
  }
}
