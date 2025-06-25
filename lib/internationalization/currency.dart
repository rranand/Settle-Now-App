import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(
  double amount,
  BuildContext context, {
  String locale = "en_IN",
}) {
  amount = (amount.abs() < 1e-2) ? 0 : amount;

  final locale = ui.Locale(
    Localizations.localeOf(context).languageCode,
    Localizations.localeOf(context).countryCode,
  );
  var format = NumberFormat.simpleCurrency(locale: locale.toString());
  String formattedAmount = NumberFormat.currency(
    symbol: format.currencySymbol,
    name: format.currencyName,
    decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    customPattern: amount.truncateToDouble() == amount ? '¤#,##0' : '¤#,##0.00',
  ).format(amount);

  debugPrint("Amount $amount $formattedAmount");
  return formattedAmount;
}
