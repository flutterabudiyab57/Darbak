import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ShimmerLoadingList extends StatelessWidget {
  final int itemCount;
  final int? height;

  const ShimmerLoadingList({Key? key, this.itemCount = 5, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: itemCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.w),
            child: Container(
              width: double.infinity,
              height: height?.h ?? 140.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        },
      ),
    );
  }
}
