import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/assets/app_colors.dart';

class CarIconInfo extends StatelessWidget {
  const CarIconInfo({
    Key? key,
    required this.image,
    required this.text,
    this.text2,
    this.backgroundColor,
    this.description,
  }) : super(key: key);

  final String image;
  final String text;
  final String? text2;
  final String? description;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
      minWidth: 60.ws(context),
    ),
      margin: EdgeInsets.all(4.sp),
      padding: EdgeInsets.all(4.sp),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border.all(
          color: strokeGrayColor(context),
          width: 1.w,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          SizedBox(height: 5.h),
          SizedBox(
            width: 30.w,
            height: 28.h,
            child: SvgPicture.asset(image, fit: BoxFit.contain,color: iconGrayColor(context),),

          ),
          SizedBox(height: 10.h),
          if (description != null && description!.isNotEmpty)
            AutoSizeText(
              description!,
              style: AppTypography.paragraphColor12(context),
            ),
          if (description != null && description!.isNotEmpty)
            SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoSizeText(
                text,
                style: AppTypography.headingColor16(context),
              ),
              if (text2 != null && text2!.isNotEmpty) ...[
                AutoSizeText(
                  text2!,
                  style: AppTypography.paragraphColor12(context),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}
