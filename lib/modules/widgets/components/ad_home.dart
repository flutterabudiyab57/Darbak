import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/home/home_screen/home_screen.dart';
import 'package:darbak/shared/commponents.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';


class AdHomeButton extends StatelessWidget {
  final bool isBackHandled;
  final VoidCallback? onPressed;

  const AdHomeButton({Key? key, this.onPressed, this.isBackHandled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Padding(
      padding:   EdgeInsets.all(8.sp),
      child:  Bounce(
          onTap: isBackHandled ? onPressed : () =>
              navigateAndFinish(context, HomeScreen()),
          child: Container(
            padding: EdgeInsets.only(
                left: locale!.isDirectionRTL(context) ? 8.w : 8.w,
                right: locale.isDirectionRTL(context) ? 8.w : 8.w
            ),
            decoration: BoxDecoration(
                color:  iconDefaultColor(context),
                borderRadius: BorderRadius.circular(8.r),
                ),
            child: Center(
                child: Icon(
                  Icons.home_outlined,
                  size: 25.sp,
                  color: Colors.white,
                )),
          ),
        ),

    );
  }
}
