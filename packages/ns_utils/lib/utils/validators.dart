import 'package:flutter/material.dart';

import '../src.dart';

const String namePattern = r"^[a-zA-Z.']+$";

const String passwordPattern = r'^[a-zA-Z0-9@#$%]{6,}$';

const String emailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

const String enter = "Enter ";
const String enterValidEmail = "Enter valid email";
const String enterValid = "Enter valid ";
const String enterEmail = "Enter email";
const String enterPassword = "Enter password";
const String enterValidPassword = "Enter valid password";
const String emptyMessage = "Can't be Empty";
const String passwordValidationMsg = "Minimum 6 characters,include upper and "
    "lower case letters,numbers,symbols(@,#,\$,%)";

class ValidatorUtil {
  ValidatorUtil._();

  static bool isFormValid(GlobalKey<FormState>? formKey) {
    try {
      final FormState? form = formKey?.currentState;
      if (form != null) {
        if (form.validate()) {
          form.save();
          appLogsNS('$formKey isFormValid:true');
          return true;
        }
      } else {
        errorLogsNS('$formKey isFormValid[_formKey?.currentState] is NULL');
      }
    } on Exception catch (e, s) {
      errorLogsNS('$formKey isFormValid', e, s);
    }
    return false;
  }

  static String? validateEmail(
    String value, {
    String? errorMessage,
  }) {
    appLogsNS("validateEmail : $value ");

    if (value.trim().isEmpty) return enterEmail;

    if (hasMatch(pattern: emailPattern, value: value)) return null;

    return errorMessage ?? enterValidEmail;
  }

  static String? validatePassword(String value) {
    appLogsNS("validatePassword : $value ");

    if (value.trim().isEmpty) return enterPassword;

    if (hasMatch(pattern: passwordPattern, value: value)) return null;

    return passwordValidationMsg;
  }

  static String? validateName(
    String value,
    String label, {
    String? pattern,
  }) {
    appLogsNS("validateName : $value ");

    if (value.trim().isEmpty) return '$enter $label';

    if (hasMatch(pattern: pattern ?? namePattern, value: value)) return null;

    return '$enterValid $label';
  }

  static String? validatePattern(
    String value, {
    required String label,
    required String pattern,
    String? errorMessage,
  }) {
    if (value.trim().isEmpty) return emptyMessage;

    if (hasMatch(pattern: pattern, value: value)) return null;

    return errorMessage ?? '$enterValid $label';
  }

  static String? validateEmptyCheck(String value) {
    if (value.trim().isEmpty) return emptyMessage;

    return null;
  }

  static String? validateEmpty(String value, String label) {
    if (value.trim().isEmpty) return enter + label;

    return null;
  }

  static bool hasMatch({
    required String pattern,
    required String value,
  }) {
    RegExp regex = RegExp(pattern);

    bool result = regex.hasMatch(value);

    appLogsNS('hasMatch $pattern $value => $result');

    return result;
  }
}
