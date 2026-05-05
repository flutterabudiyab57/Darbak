import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';

class CardTileWidget extends StatelessWidget {
  CardTileWidget({
    Key? key,
    required this.title,
    this.icon,
    required this.ontap,
    this.textcolor,
    this.isLogout = false,
    this.isBorder = true,
  }) : super(key: key);

  final String title;
  final String? icon;
  final bool isLogout;
  final bool isBorder;
  final Function()? ontap;
  final Color? textcolor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          height: 55.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: isBorder
                ? Border.all(
              color: Colors.grey,
              width: 2.w,
            )
                : null,
          ),
          child: Row(
            children: [
              if (icon != null)
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: SvgPicture.asset(
                    icon!,
                    color: textcolor ?? iconDefaultColor(context),
                  ),
                ),
              if (icon != null) SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headingColor18(context),
                ),
              ),
              if (!isLogout)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textcolor ?? mainTypographyColor(context),
                  size: 28.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
