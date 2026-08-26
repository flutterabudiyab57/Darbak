import 'package:darbak/core/style/style.dart';
import 'package:darbak/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';

import '../../../core/constants/assets/app_colors.dart';

/// Themed top bar matching the Figma nav spec: a rounded, bordered surface
/// with a soft drop shadow, a centred title, a circular BG-2 back button and an
/// optional theme toggle.
///
/// Child order is direction-aware for free: `leading` (back) resolves to the
/// right in RTL and `actions` (toggle) to the left, which is what the design
/// shows.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Toolbar height below the status bar. Figma: 105 total - 51 status bar.
  static const double barHeight = 80;

  final String title;
  final bool showBackButton;
  final bool showThemeToggle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onThemeToggle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.showThemeToggle = false,
    this.onBackPressed,
    this.onThemeToggle,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      bottomLeft: Radius.circular(20.r),
      bottomRight: Radius.circular(20.r),
    );

    // The shadow is painted here rather than through `elevation`: Material's
    // elevation draws an ambient halo on every side, while Figma drops the
    // shadow straight down. The bar is full-width, so the horizontal spread
    // falls off-screen and only the bottom edge reads.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0x33000000),
            blurRadius: 6.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: backgroundColor(context),
        // Material 3 tints the surface when content scrolls under the bar, which
        // would drift the background off the design colour.
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.w, color: strokeGrayColor(context)),
          borderRadius: radius,
        ),
        toolbarHeight: barHeight.hs(context),
        centerTitle: true,
        title: Text(title, style: AppTypography.appBarTitle20(context)),
        leadingWidth: 55.w,
        leading: showBackButton
            ? Padding(
                padding: EdgeInsetsDirectional.only(start: 20.w),
                child: _CircleBackButton(
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                ),
              )
            : null,
        automaticallyImplyLeading: showBackButton,
        actions: [
          if (showThemeToggle)
            Padding(
              padding: EdgeInsetsDirectional.only(end: 12.w),
              child: AnimatedThemeToggleButton(
                onToggle: onThemeToggle,
                size: 23.sp,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(barHeight.h);
}

/// 35x35 BG-2 circle holding the back chevron, per the Figma nav spec.
///
/// The chevron is picked from the reading direction because Material chevrons
/// do not mirror themselves.
class _CircleBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CircleBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 35.w,
        height: 35.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg2Color(context),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isRtl ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
          color: headingColor(context),
          size: 20.sp,
        ),
      ),
    );
  }
}

class AnimatedThemeToggleButton extends StatelessWidget {
  final VoidCallback? onToggle;

  /// Overrides the icon colour. Pass a fixed colour when the button sits on a
  /// surface that does not follow the theme, such as the navy hero panel.
  final Color? color;

  /// Overrides the icon size. Defaults to the 32sp used on the hero panel; the
  /// app bar passes the smaller 23sp from the nav spec.
  final double? size;

  const AnimatedThemeToggleButton({
    Key? key,
    this.onToggle,
    this.color,
    this.size,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark = themeMode == ThemeMode.dark;

        return GestureDetector(
          onTap: onToggle ??
              () {
                if (isDark) {
                  context.read<ThemeCubit>().setLightTheme();
                } else {
                  context.read<ThemeCubit>().setDarkTheme();
                }
              },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(10.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    key: ValueKey<bool>(isDark),
                    color: color ?? strokeMainColor(context),
                    size: size ?? 32.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
