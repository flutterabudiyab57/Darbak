import 'dart:ui';

import 'package:darbak/core/style/style.dart';
import 'package:darbak/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../auth/signin/presentation/pages/signin_screen.dart';
import 'ad_gradient_btn.dart';

class ErrorImage extends StatelessWidget {
  const ErrorImage({
    Key? key,
    required this.refresh,
    this.error,
    this.onLoginSuccess, 
  }) : super(key: key);

  final Function() refresh;
  final String? error;
  final VoidCallback? onLoginSuccess; 

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    if (error != null &&
        (error!.contains("Not Authenticated") || error!.contains("Unauthenticated"))) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding:  EdgeInsets.all(20.sp),
          child: Column(
            spacing: 20.h,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Lottie.asset("assets/anim/password.json"),
              ),
              Text(
                  locale!.loginToContinue.toString(),
                  style:AppTypography.headingColor20(context)
              ),
              GestureDetector(
                onTap: () async {
                  final result = await showModalBottomSheet<bool>(
                    useRootNavigator: true,
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    enableDrag: true,
                    constraints: const BoxConstraints(maxWidth: double.infinity,),
                    backgroundColor: Colors.transparent,
                    builder: (context) => BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: FractionallySizedBox(
                        child: SignInScreen(pushAddition: true, mode: SignInMode.gate),
                      ),
                    ),
                  );

                  if (result == true && onLoginSuccess != null) {
                    onLoginSuccess!();
                  }
                },
                child: Column(
                  spacing: 20.h,
                  children: [
                    ADGradientButton(
                      locale.signIn.toString(),
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Default error screen
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.7,
              child: Lottie.asset("assets/anim/error.json"),
            ),
            IconButton(
              onPressed: refresh,
              icon: Icon(
                Icons.refresh,
                size: 50,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }
  }
}