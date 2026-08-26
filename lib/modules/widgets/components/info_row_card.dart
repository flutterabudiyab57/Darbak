import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';
import '../../../core/style/style.dart';

/// A read-only profile row: type icon, label + value, and an edit affordance.
///
/// Figma: 65 tall, BG-2 fill, 12 radius, 14/11 padding.
class InfoRowCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  /// Omit to render the row without an edit affordance (e.g. a field the
  /// backend does not allow changing, like the ID number).
  final VoidCallback? onEdit;

  const InfoRowCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = paragraphNavyColor(context);

    // Under RTL the first child resolves to the right, so the type icon leads
    // on the right and the pencil lands on the far left, mirroring in English.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: bg2Color(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22.sp, color: textColor),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.infoLabel16(context),
                ),
                SizedBox(height: 6.h),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.infoValue16(context),
                ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: Icon(Icons.edit_outlined, size: 20.sp, color: textColor),
            ),
          ],
        ],
      ),
    );
  }
}
