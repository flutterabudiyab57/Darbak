import 'package:darbak/core/style/style.dart';
import 'package:darbak/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';

import '../../../core/constants/assets/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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

  double _height(BuildContext context) => 80.hs(context);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor(context),
      toolbarHeight: _height(context),
      leadingWidth: 64.w,
      title: Text(title, style: AppTypography.mainTypographyColor22(context)),
      leading: showBackButton
          ? IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(
          minWidth: 48.w,
          minHeight: 48.w,
        ),
        splashRadius: 28.w,
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: strokeMainColor(context),
          size: 26.sp,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: [
        if (showThemeToggle)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: AnimatedThemeToggleButton(onToggle: onThemeToggle),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}
class AnimatedThemeToggleButton extends StatelessWidget {
  final VoidCallback? onToggle;

  /// Overrides the icon colour. Pass a fixed colour when the button sits on a
  /// surface that does not follow the theme, such as the navy hero panel.
  final Color? color;

  const AnimatedThemeToggleButton({
    Key? key,
    this.onToggle,
    this.color,
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
                    size: 32.sp,
                  ),
                ),
                SizedBox(width: 8.w),
              ],
            ),
          ),
        );
      },
    );
  }
}