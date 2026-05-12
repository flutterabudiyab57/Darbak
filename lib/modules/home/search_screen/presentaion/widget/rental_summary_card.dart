import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/assets/app_colors.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
class RentalSummaryCard extends StatelessWidget {
  final DateTime receiveDate;
  final DateTime driveDate;
  final int differenceInDays;
  const RentalSummaryCard({
    Key? key,
    required this.receiveDate,
    required this.driveDate,
    required this.differenceInDays,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final isRTL = locale!.isDirectionRTL(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: backgroundColor(context),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: strokeGrayColor(context), width: 2.w),
      ),
      child: Row(
        children: [
          Icon(Icons.timelapse_rounded,
              size: 24.sp, color: headingColor(context)),
          SizedBox(width: 6.w),
          Text(
            isRTL
                ? "مدة الإيجار: $differenceInDays يوم"
                : "Rental Duration: $differenceInDays day(s)",
            style: AppTypography.headingColor18(context),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String dateStr;
  final BuildContext context;

  const _DateRow({
    required this.label,
    required this.dateStr,
    required this.context,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.mainTypographyColor18(context)
        ),

        SizedBox(width: 6.w),

        Text(
          "/",
          style: AppTypography.paragraphColor18(context),
        ),
        SizedBox(width: 4.w),

        Text(
          dateStr,
          style: AppTypography.paragraphColor18(context),
        ),
      ],
    );
  }
}