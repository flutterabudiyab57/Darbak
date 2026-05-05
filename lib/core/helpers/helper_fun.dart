
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../modules/widgets/components/ad_dialog.dart';
import '../constants/assets/app_colors.dart';
import '../style/style.dart';

class HelperFunctions {
  static void showFlashBar({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    Color? color,
    Color? titlcolor,
    Color? iconColor,
    bool showProgressIndicator = true,
  }) {
    showFlash(
      context: context,
      duration: const Duration(milliseconds: 3000),
      builder: (context, controller) {
        return Center(
          child: FlashBar(
            controller: controller,
            position: FlashPosition.top,
             margin: EdgeInsets.symmetric(horizontal: 10.0.sp),
            forwardAnimationCurve: Curves.easeOutBack,
            reverseAnimationCurve: Curves.slowMiddle,
            backgroundColor:color ??backgroundColor(context),
            title: Text(
              title,
              style:AppTypography.paragraphColor16(context),
            ),
            content: Text(
              message,
              style: AppTypography.paragraphColor16(context),
            ),
            icon: Icon(icon, color: iconColor),
          ),
        );
      },
    );
  }
  static dialog({
    required BuildContext context,
    required String title,
    required String body,
  }) => showDialog(context: context,
          builder: (context) => ADErrorDialog(title: title, body: body));

  static statusDialog({
    required BuildContext context,
    required bool status,
  }) => showDialog(context: context,
          builder: (context) => ADStatusDialog(status: status));
}
