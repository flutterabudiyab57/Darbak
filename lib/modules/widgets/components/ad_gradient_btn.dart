import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';

class ADGradientButton extends StatelessWidget {
  final String? title;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final Widget? customIcon;
  final BoxBorder? border;
  final Gradient? gradient;
  final bool autoSize;
  const ADGradientButton(
      this.title, {
        Key? key,
        this.width,
        this.height,
        this.backgroundColor,
        this.textColor,
        this.icon,
        this.iconSize,
        this.iconColor,
        this.textStyle,
        this.customIcon,
        this.border, this.gradient,
        this.autoSize = true,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTypography.buttonText18(context);
    final resolvedStyle = (textStyle ?? baseStyle).copyWith(
      color: textColor ?? (textStyle ?? baseStyle).color,
    );

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.hs(context),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? buttonPrimaryBgColor(context),
          borderRadius: BorderRadius.circular(15.r),
          border: border,
        ),
        child: Padding(
          padding:   EdgeInsets.symmetric(vertical: 2.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (customIcon != null) customIcon!,
              if (customIcon != null) SizedBox(width: 8.w),

              if (icon != null)
                Icon(
                  icon,
                  size: iconSize ?? 22.sps(context),
                  color: iconColor ?? textColor ?? Colors.white,
                ),
              if (icon != null) SizedBox(width: 8.w),

              autoSize
                  ? AutoSizeText(title ?? '', style: resolvedStyle)
                  : Text(
                      title ?? '',
                      style: resolvedStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
