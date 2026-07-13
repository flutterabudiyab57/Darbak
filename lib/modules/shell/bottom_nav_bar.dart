import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/language/locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShellBottomNavBar extends StatelessWidget {
  const ShellBottomNavBar({
    super.key,
    required this.navKey,
    required this.selectedIndex,
    required this.onTap,
  });

  final GlobalKey<CurvedNavigationBarState> navKey;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return CurvedNavigationBar(
      key: navKey,
      index: selectedIndex,
      backgroundColor: Colors.transparent,
      color: buttonWhiteColor(context),
      buttonBackgroundColor: Colors.transparent,
      height: 80.hs(context),
      animationDuration: const Duration(milliseconds: 300),
      items: [
        _navItem(
            context: context,
            assetPath: 'assets/icons/home.png',
            label: locale.home!,
            width: 30.w,
            height: 25.h,
            index: 0),
        _navItem(
            context: context,
            assetPath: 'assets/icons/car.png',
            label: locale.fleet!,
            width: 25.w,
            height: 25.h,
            index: 1),
        _navItem(
            context: context,
            assetPath: 'assets/icons/reservations.png',
            label: locale.finish!,
            width: 28.w,
            height: 28.h,
            index: 2),
        _navItem(
            context: context,
            assetPath: 'assets/icons/more.png',
            label: locale.more,
            width: 30.w,
            height: 30.h,
            index: 3),
      ],
      onTap: onTap,
    );
  }

  CurvedNavigationBarItem _navItem({
    required BuildContext context,
    required String assetPath,
    required String label,
    required double width,
    required double height,
    required int index,
  }) {
    final isSelected = index == selectedIndex;

    return CurvedNavigationBarItem(
      child: Container(
        width: 50.w,
        height: 50.h,
        decoration: isSelected
            ? BoxDecoration(
                gradient: gradient2(context),
                shape: BoxShape.circle,
              )
            : null,
        alignment: Alignment.center,
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          color: isSelected ? Colors.white : iconGrayColor(context),
        ),
      ),
      label: label,
      labelStyle: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        color: isSelected ? buttonBlueColor(context) : iconGrayColor(context),
        fontSize: 12.sps(context),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
      ),
    );
  }
}
