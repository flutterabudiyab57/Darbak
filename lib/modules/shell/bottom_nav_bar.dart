import 'dart:math' as math;

import 'package:darbak/core/constants/assets/app_colors.dart';
import 'package:darbak/core/helpers/text_scale_sizing.dart';
import 'package:darbak/language/locale.dart';
import 'package:darbak/modules/shell/shell_bottom_bar_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma nav bar metrics (390 design width). The four slots form one cluster
/// centred in the bar: a fixed-width selected pill plus three icon slots,
/// separated by [_kSlotGap]. The gap only shrinks (down to [_kMinSlotGap])
/// when a long label or a narrow screen leaves no room for it.
const double _kPillWidth = 110.0;
const double _kSlotWidth = 40.0;
const double _kSlotGap = 24.0;
const double _kMinSlotGap = 8.0;

/// Diagonal navy -> blue sweep of the selected pill (Figma: 143.44deg,
/// stops 39% / 84%), already converted to [Alignment] for a 110x40 box.
const LinearGradient _kPillGradient = LinearGradient(
  begin: Alignment(-0.529, -1.96),
  end: Alignment(0.529, 1.96),
  colors: [Color(0xFF021E45), Color(0xFF2172EF)],
  stops: [0.39, 0.84],
);

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
    // reserved label width undershoots the actual glyph run. The style is
    // merged with the ambient DefaultTextStyle for the same reason: a real
    // Text inherits its letterSpacing, a bare TextPainter does not, which
    // clipped longer labels ("Bookings" -> "Bookin...").
    final measureStyle = DefaultTextStyle.of(context).style.merge(labelStyle);
    final selectedLabelWidth = (TextPainter(
      text: TextSpan(text: items[selectedIndex].label, style: measureStyle),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout())
        .size
        .width;

    const iconSize = 26.0;
    const gap = 6.0;
    const leadingPad = 12.0;
    const trailingPad = 12.0;

    final iconWidth = iconSize.w;
    final gapWidth = gap.w;
    final leadingPadWidth = leadingPad.w;
    final trailingPadWidth = trailingPad.w;
    final padWidth = leadingPadWidth + trailingPadWidth;
    final minPillWidth = iconWidth + padWidth;
    final slotWidth = _kSlotWidth.w;

    final barHeight = ShellBottomBarMetrics.height(context);
    final pillHeight = 40.hs(context);
    final pillTop = (barHeight - pillHeight) / 2;
    // Constant regardless of selection — every slot reserves the same label
    // offset in its (identical) widget tree; only the selected slot actually
    // shows the label (see the AnimatedOpacity in _NavSlot).
    final labelStart = leadingPadWidth + iconWidth + gapWidth;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      // Clears the system gesture area, but never sits closer to the bottom
      // than the Figma margin.
      minimum: EdgeInsets.only(bottom: ShellBottomBarMetrics.bottomMargin),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: ShellBottomBarMetrics.horizontalMargin,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            final minGap = _kMinSlotGap.w;
            final inset = ShellBottomBarMetrics.contentInset;

            final naturalPillWidth =
                iconWidth + gapWidth + selectedLabelWidth + padWidth;
            // Longer labels (e.g. "Bookings") grow the pill, but never past
            // the point where the three icon slots would lose their minimum
            // spacing.
            final maxPillWidth = math.max(
              barWidth - 2 * inset - 3 * slotWidth - 3 * minGap,
              minPillWidth,
            );
            final pillWidth = math.min(
              math.max(naturalPillWidth, _kPillWidth.w),
              maxPillWidth,
            );

            final slotGap = ((barWidth - 2 * inset - pillWidth - 3 * slotWidth) /
                    3)
                .clamp(minGap, _kSlotGap.w)
                .toDouble();

            // ONE shared layout calculation drives every slot's box AND the
            // selected icon's target alignment. Each box is its visual width
            // plus [slotGap] (half on each side), so boxes tile the cluster
            // without overlap and every tap lands on exactly one slot.
            final visualWidths = <double>[
              for (int i = 0; i < items.length; i++)
                i == selectedIndex ? pillWidth : slotWidth,
            ];
            final clusterWidth =
                visualWidths.reduce((a, b) => a + b) + 3 * slotGap;
            final starts = <double>[];
            var running = (barWidth - clusterWidth) / 2 - slotGap / 2;
            for (final w in visualWidths) {
              starts.add(running);
              running += w + slotGap;
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
                    // The box spans the full bar height (>= 48 touch target);
                    // only the pill inside it is inset to its Figma height.
                    AnimatedPositionedDirectional(
                      duration: _kNavAnimDuration,
                      curve: _kNavAnimCurve,
                      start: starts[i],
                      top: 0,
                      width: visualWidths[i] + slotGap,
                      height: barHeight,
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
                        slotGap: slotGap,
                        pillTop: pillTop,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
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
    required this.slotGap,
    required this.pillTop,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final TextStyle labelStyle;
  final bool isSelected;
  final double labelStart;
  final double reservedLabelWidth;
  final AlignmentDirectional leadingAlignment;
  final double slotGap;
  final double pillTop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: slotGap / 2,
            vertical: pillTop,
          ),
          child: _buildPill(),
        ),
      ),
    );
  }

  Widget _buildPill() {
    return AnimatedContainer(
      duration: _kNavAnimDuration,
      curve: _kNavAnimCurve,
      decoration: BoxDecoration(
        gradient: isSelected ? _kPillGradient : null,
        borderRadius: BorderRadius.circular(35.r),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
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
                // Visibility is driven by selection, not by geometry. The
                // ClipRect above cannot hide an unselected label on its own:
                // the label starts `labelStart` (38.w) into the slot while an
                // unselected slot is (barWidth - pillWidth) / 3 wide — ~83.w
                // at the 390 design width — so the clip reveals it instead of
                // cutting it. That went unnoticed because the label colour is
                // white in both themes and the light-mode bar is also white.
                child: AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: _kNavAnimDuration,
                  curve: _kNavAnimCurve,
                  // Still laid out while hidden: keeping the label in the tree
                  // at its natural (or ellipsis-capped) width is what stops it
                  // reflowing when the slot's width animates.
                  child: OverflowBox(
                    alignment: AlignmentDirectional.centerStart,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: reservedLabelWidth),
                      // Shrinks a label that still doesn't fit instead of
                      // truncating it, so the tab name never disappears.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          label,
                          maxLines: 1,
                          softWrap: false,
                          style: labelStyle,
                        ),
                      ),
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
        width: 26.w,
        height: 26.w,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          color ?? iconnavColor(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
