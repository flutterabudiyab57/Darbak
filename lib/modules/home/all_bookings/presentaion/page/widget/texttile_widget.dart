import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextTileWidget extends StatelessWidget {
  const TextTileWidget(
      {Key? key,
      required this.contant,
      required this.title,
      required this.size})
      : super(key: key);
  final String title;
  final String contant;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AutoSizeText(
          title,
          style: TextStyle(
            fontFamily: "IBMPlexSansArabic",
            fontSize: 13.sp,
            color: paragraphColor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        AutoSizeText(contant,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: "IBMPlexSansArabic",
              color: headingColor(context),
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ))
      ],
    );
  }
}
