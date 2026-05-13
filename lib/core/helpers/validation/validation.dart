import 'package:flutter/cupertino.dart';
import '../../../language/locale.dart';

class Validate {
  static String? validateName(BuildContext context , String? value) {
    final locale = AppLocalizations.of(context);

    if (value == null) {
      return null;
    }
    if (value.isEmpty) {
      return locale!.pleaseEnterName;
    }

    if (value.length < 4) {
      return locale!.enterNameMiniChars;
    }
    return null;
  }

  static String? validateEmail(BuildContext context , String? value, {String? error}) {
    final locale = AppLocalizations.of(context);

    if (value == null) return null;
    if (value.isEmpty) {
      return locale!.pleaseEnterEmail;
    }
    const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final RegExp regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) return locale!.enterValidEmail;

    if (error != null) return error;

    return null;
  }

  static String? validateSelectCountry(String? value) {
    if (value == null) {
      return null;
    }
    if (value.isEmpty) {
      return 'Please select country';
    }
    return null;
  }

  static String? validateUserId(BuildContext context, String? value) {
    final locale = AppLocalizations.of(context);

    if (value == null) {
      return null;
    }

    if (value.isEmpty) {
      return locale!.pleaseEnterIdNumber;
    }

    if (value.length != 10) {
      return locale!.idMustBe10Digits;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return locale!.pleaseEnterNumbersOnly;
    }

    if (!value.startsWith('1')) {
      return locale!.idMustStartWith1;
    }

    return null;
  }

  static String? validateUserIdVisit(BuildContext context, String? value) {
    final locale = AppLocalizations.of(context);

    if (value == null) {
      return null;
    }

    if (value.isEmpty) {
      return locale!.pleaseEnterIdNumber;
    }

    if (value.length != 10) {
      return locale!.idMustBe10Digits;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return locale!.pleaseEnterNumbersOnly;
    }

    if (!value.startsWith('2')) {
      return locale!.iqamaMustStartWith2;
    }

    return null;
  }

  static String? validatePhoneNumber(BuildContext context, String? value) {
    final locale = AppLocalizations.of(context);

    if (value == null) {
      return null;
    }

    if (value.isEmpty) {
      return locale!.pleaseEnterPhoneNumber;
    }

    // The regex pattern for Saudi phone number
    final regex = RegExp(r'^(009665|9665|\+9665|5)(5|3|6|4|9|1|8|7|0)([0-9]{7})$');

    if (!regex.hasMatch(value)) {
      return locale!.pleaseEnterValidPhone;
    }

    return null;
  }

  // دالة جديدة للتحقق من رقم الهاتف مع الكود الدولي
  static String? validatePhoneNumberWithCountry(
      BuildContext context,
      String? value,
      String countryCode
      ) {
    final locale = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return locale!.pleaseEnterPhoneNumber;
    }

    // التحقق من أن القيمة تحتوي على أرقام فقط
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return locale!.pleaseEnterNumbersOnly;
    }

    // إذا كان الكود السعودي (966)
    if (countryCode == '966') {
      if (value.length != 9) {
        return locale!.saudiPhoneMustBe9Digits;
      }
      // التحقق من أن الرقم يبدأ بـ 5
      if (!value.startsWith('5')) {
        return locale!.saudiPhoneMustStartWith5;
      }
    } else {
      // للدول الأخرى
      if (value.length < 7 || value.length > 15) {
        return locale!.invalidPhoneNumber;
      }
    }

    return null;
  }

  // دالة للتحقق من قوة كلمة المرور (للتلوين الديناميكي)
  static PasswordStrength checkPasswordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return PasswordStrength.empty;
    }

    if (value.length < 8) {
      return PasswordStrength.weak;
    }

    return PasswordStrength.strong;
  }

  static String? validateOldPassword(
      BuildContext context,
      String? value,
      String? savedPassword,
      ) {
    final locale = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return locale!.pleaseEnterPassword;
    }

    if (value.length < 8) {
      return locale!.passwordTooShort;
    }

    if (savedPassword != null && value != savedPassword) {
      return locale!.oldPasswordIncorrect;
    }

    return null;
  }

  static String? validatePassword(
      BuildContext context,
      String? value, {
        String? confirmPassword,
      }) {
    final locale = AppLocalizations.of(context);

    if (value == null || value.isEmpty) {
      return locale!.pleaseEnterPassword;
    }

    if (value.length < 8) {
      return locale!.passwordTooShort;
    }

    if (confirmPassword != null && value != confirmPassword) {
      return locale!.passwordNotMatching;
    }

    return null;
  }

  static String? validateCreditCardNumber(BuildContext context, String? value) {
    final locale = AppLocalizations.of(context);
    if (value == null) return null;
    if (value.isEmpty) return locale!.pleaseEnterValidCredit;

    // إزالة الـ dashes اللي بيضيفها CardNumberFormatter
    final cleanValue = value.replaceAll('-', '').replaceAll(' ', '').trim();

    // التحقق من إن كله أرقام وطوله صح
    if (!RegExp(r'^\d{13,19}$').hasMatch(cleanValue)) {
      return locale!.pleaseEnterValidCredit;
    }

    // Luhn Algorithm
    if (!_isValidLuhn(cleanValue)) {
      return locale!.pleaseEnterValidCredit;
    }

    return null;
  }

  static bool _isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }
  static String? validateCVV(BuildContext context, String? value) {
    final locale = AppLocalizations.of(context)!;

    if (value == null || value.trim().isEmpty) {
      return locale.enterValidCVV;
    }

    final regExp = RegExp(r'^\d{3,4}$');

    if (!regExp.hasMatch(value.trim())) {
      return locale.enterValidCVV;
    }

    return null;
  }
  static String? validateDate(String? value) {
    if (value == null) return null;
    if (value.isEmpty) return " ";
    if (value.length < 2) return " ";
    return null;
  }

  static String? validateMonth(BuildContext context, String? monthValue) {
    final locale = AppLocalizations.of(context);

    if (monthValue == null || monthValue.isEmpty) {
      return locale!.pleaseEnterExpireMonth;
    }

    // لازم يكون رقمين بس
    if (!RegExp(r'^\d{2}$').hasMatch(monthValue)) {
      return locale!.pleaseEnterMonthIn2Digits;
    }

    final int month = int.parse(monthValue);

    if (month < 1 || month > 12) {
      return locale!.pleaseEnterValidMonth;
    }

    return null;
  }
  static String? validateYear(BuildContext context, String? yearValue, String? monthValue) {
    final locale = AppLocalizations.of(context);

    if (yearValue == null || yearValue.isEmpty) {
      return locale!.pleaseEnterExpireYear;
    }

    final int? year = int.tryParse(yearValue);
    if (year == null || year < 0) {
      return locale!.pleaseEnterValidYear;
    }

    final DateTime now = DateTime.now();
    final int currentYear = now.year;
    final int currentMonth = now.month;

    if (year + 2000 < currentYear) {
      return locale!.cardIsExpired ;
    }

    if (year + 2000 == currentYear && monthValue != null && monthValue.isNotEmpty) {
      final int? month = int.tryParse(monthValue);
      if (month != null && month < currentMonth) {
        return locale!.cardIsExpired ;
      }
    }

    return null;
  }
}

enum PasswordStrength {
  empty,
  weak,
  strong,
}