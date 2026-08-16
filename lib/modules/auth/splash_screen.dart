import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../home/profile/blocs/profile_cubit/profile_cubit.dart';
import '../../core/constants/preferences_constants.dart';
import '../../core/helpers/SharedPreference/pereferences.dart';


class SplashScreenOld extends StatefulWidget {
  @override
  _SplashScreenOldState createState() => _SplashScreenOldState();
}

class _SplashScreenOldState extends State<SplashScreenOld> {
  int _currentScreen = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _initializeStartup();

    BlocProvider.of<ProfileCubit>(context).getProfile();
  }

  Future<void> _initializeStartup() async {
    try {
      final stopwatch = Stopwatch()..start();

      final tokenFuture = SharedPreferencesHelper().get(PreferencesConstants.token);
      final token = tokenFuture != null ? await tokenFuture : null;

      final elapsed = stopwatch.elapsedMilliseconds;
      final remainingMs = 300 - elapsed;
      if (remainingMs > 0) {
        await Future.delayed(Duration(milliseconds: remainingMs));
      }

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        context.go('/home');
      } else {
        Future.delayed(const Duration(milliseconds: 1700), () {
          if (!mounted) return;
          setState(() => _currentScreen = 1);
        });
      }
    } catch (e) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        setState(() => _currentScreen = 1);
      });
    }
  }

  Widget _buildFrame1(Key key) {
    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Center(
        child: Image.asset(
          'assets/images/new_splash.png',
          width: 182.w,
          height: 281.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildFrame2(Key key) {
    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 263.h),
          Image.asset(
            'assets/images/new_logo.png',
            width: 321.w,
            height: 130.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 112.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 33.w),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final isLanguageSelected = await SharedPreferencesHelper().get("isLanguageSelected");
                    final hasSeenOnboarding = await SharedPreferencesHelper().get(PreferencesConstants.hasSeenOnboarding);

                    if (!mounted) return;

                    if (isLanguageSelected != "true") {
                      context.go('/language');
                    } else if (hasSeenOnboarding != "true") {
                      context.go('/onboarding');
                    } else {
                      context.go('/home');
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF021E45),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: Text(
                        'ابدأ الحجز',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontFamily: 'ThmanyahSans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                GestureDetector(
                  onTap: () => context.go('/signin'),
                  child: Container(
                    width: double.infinity,
                    height: 55.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF021E45), width: 1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: const Color(0xFF021E45),
                          fontSize: 20.sp,
                          fontFamily: 'ThmanyahSans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: _currentScreen == 0
            ? _buildFrame1(const ValueKey('frame1'))
            : _buildFrame2(const ValueKey('frame2')),
      ),
    );
  }
}
