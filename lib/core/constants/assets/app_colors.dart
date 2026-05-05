import 'package:flutter/material.dart';
/// =================================================
/// :art: APP COLOR PALETTE (Light & Dark)
/// Based on the provided design screenshot
/// =================================================
/// :large_brown_square: Background
const Color backgroundLight = Color(0xffF3F3F3);
const Color backgroundDark = Color(0xFF111111);
/// :writing_hand: Typography
const Color headingLight = Color(0xFF000000);
const Color headingDark = Color(0xFFFFFFFF);
const Color paragraphLight = Color(0xFF3B3B3B);
const Color paragraphDark = Color(0xFFCFCFCF);
const Color typographyMainLight = Color(0xFF06479B);
const Color typographyMainDark = Color(0xFF06479B);
const Color typographySecondaryLight = Color(0xFF009966);
const Color typographySecondaryDark = Color(0xFF009966);

const Color TextgrayLight = Color(0xFF838383);
const Color TextgrayDark = Color(0xFFC2C2C2);

/// :radio_button: Buttons
// Primary
const Color buttonPrimaryBG_Light = Color(0xFFCCCCCC);
const Color buttonPrimaryBG_Dark = Color(0xFF06479B);
const Color buttonTextLight = Color(0xFFFFFFFF);
const Color buttonTextDark = Color(0xFFFFFFFF);
// Secondary
const Color buttonSecondaryLight = Color(0xFFB1B1B1);
const Color buttonSecondaryDark = Color(0xFF464646);
/// White Button
const Color buttonWhiteLight = Color(0xFFFFFFFF);
const Color buttonWhiteDark = Color(0xFF2A2A2A);
/// Green Button
const Color buttongreenLight = Color(0xFF8EBA30);
const Color buttongreenDark =  Color(0xFF8EBA30);
/// Red Button
const Color buttonRedLight = Color(0xFFA10012);
const Color buttonRedDark =  Color(0xFFA10012);


/// blue Button
const Color buttonBlueLight = Color(0xFF0B7D98);
const Color buttonBlueDark =  Color(0xFF0B7D98);

///          Icons
const Color iconDefaultLight = Color(0xFF06479B);
const Color iconDefaultDark = Color(0xFF06479B);
///Gray
const Color iconGrayLight = Color(0xFF707070);
const Color iconGrayDark = Color(0xFFEEEEEE);
///
const Color iconGreenLight = Color(0xFF009966);
const Color iconGreenDark = Color(0xFF009966);

/// :straight_ruler: Stroke (Borders)
const Color strokeGrayLight = Color(0xFFC5C5C5);
const Color strokeGrayDark = Color(0xFFEEEEEE);
const Color strokeMainLight = Color(0xFF06479B);
const Color strokeMainDark = Color(0xFF06479B);
/// Containers background Color
const Color seatsContainerLight = Color(0xffFAF1E1);
const Color seatsContainerDark =  Color(0xff787165);
const Color speedContainerLight = Color(0xffDBEDE6);
const Color speedContainerDark  =  Color(0xff35403C);
const Color fuelContainerLight= Color(0xffEAEAEA);
const Color fuelContainerDark =  Color(0xff585656);
const Color transmissionContainerLight= Color(0xffF8E3E2);
const Color transmissionContainerDark =  Color(0xff504747);
/// ====================================================================
/// :pushpin: Dynamic Colors (Auto Switch between Light / Dark Mode)
/// ====================================================================
Color backgroundColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? backgroundLight
        : backgroundDark;
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

/// Icons
Color iconDefaultColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? iconDefaultLight
        : iconDefaultDark;
Color iconGrayColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? iconGrayLight
        : iconGrayDark;
/// Stroke
Color strokeGrayColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? strokeGrayLight
        : strokeGrayDark;
Color strokeMainColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.light
        ? strokeMainLight
        : strokeMainDark;
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
Alignment _figmaToFlutter(double x, double y) {
  return Alignment((x * 2) - 1, (y * 2) - 1);
}
LinearGradient gradient1(BuildContext context) => LinearGradient(
  begin: _figmaToFlutter(0.00, 0.90),
  end: _figmaToFlutter(0.60, 0.50),
  colors: [
    const Color(0xFF0156B2),
    const Color(0xFF3EA361),
  ],
  stops: const [0.0, 1.0],
);

LinearGradient linear(BuildContext context) => LinearGradient(
  begin: _figmaToFlutter(0.00, 0.00),
  end: _figmaToFlutter(0.60, 0.30),
  colors: const [
    Color(0xFF8BBA2E),
    Color(0xFF009966),
    Color(0xFF0156B2),
  ],
  stops: const [0.0, 0.5, 1.0],
);
LinearGradient secondary2 = LinearGradient(
  begin: _figmaToFlutter(0.0, 0.5),
  end: _figmaToFlutter(1.0, 0.5),
  colors: const [
    Color(0xFF3EA361),
    Color(0xFF8BB836),
  ],
  stops: const [0.0, 1.0],
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
