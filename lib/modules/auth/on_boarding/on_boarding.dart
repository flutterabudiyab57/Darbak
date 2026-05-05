import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/assets/app_colors.dart';
import '../../../core/style/style.dart';
import '../../../language/locale.dart';
import '../../home/home_screen/home_screen.dart';
import '../../widgets/components/ad_gradient_btn.dart';

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}
class _OnBoardingState extends State<OnBoarding> {
  final controller = PageController(keepPage: true);
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:backgroundColor(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: controller,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, index) {
                  return buildOnBoardingPageContent(context, locale, index);
                },
              ),
            ),
            buildPageIndicator(),
            SizedBox(height: 20.h),
            buildNextButton(context, locale),
            SizedBox(height: 20.h),
            buildSkipButton(context, locale),
            SizedBox(height: 75.h),
          ],
        ),
      ),
    );
  }

  Widget buildOnBoardingPageContent(
      BuildContext context, AppLocalizations? locale, int index) {
    final imageAssets = [
      'assets/images/onBord1.png',
      'assets/images/onBord2.png',
      'assets/images/onBord3.png',
    ];

    final titles = [
      locale!.titleOnboarding1.toString(),
      locale.titleOnboarding2.toString(),
      locale.titleOnboarding3.toString(),
    ];

    final bodies = [
      locale.bodyOnboarding1.toString(),
      locale.bodyOnboarding2.toString(),
      locale.bodyOnboarding3.toString(),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imageAssets[index], width: 330.w),
          SizedBox(height: 28.h),
          Text(
            titles[index],
            textAlign: TextAlign.center,
            style: AppTypography.headingColor26(context),
          ),
          SizedBox(height: 16.h),
          Text(
            bodies[index],
            textAlign: TextAlign.center,
            style: AppTypography.paragraphColor20(context),
          ),
        ],
      ),
    );
  }

  Widget buildPageIndicator() {
    return SmoothPageIndicator(
      controller: controller,
      count: 3,
      effect: ExpandingDotsEffect(
        dotHeight: 17.h,
        dotWidth: 17.w,
        expansionFactor: 3,
        spacing: 6.w,
        dotColor:   Color(0xffb6b6b6),
        activeDotColor:iconDefaultColor(context),
      ),
    );
  }

  Widget buildNextButton(BuildContext context, AppLocalizations? locale) {
    return GestureDetector(
        onTap: () {
          if (currentIndex < 2) {
            controller.nextPage(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              _createRoute(),
              (route) => false,
            );
          }
        },
        child:ADGradientButton(
          locale!.follow,
          width: 320.w,
          textStyle: AppTypography.buttonText20(context),
        )

    );
  }

  Widget buildSkipButton(BuildContext context, AppLocalizations? locale) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          _createRoute(),
          (route) => false,
        );
      },
      child: Container(
        height: 50.h,
        width: 320.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.r), color: buttonSecondaryColor(context)),
        child: Center(
          child: Text(
            locale!.skip.toString(),
            style: AppTypography.headingColor20(context),
          ),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          HomeScreen(skipLoginCheckInSearch: false),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
