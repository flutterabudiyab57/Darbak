import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return SafeArea(
      bottom: false,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale.paymentMethod.toString(),
              style: AppTypography.headingColor16(context),
            ),
            SizedBox(height:10.h),
            Text(
              locale.choosePaymentMethod.toString(),
              style: AppTypography.paragraphColor18(context),
            ),
          ],
        ),
      ),
    );
  }
}
