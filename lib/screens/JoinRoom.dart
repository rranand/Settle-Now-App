import 'dart:convert';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/screens/dashboard.dart';

import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';

import 'package:flutter/material.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomJoin extends StatefulWidget {
  final String roomKey;

  const RoomJoin({Key? key, required this.roomKey}) : super(key: key);

  @override
  State<RoomJoin> createState() => _RoomJoinState();
}

class _RoomJoinState extends State<RoomJoin> {
  String version = '';
  late SharedPreferences prefs;
  String message = "Joining Room";

  @override
  void dispose() {
    super.dispose();
  }

  Future _roomJoin() async {
    version = await getAppVersion();
    prefs = await SharedPreferences.getInstance();

    try {
      if (await prefs.getString("token") != null &&
          parseJWT(await prefs.getString("token")!) != null) {
        Map<String, dynamic> jsonOutData =
            parseJWT(await prefs.getString("token")!);

        String email = jsonOutData["email"]!;
        String _token = jsonOutData["token"]!;

        if (widget.roomKey.length == 7) {
          Map<String, String> jsonInputData = {
            'email': crypto.encrypt(email),
            'roomKey': crypto.encrypt(widget.roomKey),
          };

          final response =
              await createHTTPreq('room', http.put, _token, jsonInputData);

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
              'lend/addPerson', http.post, _token, jsonInputData);

          if (this.mounted) {
            setState(() {
              message = crypto.decrypt(jsonDecode(response.body)['Message']);
            });
          }
        }

        Future.delayed(const Duration(milliseconds: 1000), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DashBoard(
                version: version,
                firstTime: false,
              ),
            ),
            (Route<dynamic> route) => false,
          );
        });
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } on Exception catch (_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard(
            version: version,
            firstTime: false,
          ),
        ),
        (Route<dynamic> route) => false,
      );
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
