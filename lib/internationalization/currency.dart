import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatCurrency(
  double amount,
  BuildContext context, {
  String locale = "en_IN",
}) {
  final locale = ui.Locale(
    Localizations.localeOf(context).languageCode,
    Localizations.localeOf(context).countryCode,
  );
  var format = NumberFormat.simpleCurrency(locale: locale.toString());
  return NumberFormat.currency(
    symbol: format.currencySymbol,
    name: format.currencyName,
    decimalDigits: 2,
  ).format(amount);
}
