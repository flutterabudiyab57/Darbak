import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ADColoredTextButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ADColoredTextButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsetsDirectional.only(start: 8.w),
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? buttonPrimaryBgColor(context)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: isSelected
              ? null
              : Border.all(color: strokeGrayColor(context)),
        ),
        child: Text(
          text,
          style: isSelected
              ? AppTypography.buttonText16(context)
              : AppTypography.paragraphColor16(context),
        ),
      ),
    );
  }
}
