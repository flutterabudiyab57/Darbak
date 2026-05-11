import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../../core/constants/assets/assets.dart';
class BuildEmptyCar extends StatelessWidget {
  final String? title;

  const BuildEmptyCar({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Lottie.asset(
              Assets.img_empty_anim,
              width: 300.w,
            ),
          ),
          if (title != null) ...[
            SizedBox(height: 30.h),
            Text(
              title!,
              style: AppTypography.mainTypographyColor20(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
