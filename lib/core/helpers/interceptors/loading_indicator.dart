import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingIndicator extends StatelessWidget {
  final double? width;
  final double? height;

  const LoadingIndicator({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 3.w,
      )

      // Lottie.asset(
      //   'assets/anim/loading_Indicator.json',
      //   width: width ?? 100.w,
      //   height: height ?? 100.h,
      //   fit: BoxFit.contain,
      //   repeat: true,
      //   animate: true,
      // ),
    );
  }
}
