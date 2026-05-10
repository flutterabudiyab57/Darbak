import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/assets/app_colors.dart';

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: headingLight,
      ),
      iconTheme: IconThemeData(color: iconDefaultLight),
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.tajawal(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: headingLight,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16.sp,
        color: paragraphLight,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14.sp,
        color: typographyMainLight,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 13.sp,
        color: strokeMainLight,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPrimaryBG_Light,
        foregroundColor: buttonTextLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: typographyMainLight,
      secondary: buttonSecondaryLight,
      background: backgroundLight,
      surface: backgroundLight,
      error: Colors.red,
      onPrimary: buttonTextLight,
      onSecondary: buttonSecondaryLight,
      onBackground: paragraphLight,
      onSurface: headingLight,
      onError: Colors.white,
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.tajawal(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: headingDark,
      ),
      iconTheme: IconThemeData(color: iconDefaultDark),
    ),
    textTheme: TextTheme(
      titleLarge: GoogleFonts.tajawal(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: headingDark,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16.sp,
        color: paragraphDark,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14.sp,
        color: typographyMainDark,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 13.sp,
        color: strokeMainDark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPrimaryBG_Dark,
        foregroundColor: buttonTextDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: typographyMainDark,
      secondary: buttonSecondaryDark,
      background: backgroundDark,
      surface: backgroundDark,
      error: Colors.red,
      onPrimary: buttonTextDark,
      onSecondary: buttonSecondaryDark,
      onBackground: paragraphDark,
      onSurface: headingDark,
      onError: Colors.black,
    ),
  );
}

/// =================================================
/// :capital_abcd: TYPOGRAPHY STYLES
/// =================================================

class AppTypography {
  // ===========================
  // Heading Styles
  // ===========================
  static TextStyle headingColor36(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 36.sp,
        fontWeight: FontWeight.bold,
        color: headingColor(context),
      );
  static TextStyle headingColor26(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
        color: headingColor(context),
      );
  static TextStyle headingColor22(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: headingColor(context),
      );

  static TextStyle headingColor20(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: headingColor(context),
      );

  static TextStyle headingColor18(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: headingColor(context),
      );

  static TextStyle headingColor16(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: headingColor(context),
      );static TextStyle headingColor15(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: headingColor(context),
      );
  static TextStyle headingColor14(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: headingColor(context),
      );

  static TextStyle headingColor12(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: headingColor(context),
      ); static TextStyle headingColor10(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        color: headingColor(context),
      );

  // ===========================
  // Paragraph Styles
  // ===========================
  static TextStyle paragraphColor24(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 24.sp,
    fontWeight: FontWeight.w500,
    color: paragraphColor(context),
  );  static TextStyle paragraphColor20(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 20.sp,
    fontWeight: FontWeight.w500,
    color: paragraphColor(context),
  );
  static TextStyle paragraphColor18(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: paragraphColor(context),
      );

  static TextStyle paragraphColor16(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: paragraphColor(context),
      );

  static TextStyle paragraphColor15(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: paragraphColor(context),
      );static TextStyle paragraphColor14(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: paragraphColor(context),
      );
  static TextStyle paragraphColor12(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: paragraphColor(context),
  );
  // ===========================
  // Main Typography Styles
  // ===========================
  static TextStyle mainTypographyColor55(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 55.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      );
  static TextStyle mainTypographyColor30(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 30.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      ); static TextStyle mainTypographyColor24(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      ); static TextStyle mainTypographyColor22(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      ); static TextStyle mainTypographyColor20(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: mainTypographyColor(context),
      );static TextStyle mainTypographyColor18(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      );

  static TextStyle mainTypographyColor16(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      );
  static TextStyle mainTypographyColor15(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      );

  static TextStyle mainTypographyColor14(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      );
  static TextStyle mainTypographyColor12(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: mainTypographyColor(context),
      );
  // ===========================
  // Main Typography Styles
  // ===========================
  static TextStyle secondaryTypographyColor16(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: SecondaryTypographyColor(context),
  );
  // ===========================
  // Primary Button Text Styles
  // ===========================
  static TextStyle buttonText36(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 36.sp,
        fontWeight: FontWeight.bold,
        color: buttonTextColor(context),
      );
  static TextStyle buttonText24(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: buttonTextColor(context),
      );
  static TextStyle buttonText20(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: buttonTextColor(context),
      );
  static TextStyle buttonText18(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: buttonTextColor(context),
      );
  static TextStyle buttonText16(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: buttonTextColor(context),
      );

  static TextStyle buttonText15(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: buttonTextColor(context),
      );
  static TextStyle buttonText14(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: buttonTextColor(context),
      );static TextStyle buttonText12(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: buttonTextColor(context),
      );

  // ===========================
  // Secondary Button Text Styles
  // ===========================
  static TextStyle buttonSecondary(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: buttonTextColor(context),
      );

  // ===========================
  // White Button Text Styles
  // ===========================
  static TextStyle buttonWhite20(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: buttonWhiteColor(context),
      );
  static TextStyle buttonWhite18(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: buttonWhiteColor(context),
      );
  static TextStyle buttonWhite16(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: buttonWhiteColor(context),
      );
  static TextStyle buttonWhite14(BuildContext context) => TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: buttonWhiteColor(context),
      );
  // ===========================
  // Green Button Text Styles
  // ===========================
  static TextStyle buttonGreen22(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: buttonGreenColor(context),
  ); static TextStyle buttonGreen20(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: buttonGreenColor(context),
  ); static TextStyle buttonGreen18(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: buttonGreenColor(context),
  ); static TextStyle buttonGreen16(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: buttonGreenColor(context),
  );
  static TextStyle buttonGreen14(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: buttonGreenColor(context),
  );
  static TextStyle buttonGreen12(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: buttonGreenColor(context),
  );
  // ===========================
// Green Red Text Styles
// ===========================
  static TextStyle buttonRed24(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: buttonRedColor(context),
  );static TextStyle buttonRed22(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: buttonRedColor(context),
  );static TextStyle buttonRed20(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: buttonRedColor(context),
  );
  static TextStyle buttonRed18(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: buttonRedColor(context),
  );
  static TextStyle buttonRed16(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: buttonRedColor(context),
  );
  static TextStyle buttonRed14(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: buttonRedColor(context),
  );
  static TextStyle buttonRed12(BuildContext context) => TextStyle(
    fontFamily: 'IBMPlexSansArabic',
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: buttonRedColor(context),
  );
}
