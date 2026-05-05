import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../language/locale.dart';
import '../../style/style.dart';

class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    Key? key,
    required this.onRetry,
    this.buttonText = 'إعادة المحاولة',
    this.descriptionAr = 'تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى',
    this.descriptionEn = 'Check your internet connection and try again',
  }) : super(key: key);

  final VoidCallback onRetry;
  final String buttonText;
  final String descriptionAr;
  final String descriptionEn;

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final locale = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/anim/Network error.json",
            width: 350.w,
            fit: BoxFit.cover,
          ),

          SizedBox(height: 14.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              isRTL ? descriptionAr : descriptionEn,
              textAlign: TextAlign.center,
              style: AppTypography.mainTypographyColor16(context),
            ),
          ),

          SizedBox(height: 18.h),

          ElevatedButton(
            onPressed: onRetry,
            child: Text(locale.retry),
          ),
        ],
      ),
    );
  }
}
