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

  static String? validatePhoneNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    } else if (value.trim().length == 9 || int.tryParse(value.trim()) == null) {
      return 'Please enter valid phone no.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    } else if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    } else if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
      return 'Invalid name format';
    }
    return null;
  }

  static String? validateRoomKey(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room Key is required';
    } else if (value.trim().length != 7) {
      return 'Invalid Room Key';
    } else if (!RegExp(r"^[a-zA-Z0-9]+$").hasMatch(value.trim())) {
      return 'Invalid Room Key';
    }
    return null;
  }

  static String? validateRoomName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room Name is required';
    } else if (value.trim().length < 4) {
      return 'Room Name must be at least 4 characters';
    } else if (RegExp(r"[<>';=%()\[\]{}\\\/^`*,\$]").hasMatch(value.trim())) {
      return 'Invalid Room Key';
    }
    return null;
  }
}
