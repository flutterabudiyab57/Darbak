
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';
class ADBackButton extends StatelessWidget {
  final bool isBackHandled;
  final VoidCallback? onPressed;

  const ADBackButton({Key? key, this.onPressed, this.isBackHandled = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isBackHandled ? onPressed : () => Navigator.of(context).pop(),
      child: Padding(
        padding:  EdgeInsets.all(8.sp),
        child: Container(
          child: Icon(Icons.arrow_back_ios, color: iconDefaultColor(context),size: 25.sp,),
            ),
      ),
    );
  }
}
