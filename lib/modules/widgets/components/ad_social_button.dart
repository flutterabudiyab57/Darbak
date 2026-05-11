import 'package:darbak/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'constants.dart';

class ADSocialButtons extends StatelessWidget {
  final String? title;
  final Color color;
  ADSocialButtons({required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r), gradient: gradient),
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(25.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 15.h,
              child: Image(
                  image: title == locale.facebook
                      ? AssetImage('')
                      : AssetImage('')),
            ),
            Text(
              title!,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          ],
        ),
      ),
    );
  }
}
