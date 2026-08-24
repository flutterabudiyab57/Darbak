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

  static double get horizontalMargin => 16.w;

  static double get bottomMargin => 12.h;
}

/// Total vertical space the floating bar occupies above the safe area:
/// bar height + its bottom margin + the device's own safe-area inset.
/// A function (not a const) because the safe-area inset is device-dependent.
double shellBottomInset(BuildContext context) =>
    ShellBottomBarMetrics.height(context) +
    ShellBottomBarMetrics.bottomMargin +
    MediaQuery.of(context).padding.bottom;
