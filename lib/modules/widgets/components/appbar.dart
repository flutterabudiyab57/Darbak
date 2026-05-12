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
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.showThemeToggle = false,
    this.onBackPressed,
    this.onThemeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor(context),
      toolbarHeight: 80.hs(context),
      title: Text(
        title,
        style: AppTypography.mainTypographyColor22(context),
      ),
      leading: showBackButton
          ? Padding(
            padding:  EdgeInsets.all(12.sp),
            child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: strokeMainColor(context),size: 30.sp,),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  ),
          )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: [
        if (showThemeToggle)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: AnimatedThemeToggleButton(
              onToggle: onThemeToggle,
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80.h);
}

class AnimatedThemeToggleButton extends StatelessWidget {
  final VoidCallback? onToggle;
  const AnimatedThemeToggleButton({
    Key? key,
    this.onToggle,
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
                    color: strokeMainColor(context),
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