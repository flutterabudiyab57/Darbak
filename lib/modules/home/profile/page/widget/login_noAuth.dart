import 'package:darbak/modules/home/selectLanguage/language_dialog.dart';
import 'dart:ui';
import 'package:darbak/core/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../../core/constants/assets/assets.dart';
import '../../../../../core/router/routes.dart';
import '../../../../../language/locale.dart';
import '../../../../auth/register/presentaion/pages/register_page.dart';
import '../../../../auth/signin/presentation/pages/signin_screen.dart';
import 'card_tile.dart';
class LoginNoAuth extends StatelessWidget {
  const LoginNoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var locale = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: Column(
          spacing: 15.h,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 12.h,
            ),
            Text(
              locale.niceToMeetYou,
              style:AppTypography.headingColor18(context),),
            Text(
              locale.openAccountSubtitle,
              style:AppTypography.headingColor18(context),
            ),
            Center(
                child: Lottie.asset("assets/anim/password.json",
                    width: 240.w, fit: BoxFit.cover)),
             CardTileWidget(
              title: locale.signIn.toString(),
              icon: Assets.icon_login,
              ontap: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  constraints: const BoxConstraints(maxWidth: double.infinity,),
                  builder: (context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: FractionallySizedBox(
                        child: SignInScreen(mode: SignInMode.gate),
                      ),
                    );
                  },
                );
              },
            ),

            CardTileWidget(
              title: locale.createAccount,
              icon: Assets.icon_addAccount,
              ontap: () {
                showModalBottomSheet(
                  useRootNavigator: true,
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  constraints: const BoxConstraints(maxWidth: double.infinity,),
                  builder: (context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: FractionallySizedBox(
                        heightFactor: .9,
                        child: RegisterPage(),
                      ),
                    );
                  },
                );
              },
            ),

            /*   Bounce(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: SignInScreen(),
                  withNavBar: false,
                );
              },
              child: Container(
                height: size.height * 0.053,
                width: 300.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: kButtonColor),
                child: Center(
                  child: Text(
                    locale.signIn.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
*/

            /*      Bounce(
              onTap: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: RegisterPage(),
                  withNavBar: false,
                );
              },
              child: Container(
                height: size.height * 0.053,
                width: 300.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: kButtonColor),
                child: Center(
                  child: Text(
                    locale.isDirectionRTL(context)
                        ? 'فتح حساب'
                        : 'Create Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          */
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(16),
            //       // حواف دائرية بـ radius 16
            //       border: Border.all(
            //         color: Colors.grey, // لون البوردر
            //         width: 2.0, // سماكة البوردر
            //       ),
            //     ),
            //     child: ListTile(
            //       title: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Icon(
            //             Icons.color_lens,
            //             color: Theme.of(context).brightness == Brightness.light
            //                 ? Color(0xFF0A708D)
            //                 : Color(0xFF00A0FF),
            //           ),
            //           Text(
            //             locale.isDirectionRTL(context)
            //                 ? "الوضع الليلي "
            //                 : "Dark Theme",
            //             style: GoogleFonts.almarai(
            //               fontSize: 18.sp,
            //               fontWeight: FontWeight.w400,
            //               color:
            //                   Theme.of(context).brightness == Brightness.light
            //                       ? Colors.black
            //                       : Colors.white,
            //             ),
            //           ),
            //           Spacer(),
            //           AnimatedThemeToggleButton(),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            CardTileWidget(
                title: locale.changeLanguage.toString(),
                icon: Assets.profile_language,
                trailing: const ActiveLanguageFlag(),
                ontap: () {
                  showLanguageDialog(context);
                }),
             CardTileWidget(
                title: locale.privacyPolicy.toString(),
                icon: Assets.profile_privacy,
                ontap: () {
                  context.pushNamed(Routes.privacyPolicy);
                }),
            CardTileWidget(
              title: locale.complaint!,
              ontap: () {
                context.pushNamed(Routes.complaints);
              },
              icon: Assets.icon_complaint,
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.15,)
          ],
        ),
      ),
    );
  }
}
