import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/assets/app_colors.dart';

/// The navy brand panel that heads the home and profile screens.
///
/// Paints the Figma hero gradient, the 10% black scrim layered over it, and the
/// 32px bottom corners, then insets [child] below the status bar.
///
/// [height] is the panel's height *below* the status bar. The widget adds
/// `MediaQuery.paddingOf(context).top` itself, so callers pass the Figma number
/// straight through (354 on home, 337 on the profile screen).
///
/// The panel is navy in both light and dark mode — it is a brand surface, not a
/// theme surface — so anything placed in [child] must use the fixed `onHero*`
/// tokens rather than the theme-dynamic heading/paragraph functions, which
/// resolve to navy in light mode and would render navy-on-navy.
class GradientHeroPanel extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const GradientHeroPanel({
    Key? key,
    required this.height,
    required this.child,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      bottomLeft: Radius.circular(32.r),
      bottomRight: Radius.circular(32.r),
    );

    return SizedBox(
      height: height + MediaQuery.paddingOf(context).top,
      // Two nested boxes rather than `foregroundDecoration`: Figma stacks the
      // scrim over the gradient but *under* the content, and a foreground
      // decoration would paint over the child too.
      child: DecoratedBox(
        decoration:
            BoxDecoration(gradient: heroPanelGradient, borderRadius: radius),
        child: DecoratedBox(
          decoration:
              BoxDecoration(color: heroPanelScrim, borderRadius: radius),
          child: SafeArea(
            bottom: false,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
