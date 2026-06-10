import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/helper/notification_date_format.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/model/notification_model.dart';
import 'notification_type.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final type = NotificationType.fromString(item.type);
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: backgroundColor(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: strokeGrayColor(context), width: 1.5.w),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBox(type),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dateRow(context, isArabic),
                  SizedBox(height: 8.h),
                  Text(
                    item.title,
                    style: AppTypography.mainTypographyColor16(context)
                        .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    item.body,
                    style: AppTypography.paragraphColor16(context)
                        .copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconBox(NotificationType type) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: type.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(type.icon, size: 20.sp, color: type.iconColor),
    );
  }

  Widget _dateRow(BuildContext context, bool isArabic) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatNotificationDate(item.createdAt, isArabic: isArabic),
          style: AppTypography.paragraphColor16(context)
              .copyWith(fontSize: 12.sp),
        ),
        if (!item.isRead) ...[
          SizedBox(width: 5.w),
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: Color(0xFF00323A), // unread dot (Figma)
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
