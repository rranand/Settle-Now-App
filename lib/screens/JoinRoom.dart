import 'dart:convert';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/screens/dashboard.dart';

import '../contents.dart' as global;
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
      if (prefs.getString("token") != null &&
          parseJWT(prefs.getString("token")!) != null) {
        Map<String, dynamic> jsonOutData =
            parseJWT(prefs.getString("token")!);

        String email = jsonOutData["email"]!;
        String _token = jsonOutData["token"]!;

        if (widget.roomKey.length == 7) {
          final response = await http.put(Uri.parse(global.url + 'room'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Auth': _token
              },
              body: jsonEncode({
                'email': crypto.encrypt(email),
                'roomKey': crypto.encrypt(widget.roomKey),
              }));

          if (this.mounted) {
            setState(() {
              message = crypto.decrypt(jsonDecode(response.body)['Message']);
            });
          }
        } else {
          final response = await http.post(
              Uri.parse(global.url + 'lend/addPerson'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Auth': _token
              },
              body: jsonEncode({
                'email': crypto.encrypt(email),
                'id': crypto.encrypt(widget.roomKey),
              }));

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
