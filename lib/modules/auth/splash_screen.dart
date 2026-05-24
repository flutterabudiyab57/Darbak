import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/assets/app_colors.dart';
import '../../core/helpers/SharedPreference/pereferences.dart';
import '../home/profile/blocs/profile_cubit/profile_cubit.dart';

class SplashScreenOld extends StatefulWidget {
  @override
  _SplashScreenOldState createState() => _SplashScreenOldState();
}

class _SplashScreenOldState extends State<SplashScreenOld> {
  int _currentScreen = 0;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _currentScreen = 1);
      }
    });

    BlocProvider.of<ProfileCubit>(context).getProfile();

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    String? isLanguageSelectedStr =
    await SharedPreferencesHelper().get("isLanguageSelected");

    bool isLanguageSelected = isLanguageSelectedStr == "true";

    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;
    context.go(isLanguageSelected ? '/shell?tab=0' : '/language');
  }

  Widget _buildScreen({required bool gradient, required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient ? gradient1(context) : null,
        color: gradient ? null : Colors.white,
      ),
      child: Center(
        child: Image.asset(
          "assets/images/Darbak_logo.png",
          width: 180.w,
        ),
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
            ? _buildScreen(gradient: true, key: const ValueKey('screen1'))
            : _buildScreen(gradient: false, key: const ValueKey('screen2')),
      ),
    );
  }
}
