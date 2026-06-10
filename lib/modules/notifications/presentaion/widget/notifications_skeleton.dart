import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Loading placeholder mirroring the notification card layout.
class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(height: 15.h),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300, width: 1.5.w),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone.square(
                  size: 40.w,
                  borderRadius: BorderRadius.all(Radius.circular(10.r)),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone.text(width: 80.w, fontSize: 12.sp),
                      SizedBox(height: 8.h),
                      Bone.text(width: 140.w, fontSize: 14.sp),
                      SizedBox(height: 6.h),
                      Bone.text(width: double.infinity, fontSize: 12.sp),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
