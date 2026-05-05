import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/assets/app_colors.dart';

Widget dashedDivider(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final dashWidth = 10.w;
      final dashSpace = 6.w;
      final dashCount =
      (constraints.maxWidth / (dashWidth + dashSpace)).floor();

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          dashCount,
              (_) => SizedBox(
            width: dashWidth,
            height: 2.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: strokeGrayColor(context),
              ),
            ),
          ),
        ),
      );
    },
  );
}
