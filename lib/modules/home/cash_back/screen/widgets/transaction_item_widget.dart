// transaction_item_widget.dart
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/constants/assets/assets.dart';

class TransactionItemWidget extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isPositive;
  final IconData icon;
  final Color iconColor;

  const TransactionItemWidget({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isPositive,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headingColor16(context),
              ),
              SizedBox(height: 4.h),
              Text(
                date,
                style: AppTypography.paragraphColor12(context),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            SizedBox(width: 4.w),
            SvgPicture.asset(
              Assets.icon_riyal,
              height: 18.h,
              width: 20.w,
              color: iconColor,
            ),
          ],
        ),
      ],
    );
  }
}