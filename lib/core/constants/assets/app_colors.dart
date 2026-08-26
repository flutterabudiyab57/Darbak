import 'package:flutter/material.dart';
/// =================================================
/// :art: APP COLOR PALETTE (Light & Dark)
/// Based on the provided design screenshot
/// =================================================
/// :large_brown_square: Background
const Color backgroundLight = Color(0xFFFFFFFF);
const Color backgroundDark = Color(0xFF0D1117);
const Color bg2Light = Color(0xFFE2E8EF);
const Color bg2Dark  = Color(0xFF111C2C);
/// :writing_hand: Typography
const Color headingLight = Color(0xFF021E45);
const Color headingDark = Color(0xFFFFFFFF);
const Color paragraphLight = Color(0xFF3B3B3B);
const Color paragraphDark = Color(0xFFCFCFCF);
const Color typographyMainLight = Color(0xFF021E45);
const Color typographyMainDark = Color(0xFF2676F0);
const Color typographySecondaryLight = Color(0xFF2676F0);
const Color typographySecondaryDark = Color(0xFF2676F0);

const Color TextgrayLight = Color(0xFF838383);
const Color TextgrayDark = Color(0xFFC2C2C2);

/// :radio_button: Buttons
// Primary
const Color buttonPrimaryBG_Light = Color(0xFF021E45);
const Color buttonPrimaryBG_Dark = Color(0xFF2172EF);
const Color buttonTextLight = Color(0xFFFFFFFF);
const Color buttonTextDark = Color(0xFFFFFFFF);
// Secondary
const Color buttonSecondaryLight = Color(0xFFB1B1B1);
const Color buttonSecondaryDark = Color(0xFF464646);
/// White Button
const Color buttonWhiteLight = Color(0xFFFFFFFF);
const Color buttonWhiteDark = Color(0xFF0D1117);
/// White Button
const Color navLight = Color(0xFFFFFFFF);
const Color navDark = Color(0xFF3E4146);
/// Green Button
///
const Color buttongreenLight = Color(0xFF0B6E00);
const Color buttongreenDark =  Color(0xFF43823C);
/// Red Button
const Color buttonRedLight = Color(0xFFA10012);
const Color buttonRedDark =  Color(0xFFA10012);

/// blue Button
const Color buttonBlueLight = Color(0xFF2172EF);
const Color buttonBlueDark =  Color(0xFF0B7D98);

// New from design tokens
const Color buttonColorLight = Color(0xFF2172EF);
const Color buttonColorDark  = Color(0xFF2172EF);

///          Icons
const Color iconDefaultLight = Color(0xFF021E45);
const Color iconDefaultDark = Color(0xFF155DFC);
///Gray
const Color iconGrayLight = Color(0xFF707070);
const Color iconGrayDark = Color(0xFFEEEEEE);
///
const Color iconGreenLight = Color(0xFF009966);
const Color iconGreenDark = Color(0xFF009966);

const Color iconBlueLight = Color(0xFF155DFC);
const Color iconBlueDark  = Color(0xFF2172EF);
const Color iconnavLight = Color(0xFF354B6A);
const Color iconnavDark  = Color(0xFFD8D9DA);

/// :straight_ruler: Stroke (Borders)
const Color strokeGrayLight = Color(0xFFC5C5C5);
const Color strokeGrayDark = Color(0xFFEEEEEE);
const Color strokeMainLight = Color(0xFF021E45);
const Color strokeMainDark = Color(0xFF155DFC);

const Color strokeBlueLight = Color(0xFF155DFC);
const Color strokeBlueDark  = Color(0xFF155DFC);

/// Containers background Color
const Color seatsContainerLight = Color(0xffFFF0D6);
const Color seatsContainerDark =  Color(0xffFFF0D6);
const Color speedContainerLight = Color(0xffC2FCE5);
const Color speedContainerDark  =  Color(0xffC2FCE5);
const Color fuelContainerLight= Color(0xffC1C1C1);
const Color fuelContainerDark =  Color(0xffC1C1C1);
const Color transmissionContainerLight= Color(0xffFFDEDC);
const Color transmissionContainerDark =  Color(0xffFFDEDC);
/// ====================================================================
/// :pushpin: Dynamic Colors (Auto Switch between Light / Dark Mode)
/// ====================================================================
Color backgroundColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? backgroundLight
        : backgroundDark;
