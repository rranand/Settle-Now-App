import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/routes/route_constant.dart';

import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';

import 'package:flutter/material.dart';

import '../others/themes.dart';

class RoomJoin extends StatefulWidget {
  final String roomKey;

  const RoomJoin({Key? key, required this.roomKey}) : super(key: key);

  @override
  State<RoomJoin> createState() => _RoomJoinState();
}

class _RoomJoinState extends State<RoomJoin> {
  String version = '';
  bool darkTheme = false;
  String message = "Joining Room";

  @override
  void dispose() {
    super.dispose();
  }

  Future _roomJoin() async {
    var futureOut = await Future.wait([getAppVersion(), getTheme(context)]);
    version = futureOut[0] as String;
    darkTheme = futureOut[1] as bool;

    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.toggleTheme(darkTheme);

    try {
      var tokenData = await getStringPref("token");
      if (tokenData != null && parseJWT(tokenData) != null) {
        Map<String, dynamic> jsonOutData = parseJWT(tokenData);

        String email = jsonOutData["email"]!;
        String _token = jsonOutData["token"]!;

        if (widget.roomKey.length == 7) {
          Map<String, String> jsonInputData = {
            'email': crypto.encrypt(email),
            'roomKey': crypto.encrypt(widget.roomKey),
          };

          final response = await createHTTPreq(
              'room', http.put, _token, jsonInputData, context);

          if (this.mounted) {
            setState(() {
              message = crypto.decrypt(jsonDecode(response.body)['Message']);
            });
          }
        } else {
          Map<String, String> jsonInputData = {
            'email': crypto.encrypt(email),
            'id': crypto.encrypt(widget.roomKey),
          };

          final response = await createHTTPreq(
              'lend/addPerson', http.post, _token, jsonInputData, context);

          if (this.mounted) {
            setState(() {
              message = crypto.decrypt(jsonDecode(response.body)['Message']);
            });
          }
        }

        Future.delayed(const Duration(milliseconds: 1000), () {
          if (this.mounted) {
            while (context.canPop()) {
              context.pop();
            }
          }
          context.go(AppRouteConstants.dashboardRouteName,
              extra: {"firstTime": false});
        });
      } else {
        if (this.mounted) {
          while (context.canPop()) {
            context.pop();
          }
          context.push(AppRouteConstants.loginRouteName);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["JoinRoom->_roomJoin"]);
      }

      if (this.mounted) {
        while (context.canPop()) {
          context.pop();
        }
      }
      context.go(AppRouteConstants.dashboardRouteName,
          extra: {"firstTime": false});
    }
  }

  @override
  void initState() {
    super.initState();
    _roomJoin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              message,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ],
        )));
  }
}
