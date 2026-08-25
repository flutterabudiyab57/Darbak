import 'dart:math' as math;

import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/shell/shell_bottom_bar_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Fraction of the bar's width the selected pill is allowed to claim. Caps
/// long/scaled labels so they can never push the other three slots below
/// [_kMinSlotWidth] or push the pill past the bar's own edges.
const double _kPillWidthCap = 0.60;

/// Floor for the three unselected slots: icon (24.w) + a small breathing
/// margin (10.w) so compressed icons never touch each other or clip.
const double _kMinSlotWidth = 34.0;

const Duration _kNavAnimDuration = Duration(milliseconds: 300);
const Curve _kNavAnimCurve = Curves.easeInOut;

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
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);

    final items = [
      _NavItemData(assetPath: 'assets/icons/home.svg', label: locale.home!),
      _NavItemData(assetPath: 'assets/icons/car.svg', label: locale.fleet!),
      _NavItemData(
        assetPath: 'assets/icons/reservations.svg',
        label: locale.finish!,
      ),
      _NavItemData(assetPath: 'assets/icons/more.svg', label: locale.more),
    ];

    final labelStyle = TextStyle(
      fontFamily: 'ThmanyahSans',
      color: buttonTextColor(context),
      fontSize: 14.sps(context),
      fontWeight: FontWeight.w500,
      height: 1.14,
    );

    // The rendered Text below doesn't opt out of ambient text scaling, so a
    // real Text widget scales this already-.sps-scaled fontSize a second
    // time. Passing the same textScaler here reproduces that, otherwise the
    // reserved label width undershoots the actual glyph run.
    final selectedLabelWidth = (TextPainter(
      text: TextSpan(text: items[selectedIndex].label, style: labelStyle),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout())
        .size
        .width;

    const iconSize = 24.0;
    const gap = 6.0;
    const leadingPad = 8.0;
    const trailingPad = 8.0;

    final iconWidth = iconSize.w;
    final gapWidth = gap.w;
    final leadingPadWidth = leadingPad.w;
    final trailingPadWidth = trailingPad.w;
    final padWidth = leadingPadWidth + trailingPadWidth;
    final minPillWidth = iconWidth + padWidth;
    final minSlotWidth = _kMinSlotWidth.w;

    final barHeight = ShellBottomBarMetrics.height(context);
    final pillHeight = 40.hs(context);
    final pillTop = (barHeight - pillHeight) / 2;
    // Constant regardless of selection — every slot reserves the same label
    // offset in its (identical) widget tree; it's only visible where the
    // slot is wide enough to reveal it (see ClipRect below).
    final labelStart = leadingPadWidth + iconWidth + gapWidth;

    return Container(
      margin: EdgeInsets.only(
        left: ShellBottomBarMetrics.horizontalMargin,
        right: ShellBottomBarMetrics.horizontalMargin,
        bottom: ShellBottomBarMetrics.bottomMargin,
      ),
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;

          final naturalPillWidth =
              iconWidth + gapWidth + selectedLabelWidth + padWidth;
          var pillWidth = math.max(
            math.min(naturalPillWidth, _kPillWidthCap * barWidth),
            minPillWidth,
          );

          // Reducing the pill (not growing the others) is what protects the
          // three unselected slots' minimum width — see REMAINING SLOTS.
          final maxPillGivenMins = math.max(
            barWidth - 3 * minSlotWidth,
            minPillWidth,
          );
          pillWidth = math.min(pillWidth, maxPillGivenMins);

          final perOtherWidth = (barWidth - pillWidth) / 3;

          // ONE shared layout calculation drives every slot's box AND the
          // selected icon's target alignment. Widths sum to exactly
          // barWidth, so the last slot's end is exactly the bar's inner
          // edge: no overlap, no edge clipping, by construction.
          final widths = <double>[
            for (int i = 0; i < items.length; i++)
              i == selectedIndex ? pillWidth : perOtherWidth,
          ];
          final starts = <double>[];
          var running = 0.0;
          for (final w in widths) {
            starts.add(running);
            running += w;
          }

          final reservedLabelWidth = math.max(
            pillWidth - labelStart - trailingPadWidth,
            0.0,
          );
          final leadingAlignment = _leadingAlignmentDirectional(
            boxWidth: pillWidth,
            iconWidth: iconWidth,
            leadingPad: leadingPadWidth,
          );

          return Container(
            width: barWidth,
            height: barHeight,
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
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (int i = 0; i < items.length; i++)
                  AnimatedPositionedDirectional(
                    duration: _kNavAnimDuration,
                    curve: _kNavAnimCurve,
                    start: starts[i],
                    top: pillTop,
                    width: widths[i],
                    height: pillHeight,
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.opaque,
                      // Every slot renders this exact same widget tree —
                      // only property values (color, alignment, max width)
                      // differ by isSelected — so Flutter tweens between
                      // states instead of swapping subtrees on tap.
                      child: _NavSlot(
                        assetPath: items[i].assetPath,
                        label: items[i].label,
                        labelStyle: labelStyle,
                        isSelected: i == selectedIndex,
                        labelStart: labelStart,
                        reservedLabelWidth: i == selectedIndex
                            ? reservedLabelWidth
                            : double.infinity,
                        leadingAlignment: leadingAlignment,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Solves for the [AlignmentDirectional] x-value that places a fixed-size
/// icon's leading edge at [leadingPad] from its box's leading edge, given
/// the box is [boxWidth] wide. Align's own formula is
/// `childOffset = (boxWidth - childWidth) * (x + 1) / 2`, so this is just
/// that formula inverted.
AlignmentDirectional _leadingAlignmentDirectional({
  required double boxWidth,
  required double iconWidth,
  required double leadingPad,
}) {
  final travel = boxWidth - iconWidth;
  if (travel <= 0) return AlignmentDirectional.center;
  final x = ((2 * leadingPad) / travel) - 1;
  return AlignmentDirectional(x.clamp(-1.0, 1.0), 0);
}

class _NavItemData {
  const _NavItemData({required this.assetPath, required this.label});

  final String assetPath;
  final String label;
}

/// A single nav slot. Structurally identical whether selected or not — the
/// background color/shadow, the icon's alignment, and the label's allowed
/// width are the only things that vary, and all of them are driven by
/// implicit animations on the SAME 300ms/easeInOut timing as the slot's own
/// [AnimatedPositionedDirectional] box, so nothing inside ever teleports.
class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.assetPath,
    required this.label,
    required this.labelStyle,
    required this.isSelected,
    required this.labelStart,
    required this.reservedLabelWidth,
    required this.leadingAlignment,
  });

  final String assetPath;
  final String label;
  final TextStyle labelStyle;
  final bool isSelected;
  final double labelStart;
  final double reservedLabelWidth;
  final AlignmentDirectional leadingAlignment;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _kNavAnimDuration,
      curve: _kNavAnimCurve,
      decoration: BoxDecoration(
        gradient: isSelected ? buttonGradient : null,
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
            : const [],
      ),
      // Clips the label's OverflowBox reveal (below) to this slot's own
      // currently-animating box — narrow unselected slots simply clip the
      // label away entirely, wide selected slots reveal it.
      child: ClipRect(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(start: labelStart),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                // Lays the label out at its natural (or ellipsis-capped)
                // width, independent of the slot's current animated width,
                // so it never reflows/squeezes mid-slide — only how much of
                // it the ClipRect above reveals changes.
                child: OverflowBox(
                  alignment: AlignmentDirectional.centerStart,
                  minWidth: 0,
                  maxWidth: double.infinity,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: reservedLabelWidth),
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  ),
                ),
              ),
            ),
            // Painted after the label so it's never momentarily drawn
            // underneath the label during a transition.
            AnimatedAlign(
              duration: _kNavAnimDuration,
              curve: _kNavAnimCurve,
              alignment: isSelected
                  ? leadingAlignment
                  : AlignmentDirectional.center,
              child: _AnimatedNavIcon(
                assetPath: assetPath,
                isSelected: isSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon tint needs to transition smoothly rather than swap instantly, so
/// each icon runs its own implicit color animation synchronized to the
/// slot's 300ms slide.
class _AnimatedNavIcon extends StatelessWidget {
  const _AnimatedNavIcon({required this.assetPath, required this.isSelected});

  final String assetPath;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(
        end: isSelected ? buttonTextColor(context) : iconnavColor(context),
      ),
      duration: _kNavAnimDuration,
      curve: _kNavAnimCurve,
      builder: (context, color, child) => SvgPicture.asset(
        assetPath,
        width: 24.w,
        height: 24.h,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          color ?? iconnavColor(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
