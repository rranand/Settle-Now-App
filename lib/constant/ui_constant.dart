import 'dart:math';

import 'package:flutter/material.dart';
import 'package:settlenow_v2/model/user_model.dart';

class UiConstant {
  static const double cardTitleTextSize = 18;
  static const double cardBorderLeftSideStripWidth = 6;
  static const double cardBorderRadius = 12;
  static const double cardSpaceBetweenSubText = 4;
  static const double cardSpaceAfterSubText = 8;
  static const double cardElevation = 4;
  static const double cardPadding = 10;
  static const double spaceBetweenCard = 12;
  static const double cardFixedHeight = 160;

  static const double scrollBarWidth = 4;
  static const double maxWidth = 500;

  static const double spaceBetweenSection = 20;
  static const double spaceBetweenRowSection = 8;
  static const double spaceAtBottom = 80;

  static const String expenseDatetimeFormat = 'MMMM dd, yyyy hh:mm a';

  static const Icon indianRupeeSymbol = Icon(
    IconData(0x20B9, fontFamily: 'MaterialIcons'),
  );

  static List<Color> colorsWithShade50 = [
    Colors.red.shade50,
    Colors.green.shade50,
    Colors.blue.shade50,
    Colors.yellow.shade50,
    Colors.orange.shade50,
    Colors.purple.shade50,
    Colors.teal.shade50,
    Colors.pink.shade50,
    Colors.brown.shade50,
    Colors.grey.shade50,
    Colors.indigo.shade50,
    Colors.lime.shade50,
    Colors.cyan.shade50,
    Colors.amber.shade50,
    Colors.deepOrange.shade50,
    Colors.deepPurple.shade50,
    Colors.lightGreen.shade50,
    Colors.lightBlue.shade50,
  ];

  static List<Color> colorsWithShade100 = [
    Colors.red.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.yellow.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.pink.shade100,
    Colors.brown.shade100,
    Colors.grey.shade100,
    Colors.indigo.shade100,
    Colors.lime.shade100,
    Colors.cyan.shade100,
    Colors.amber.shade100,
    Colors.deepOrange.shade100,
    Colors.deepPurple.shade100,
    Colors.lightGreen.shade100,
    Colors.lightBlue.shade100,
  ];

  static List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.indigo,
    Colors.lime,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightGreen,
    Colors.lightBlue,
  ];

  static List<UserModel> users = [
    UserModel.fromBasicInfo(
      id: 'u1',
      name: 'Riya Kapoor',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u2',
      name: 'Aarav',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u3',
      name: 'Meera Shah',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u4',
      name: 'Kabir',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u5',
      name: 'Anaya Sen',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u6',
      name: 'Ishaan Malhotra Anaya',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u7',
      name: 'Tara',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u8',
      name: 'Dev Verma',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
    UserModel.fromBasicInfo(
      id: 'u9',
      name: 'Zoya',
      profileImage:
          'https://picsum.photos/id/${1 + Random().nextInt(100)}/200/300',
    ),
  ];
}
