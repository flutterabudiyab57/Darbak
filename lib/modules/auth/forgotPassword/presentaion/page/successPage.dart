import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/style/style.dart';
import '../../../../../language/locale.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';
import '../../../signin/presentation/pages/signin_screen.dart';

class SuccessBottomSheet extends StatelessWidget {
  const SuccessBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: size.height * 0.41 + keyboardHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.sp),
          topRight: Radius.circular(25.sp),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.sp),
          topRight: Radius.circular(25.sp),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 15.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 120.h,
                        width: 120.w,
                        child: Image.asset(
                          'assets/icons/Ok_hand.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: size.height*0.02,),
                      Text(locale!.passwordChanged.toString(),
                          textAlign: TextAlign.center,
                          style:AppTypography.headingColor26(context)),
                      SizedBox(height: 15.h),
                      Text(
                        locale.returnToLoginScreen,
                        textAlign: TextAlign.center,
                        style: AppTypography.paragraphColor20(context),
                      ),
                      SizedBox(height: 20.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          showModalBottomSheet(
                            useRootNavigator: true,
                            context: context,
                            isScrollControlled: true,
                            isDismissible: true,
                            enableDrag: true,
                            backgroundColor: Colors.transparent,
                            constraints: BoxConstraints(
                              maxWidth: double.infinity,
                              maxHeight: MediaQuery.of(context).size.height * 0.85,
                            ),                            builder: (context) => BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: FractionallySizedBox(
                                child: SignInScreen(mode: SignInMode.gate),
                              ),
                            ),
                          );
                        },
                          child: ADGradientButton(
                            locale.signIn.toString(),
                          )
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}