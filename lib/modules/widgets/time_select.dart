import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/assets/app_colors.dart';
import '../../core/style/style.dart';
import '../../language/locale.dart';
import '../home/search_screen/presentaion/widget/select_day_and_time.dart';
import '../location/data/models/branch_work_time.dart';

class TimeSelectTwoBox extends StatelessWidget {
  /// T038 guarding, opt-in. `false` (the default) keeps every pre-existing
  /// call site — airport, delivery, monthly, book-from-car — byte-for-byte
  /// on the old unrestricted-except-past-slots behaviour. Only daily rent
  /// passes `true`.
  final bool enableGuarding;
  final BranchWorkTime? pickupWorkTime;
  final BranchWorkTime? dropoffWorkTime;

  const TimeSelectTwoBox({
    Key? key,
    this.enableGuarding = false,
    this.pickupWorkTime,
    this.dropoffWorkTime,
  }) : super(key: key);

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
              Expanded(
                child: SelectDayAndTimeWidget(
                  isReceive: true,
                  enableGuarding: enableGuarding,
                  workTime: pickupWorkTime,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: SelectDayAndTimeWidget(
                  isReceive: false,
                  enableGuarding: enableGuarding,
                  workTime: dropoffWorkTime,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
