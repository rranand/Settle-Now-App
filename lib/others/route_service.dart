import 'package:flutter/material.dart';
import 'package:settlenow/screens/JoinRoom.dart';

class RouteServices {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) {
      int ind = routeSettings.name.toString().indexOf("/room/") + 6;
      return RoomJoin(
        roomKey: routeSettings.name.toString().substring(ind)
      );
    });
  }
}

class NavKey {
  static final navKey = new GlobalKey<NavigatorState>();
}
