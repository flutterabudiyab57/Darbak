import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
class RentalSummaryCard extends StatelessWidget {
  final int differenceInDays;
  const RentalSummaryCard({
    Key? key,
    required this.differenceInDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final isRTL = locale!.isDirectionRTL(context);
    final isSingular = differenceInDays == 1;
    final unit = isRTL
        ? (isSingular ? "يوم" : "أيام")
        : (isSingular ? "day" : "days");

    return Container(
      width: 150.w,
      height: 150.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SecondaryTypographyColor(context).withValues(alpha: 0.4),
        shape: BoxShape.circle,
        border: Border.all(
          color: headingColor(context),
          width: 1.w,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        boxShadow: [
          BoxShadow(
            color: headingColor(context).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isRTL ? "مدة الايجار" : "Rental Duration",
            style: AppTypography.headingColor18(context)
          ),
          Text(
            "$differenceInDays",
            style: AppTypography.headingColor18(context).copyWith(
              fontSize: 50.sp,
              color: headingColor(context),
            ),
          ),
          Text(
            unit,
            style: AppTypography.headingColor18(context)
          ),
        ],
      ),
    );
  }
}

