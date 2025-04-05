import 'package:flutter/material.dart';

Widget dateOnCard(String date) {
  return Text(date, style: TextStyle(color: Colors.grey));
}

Widget subTextOnCard(String text) {
  return Text(
    text,
    style: TextStyle(
      color: Colors.grey,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );
}
