import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';
import '../../../core/style/style.dart';
import 'appbar.dart';

/// The app-bar row that sits inside a [GradientHeroPanel].
///
/// This is deliberately NOT a variant of [CustomAppBar]: that widget returns a
/// real `AppBar` on a themed background and is used by 37 screens, whereas this
/// is a plain `Row` painted on the fixed navy panel. Folding both into one
/// class would put two unrelated branches inside a widget the whole app depends
/// on. Screens migrate to this one at a time as the design rolls out.
class HeroAppBarRow extends StatelessWidget {
  final String title;
  final bool showBackButton;
  final bool showThemeToggle;
  final VoidCallback? onBackPressed;

  const HeroAppBarRow({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showThemeToggle = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // First child resolves to the right under RTL, so back-then-toggle puts the
    // back button on the trailing edge in Arabic and the leading edge in
    // English — the natural side for each direction.
    return Row(
      children: [
        SizedBox(width: 40.w, child: showBackButton ? _back(context) : null),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.heroAppBarTitle20(context),
          ),
        ),
        SizedBox(
          child: showThemeToggle
              ? const AnimatedThemeToggleButton(color: onHeroPrimary)
              : null,
        ),
      ],
    );
  }

  Widget _back(BuildContext context) {
    // Material chevrons never mirror themselves, so pick the one that points
    // "backwards" for the active direction.
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onBackPressed ?? () => Navigator.pop(context),
      child: Container(
        width: 35.w,
        height: 35.w,
        // Fixed, not bg2Color(context): this chip sits on the navy panel, which
        // does not change with the theme, so a dark-mode BG-2 would vanish.
        decoration: const BoxDecoration(color: bg2Light, shape: BoxShape.circle),
        child: Icon(
          isRtl ? Icons.arrow_back_ios_new :Icons.arrow_forward_ios ,
          size: 24.sp,
          color: heroNavy,
        ),
      ),
    );
  }
}
