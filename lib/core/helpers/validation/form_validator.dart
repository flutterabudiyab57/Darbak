
import 'package:darbak/core/helpers/validation/validation.dart';
import 'package:flutter/cupertino.dart';

import '../../../language/locale.dart';

class FormValidator {
  static String? passwordValidate(BuildContext context, String? value) {
    final passwordValidator = Validate.validatePassword(context, value);
    return passwordValidator;
  }

  static String? passwordConfirmValidate(
      BuildContext context, String? value, String? confirmValue) {
    final passwordValidator =
    Validate.validatePassword(context, value, confirmPassword: confirmValue);
    return passwordValidator;
  }

  static String? emailValidate(BuildContext context, String? value) {
    final emailValidator = Validate.validateEmail(context, value);
    return emailValidator;
  }

  static String? phoneValidate(BuildContext context, String? value) {
    final phoneValidator = Validate.validatePhoneNumber(context, value);
    return phoneValidator;
  }

  static String? phoneValidateWithCountry(
      BuildContext context, String? value, String countryCode) {
    final phoneValidator =
    Validate.validatePhoneNumberWithCountry(context, value, countryCode);
    return phoneValidator;
  }

  static String? nameValidate(BuildContext context, String? value) {
    final nameValidator = Validate.validateName(context, value);
    return nameValidator;
  }

  static String? numValidate(BuildContext context, String? value) {
    final numberValidator = Validate.validateUserId(context, value);
    return numberValidator;
  }

  static String? numVisitValidate(BuildContext context, String? value) {
    final numberValidator = Validate.validateUserIdVisit(context, value);
    return numberValidator;
  }

  static String? passportValidate(BuildContext context, String? value) {
    final locale = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return locale.isDirectionRTL(context)
          ? 'الرجاء إدخال رقم جواز السفر'
          : 'Please enter the passport number';
    }

    // Pattern: 3-15 characters, alphanumeric, not all zeros
    String pattern = r'^(?!^0+$)[a-zA-Z0-9]{3,15}$';
    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return locale.isDirectionRTL(context)
          ? 'يجب أن يكون بين 3 إلى 15 أحرفًا وأرقامًا'
          : 'Must be 3 to 15 letters and numbers.';
    }

    return null;
  }

  static String? creditValidate(BuildContext context, String? value) {
    final validator = Validate.validateCreditCardNumber(context, value);
    return validator;
  }

  static String? cvvValidate(BuildContext context, String? value) {
    final validator = Validate.validateCVV(context, value);
    return validator;
  }

  static String? monthValidate(BuildContext context, String? value) {
    final validator = Validate.validateMonth(context, value);
    return validator;
  }

  static String? yearValidate(
      BuildContext context, String? yearValue, String? monthValue) {
    final validator = Validate.validateYear(context, yearValue, monthValue);
    return validator;
  }

  static String? dateValidate(String? value) {
    final validator = Validate.validateDate(value);
    return validator;
  }
}