import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/helpers/SharedPreference/pereferences.dart';
import '../home/profile/blocs/profile_cubit/profile_cubit.dart';
import '../home/selectLanguage/selectLanguage.dart';
import '../compose_ui.dart';

class SplashScreenOld extends StatefulWidget {
  @override
  _SplashScreenOldState createState() => _SplashScreenOldState();
}

class _SplashScreenOldState extends State<SplashScreenOld>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    BlocProvider.of<ProfileCubit>(context).getProfile();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    String? token = await SharedPreferencesHelper().get("token");
    String? isLanguageSelectedStr =
    await SharedPreferencesHelper().get("isLanguageSelected");

    bool isLanguageSelected = isLanguageSelectedStr == "true";

    // print("Token:****************** $token");
    // print("isLanguageSelected: $isLanguageSelected");

    Widget startWidget;

    if (!isLanguageSelected) {
      startWidget = SelectLanguage(true);
    } else {
      startWidget = ComposeUi() ;
    }

    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => startWidget),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/Darbak_logo.png",
                  width: 180.w,
                ),
                // SizedBox(
                //   height: 10.h,
                // ),
                // Text(
                //   "دركسون",
                //   style: TextStyle(
                //       fontSize: 35.sp,
                //       fontWeight: FontWeight.w600,
                //       fontFamily: "IBMPlexSansArabic",
                //       color: Color(0xFF00323A)),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}