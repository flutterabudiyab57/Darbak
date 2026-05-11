import 'package:bounce/bounce.dart';
import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/widgets/components/ad_gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key, required this.storeUrl});
  final String storeUrl;

  Future<void> _launch() async {
    if (await canLaunch(storeUrl)) await launch(storeUrl);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.all(8.h),
            child: SvgPicture.asset(
              'assets/icons/update_version.svg',
              height: MediaQuery.of(context).size.height * 0.12,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            locale.updateAvailable,
            style: AppTypography.mainTypographyColor14(context),
          ),
          SizedBox(height: 6.h),
          Text(
            locale.updateAvailableMessage,
            style: AppTypography.headingColor14(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Center(
            child: Bounce(
              onTap: () {
                _launch();
                Navigator.of(context).pop();
              },
              child: ADGradientButton(
                locale.updateNow,
                width: MediaQuery.of(context).size.width * 0.6,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
