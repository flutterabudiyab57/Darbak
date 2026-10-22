import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single source of truth for the floating bottom nav bar's vertical
/// footprint. [ShellBottomNavBar] reads these directly instead of
/// re-declaring the numbers, and root tab screens use [shellBottomInset] to
/// size their own trailing clearance so scrollable content never ends up
/// hidden behind the floating bar.
class ShellBottomBarMetrics {
  const ShellBottomBarMetrics._();

  /// The bar holds text labels, so its height stays text-scale-aware via
  /// `.hs` (see lib/core/helpers/text_scale_sizing.dart) rather than plain
  /// `.h`.
  static double height(BuildContext context) => 55.hs(context);

  static double get horizontalMargin => 21.w;

  /// Minimum distance from the screen bottom; the bar uses the larger of this
  /// and the device's own safe-area inset.
  static double get bottomMargin => 20.h;

  /// Space between the bar's edge and the icon-slot cluster.
  static double get contentInset => 23.5.w;
}

/// Total vertical space the floating bar occupies from the screen bottom:
/// bar height + the larger of its bottom margin and the device's own
/// safe-area inset (matching the bar's `SafeArea(minimum: ...)`).
/// A function (not a const) because the safe-area inset is device-dependent.
double shellBottomInset(BuildContext context) =>
    ShellBottomBarMetrics.height(context) +
    math.max(
      ShellBottomBarMetrics.bottomMargin,
      MediaQuery.of(context).padding.bottom,
    );
