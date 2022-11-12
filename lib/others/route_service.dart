import 'package:flutter/material.dart';
import 'package:settlenow/screens/JoinRoom.dart';

class RouteServices {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) {
      return RoomJoin(roomKey: routeSettings.name.toString().substring(6));
    });
  }
}
