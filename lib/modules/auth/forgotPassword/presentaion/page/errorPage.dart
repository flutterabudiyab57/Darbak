
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../language/locale.dart';
import '../../../../../shared/commponents.dart';
import '../../../../widgets/components/ad_gradient_btn.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    return  Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: size.width*0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/error1.svg'),
                SizedBox(height: size.height*0.05,),
                Text(locale!.passwordChanged.toString(),
                  textAlign: TextAlign.center,
                  style: defaultTextStyle(34, FontWeight.w700, Colors.black),),
                SizedBox(height: size.height*0.05,),
                GestureDetector(onTap:(){
                  context.go('/signin');
                },child: ADGradientButton(locale.goToHome)),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
