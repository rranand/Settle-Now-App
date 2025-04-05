import 'package:flutter/material.dart';

Widget dateOnCard(String date) {
  return Text(date, style: TextStyle(color: Colors.grey));
}

Widget subTextOnCard(
  String text, {
  Color? textColor = Colors.grey,
  FontWeight? fontWeight = FontWeight.w400,
}) {
  return Text(
    text,
    style: TextStyle(color: textColor, fontSize: 12, fontWeight: fontWeight),
  );
}
