import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../data/models/branch.dart';

/// A single row in [BranchPickerScreen]. Part of the picker surface —
/// Constitution Principle II forbids any cubit read here, scoped or global
/// (see contracts/navigation-contract.md). Everything this widget needs
/// arrives through its constructor.
///
/// Every [Branch] field except [Branch.id] and [Branch.name] may be absent —
/// a partial, car-flow branch (`Branch.fromCarBranchesApi`) supplies neither
/// address, region, nor work-time data (US6 scenario 2). This tile tolerates
/// all of that and renders only what is present.
class BranchTile extends StatelessWidget {
  final Branch branch;
  final bool isSelected;
  final VoidCallback onTap;

  const BranchTile({
    super.key,
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = branch.address ?? branch.regionName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: bg2Color(context),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? mainTypographyColor(context) : strokeGrayColor(context),
            width: isSelected ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    branch.name,
                    style: AppTypography.headingColor16(context),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTypography.paragraphColor14(context),
                    ),
                  ],
                  if (branch.bookToday) ...[
                    SizedBox(height: 4.h),
                    Text(
                      AppLocalizations.of(context)!.availableToday,
                      style: AppTypography.paragraphColor12(context)
                          .copyWith(color: buttonGreenColor(context)),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Padding(
                padding: EdgeInsetsDirectional.only(start: 8.w),
                child: Icon(
                  Icons.check_circle,
                  color: mainTypographyColor(context),
                  size: 22.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
