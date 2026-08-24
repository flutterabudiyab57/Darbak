import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/shell/shell_bottom_bar_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShellBottomNavBar extends StatelessWidget {
  const ShellBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    final items = [
      _NavItemData(assetPath: 'assets/icons/home.svg', label: locale.home!),
      _NavItemData(assetPath: 'assets/icons/car.svg', label: locale.fleet!),
      _NavItemData(assetPath: 'assets/icons/reservations.svg', label: locale.finish!),
      _NavItemData(assetPath: 'assets/icons/more.svg', label: locale.more),
    ];

    return Container(
      margin: EdgeInsets.only(
        left: ShellBottomBarMetrics.horizontalMargin,
        right: ShellBottomBarMetrics.horizontalMargin,
        bottom: ShellBottomBarMetrics.bottomMargin,
      ),
      color: Colors.transparent,
      child: Container(
        height: ShellBottomBarMetrics.height(context),
        decoration: BoxDecoration(
          color: navColor(context),
          borderRadius: BorderRadius.circular(40.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 16,
              offset: Offset(0, 3),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i = 0; i < items.length; i++)
              _NavItem(
                data: items[i],
                isSelected: i == selectedIndex,
                onTap: () => onTap(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({required this.assetPath, required this.label});

  final String assetPath;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 40.hs(context),
        padding: isSelected
            ? EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected ? buttonPrimaryBgColor(context) : null,
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              data.assetPath,
              width: 24.w,
              height: 24.h,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                isSelected ? buttonTextColor(context) : iconnavColor(context),
                BlendMode.srcIn,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Text(
                data.label,
                style: TextStyle(
                  fontFamily: 'ThmanyahSans',
                  color: buttonTextColor(context),
                  fontSize: 14.sps(context),
                  fontWeight: FontWeight.w500,
                  height: 1.14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
