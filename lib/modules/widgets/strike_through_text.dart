import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';

class StrikethroughText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const StrikethroughText({
    Key? key,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style ??
              TextStyle(
                fontFamily: "IBMPlexSansArabic",
                fontSize: 14.sp,
                color: paragraphColor(context),
              ),
        ),
        Positioned.fill(
          child: Center(
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                height: 2.h,
                margin: EdgeInsets.symmetric(horizontal: 2.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0004),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}