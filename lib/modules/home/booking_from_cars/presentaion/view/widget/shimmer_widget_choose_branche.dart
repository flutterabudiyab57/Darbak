import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffectWidget extends StatelessWidget {
  const ShimmerEffectWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            height: size.height * 0.2,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                ShimmerBox(height: 40.h, width: double.infinity),
                SizedBox(height: 10.h),
                ShimmerBox(height: 40.h, width: double.infinity),
                SizedBox(height: 10.h),
                ShimmerBox(height: 40.h, width: double.infinity),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    ShimmerBox(
                      width: 170.w,
                      height: 130.h,
                    ),
                    Spacer(),
                    ShimmerBox(
                      width: 120.w,
                      height: 130.h,
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ShimmerBox(height: 60, width: double.infinity),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;

  const ShimmerBox({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
