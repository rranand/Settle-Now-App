import 'package:email_validator/email_validator.dart';

class CustomValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter OTP';
    } else if (value.trim().length != 6 || int.tryParse(value.trim()) == null) {
      return 'Please enter valid OTP';
    }
    return null;
  }
}
