import 'package:flutter/material.dart';
import 'package:settlenow/screens/JoinRoom.dart';

class RouteServices {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    return MaterialPageRoute(builder: (_) {
      int ind = -1;
      if (routeSettings.name.toString().indexOf("/room/") >= 0) {
        ind = routeSettings.name.toString().indexOf("/room/") + 6;
      } else {
        ind = routeSettings.name.toString().indexOf("/lend/") + 6;
      }
      return RoomJoin(roomKey: routeSettings.name.toString().substring(ind));
    });
  }
}

class NavKey {
  static final navKey = new GlobalKey<NavigatorState>();
}
