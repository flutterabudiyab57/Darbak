import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/style/style.dart';

class ADUploadLicense extends StatelessWidget {
  final String text;
  final String? displayImage;

  const ADUploadLicense({
    Key? key,
    required this.displayImage,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      margin: EdgeInsets.symmetric(vertical: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50.r),
              topRight: Radius.circular(50.r))),
      child: displayImage != ""
          ? SizedBox(
              width: double.infinity,
              child: Image.file(
                File(displayImage!),
                fit: BoxFit.fill,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.camera_enhance,
                  color: Colors.white,
                  size: 24.sp,
                ),
                Text(
                  text,
                  style: AppTypography.buttonText18(context).copyWith(
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.add, color: Colors.white, size: 28.sp),
              ],
            ),
    );
  }
}
