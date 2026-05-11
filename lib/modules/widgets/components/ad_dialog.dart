import 'package:auto_size_text/auto_size_text.dart';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';

class ADErrorDialog extends StatelessWidget {
  final String title;
  final String body;

  ADErrorDialog({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor(context),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: buttonPrimaryBgColor(context),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Image.asset(
                'assets/images/man2.png',
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.05,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          FittedBox(
            child: AutoSizeText(
              title,
              style: AppTypography.headingColor22(context)
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: MediaQuery.of(context).size.height * 0.13,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: AutoSizeText(
              body,
              style: AppTypography.paragraphColor24(context),
              textAlign: TextAlign.center,
            ),
          ),
          Spacer(),
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            width: double.infinity,
            alignment: AlignmentDirectional.center,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              child: AutoSizeText(
                'ok',
                style: AppTypography.mainTypographyColor24(context)
              ),
            ),
          ),
          SizedBox(height: 8.h),

        ],
      ),
    );
  }
}

class ADStatusDialog extends StatelessWidget {
  final bool status;

  ADStatusDialog({required this.status});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(12.r)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Image.asset(
                status ? 'assets/checked.png' : 'assets/wrong.png',
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.05,
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Spacer(),
          SizedBox(height: 20.h),
          FittedBox(
            child: AutoSizeText(
              status ? 'Success Payment' : 'Failed Payment',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 18.sp),
            ),
          ),
          Spacer(),
          Container(
            height: MediaQuery.of(context).size.height * 0.05,
            width: double.infinity,
            alignment: AlignmentDirectional.center,
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                elevation: 2.0,
                backgroundColor: status ? Colors.green : Colors.red,
                minimumSize: Size(180.w, 60.h),
                shape: StadiumBorder(),
                textStyle: TextStyle(color: Colors.white),
                padding: EdgeInsets.all(5.r),
              ),
              child: AutoSizeText(
                'ok',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
