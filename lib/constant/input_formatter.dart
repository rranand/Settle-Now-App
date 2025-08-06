import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^(\d+)?(\.\d{1,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