Color bg2Color(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light ? bg2Light : bg2Dark;
Color headingColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? headingLight
        : headingDark;
Color paragraphColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? paragraphLight
        : paragraphDark;

Color mainTypographyColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? typographyMainLight
        : typographyMainDark;
Color SecondaryTypographyColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? typographySecondaryLight
        : typographySecondaryDark;
Color TextgrayColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? TextgrayLight
        : TextgrayDark;
// Buttons
Color buttonPrimaryBgColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttonPrimaryBG_Light
        : buttonPrimaryBG_Dark;
Color buttonTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttonTextLight
        : buttonTextDark;
Color buttonSecondaryColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttonSecondaryLight
        : buttonSecondaryDark;
Color buttonWhiteColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttonWhiteLight
        : buttonWhiteDark;
Color navColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? navLight
        : navDark;
Color buttonGreenColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttongreenLight
        : buttongreenDark;
Color buttonRedColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttonRedLight
        : buttonRedDark;
Color buttonBlueColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttonBlueLight
        : buttonBlueDark;
Color buttonColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? buttonColorLight
        : buttonColorDark;

/// Icons
Color iconDefaultColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? iconDefaultLight
        : iconDefaultDark;
Color iconGrayColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? iconGrayLight
        : iconGrayDark;
Color iconBlueColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? iconBlueLight
        : iconBlueDark;
Color iconnavColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? iconnavLight
        : iconnavDark;

/// Stroke
Color strokeGrayColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? strokeGrayLight
        : strokeGrayDark;
Color strokeMainColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? strokeMainLight
        : strokeMainDark;
Color strokeBlueColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? strokeBlueLight
        : strokeBlueDark;

/// Containers background Color
Color seatsContainer(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? seatsContainerLight
        : seatsContainerDark;
Color speedContainer(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? speedContainerLight
        : speedContainerDark;
Color fuelContainer(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? fuelContainerLight
        : fuelContainerDark;
Color TransmissionContainer(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? transmissionContainerLight
        : transmissionContainerDark;
// ===========================
// Gradients
// ===========================
// ===========================
Alignment _figmaToFlutter(double x, double y) {
  return Alignment((x * 2) - 1, (y * 2) - 1);
}
LinearGradient gradient1(BuildContext context) => const LinearGradient(
  begin: Alignment(0.00, 0.00),
  end: Alignment(1.00, 1.00),
  colors: [Color(0xFF021E45), Color(0xFF2172EF)],
  stops: [0.0, 1.0],
); 

// LinearGradient gradient2(BuildContext context) => LinearGradient(
//   begin: _figmaToFlutter(1.00, 0.31),
//   end: _figmaToFlutter(0.09, 0.66),
//   colors: const [
//     Color(0xFF0156B2),
//     Color(0xFF009966),
//     Color(0xFF8BBA2E),
//   ],
//   stops: const [0.0, 0.5, 1.0],
// );
// LinearGradient secondary2 = LinearGradient(
//   begin: _figmaToFlutter(0.0, 0.5),
//   end: _figmaToFlutter(1.0, 0.5),
//   colors: const [
//     Color(0xFF3EA361),
//     Color(0xFF8BB836),
//   ],
//   stops: const [0.0, 1.0],
// );
// ===========================
// Gradients
// ===========================

/// Primary button gradient (same in Light & Dark).
/// Source: Figma "SlotClone" — SVG linearGradient (79.67, 22) -> (96.58, 71.77)
/// on a 240x40 box, converted to Flutter Alignment space:
///   alignX = (px - centerX) / (width  / 2)
///   alignY = (py - centerY) / (height / 2)
/// Do NOT re-run _figmaToFlutter on these values — they are already converted.
const LinearGradient buttonGradient = LinearGradient(
  begin: Alignment(-0.361, 0.0),
  end: Alignment(-0.220, 2.488),
  colors: [Color(0xFF021E45), Color(0xFF2172EF)],
  stops: [0.0285, 1.0],
);
LinearGradient secondary =  LinearGradient(
  begin: _figmaToFlutter(0.0, 0.5),
  end: _figmaToFlutter(1.0, 0.5),
  colors: [
    Color(0xFF0156B2),
    Color(0xFF147D9B),
  ],
  stops: [0.0, 1.0],
);
const List<BoxShadow> buttonShadows = [
  BoxShadow(
    color: Color(0x19000000),
    blurRadius: 2,
    offset: Offset(0, 1),
    spreadRadius: -1,
  ),
  BoxShadow(
    color: Color(0x19000000),
    blurRadius: 3,
    offset: Offset(0, 1),
  ),
];

// ===========================
// Hero panel — fixed brand surface
// ===========================
// The home hero panel is navy in BOTH light and dark mode: it is a brand
// surface, not a theme surface. So every token that lands on it is a plain
// const, not a *Light / *Dark pair. Do NOT swap these for the dynamic
// heading/paragraph functions — those resolve to navy in light mode and would
// render navy-on-navy.

/// Figma "Typography-white".
const Color onHeroPrimary = Color(0xFFFFFFFF);

/// Figma "Typography-paragraph-2" — white @ 70%.
const Color onHeroSecondary = Color(0xB3FFFFFF);

/// Figma "Typography-paragraph" — navy @ 80%. Distinct from [paragraphLight]
/// (`#3B3B3B`); this one is the tinted-navy body colour used on BG-2 cards.
const Color paragraphNavyLight = Color(0xCC021E45);

/// Dark counterpart. The navy tint only reads on the light `#E2E8EF` card; in
/// dark mode those cards are `#111C2C`, so this falls back to the standard
/// light-on-dark paragraph colour.
const Color paragraphNavyDark = Color(0xFFCFCFCF);

Color paragraphNavyColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? paragraphNavyLight
        : paragraphNavyDark;

/// Black @ 10% scrim Figma lays over the hero gradient to deepen it.
const Color heroPanelScrim = Color(0x1A000000);

/// Hero panel gradient.
///
/// Figma: 390x354 box, `linearGradient` from (0,0) to (1,1) in **normalized**
/// 0..1 space — i.e. top-left to bottom-right. Normalized values map to
/// [Alignment] via `(v * 2) - 1`, so (0,0) is `topLeft` and (1,1) is
/// `bottomRight`. Pasting the raw `0..1` pair straight into `Alignment` (as
/// the export does) would start the sweep at the box *centre* instead.
const LinearGradient heroPanelGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF021E45), Color(0xFF2172EF)],
);

/// Navy used for content that sits on a white/BG-2 chip *inside* the hero
/// panel (the back button's arrow, the white search CTA's label).
const Color heroNavy = Color(0xFF021E45);

/// Drop shadow on the hero notification bell.
const List<BoxShadow> heroBellShadows = [
  BoxShadow(
    color: Color(0x28000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  ),
];