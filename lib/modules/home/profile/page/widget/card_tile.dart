import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/helpers/text_scale_sizing.dart';
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
    this.trailing,
    this.margin,
  }) : super(key: key);

  final String title;
  final String? icon;
  final bool isLogout;
  final bool isBorder;
  final Function()? ontap;
  final Color? textcolor;

  /// Replaces the trailing chevron. Use it when the tile shows its current
  /// value inline instead of navigating to a page that owns that value.
  final Widget? trailing;

  /// Outer spacing. Defaults to the Figma 20 side margin; pass
  /// `EdgeInsets.zero` when the parent already pads.
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.symmetric(horizontal: 20.w),
      child: GestureDetector(
        onTap: ontap,
        child: Container(
          height: 50.hs(context),
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: bg2Color(context),
            borderRadius: BorderRadius.circular(40.r),
            // border: isBorder
            //     ? Border.all(
            //   color: Colors.grey,
            //   width: 2.w,
            // )
            //     : null,
          ),
          child: Row(
            children: [
              if (icon != null)
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: SvgPicture.asset(
                    icon!,
                    color: textcolor ?? iconDefaultColor(context),
                  ),
                ),
              if (icon != null) SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.headingColor16(context),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (!isLogout)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: textcolor ?? mainTypographyColor(context),
                  size: 16.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
