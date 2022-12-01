import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:settlenow/others/crypto.dart';

Future<Map<String, dynamic>> initPlatformState() async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (kIsWeb) {
      WebBrowserInfo data = await deviceInfoPlugin.webBrowserInfo;
      return <String, dynamic>{
        'id': describeEnum(data.browserName),
        'device': describeEnum(data.browserName) + " (" + data.platform! + ")"
      };
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
        return <String, dynamic>{'id': build.id, 'device': build.product};
      }
    }
  } on PlatformException {}

  return <String, dynamic>{'id': 'Not Found', 'device': 'Not Found'};
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return await packageInfo.version.toString();
}

MoveToNext(
    BuildContext context, Widget widget, GlobalKey<FormState> _formKey) async {
  if (_formKey.currentState!.validate()) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }
}

Widget privacyAndVersionBottomAppBar(String version) {
  return BottomAppBar(
    elevation: 0,
    child: ListView(shrinkWrap: true, children: [
      SizedBox(
        height: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              launchUrl(
                Uri.parse("https://settlenow.in/privacy-policy"),
                mode: LaunchMode.inAppWebView,
                webViewConfiguration:
                    const WebViewConfiguration(enableJavaScript: true),
              );
            },
            child: Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 15),
            ),
          ),
          Text(
            "  |  " + "Version: " + version,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
    ]),
  );
}

buildShowDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      });
}

showToast(BuildContext context, String show, {bool flag = true}) {
  FToast fToast = FToast();
  fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.grey.shade700,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          flag ? Icons.check : Icons.close,
          color: Colors.white,
        ),
        SizedBox(
          width: 12.0,
        ),
        Text(
          show,
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 2),
  );
}

Widget textWidget(String text, Shader gradient) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      foreground: Paint()..shader = gradient,
    ),
  );
}

Future<Map<String, String>> getDataFromNotification(String? payload) async {
  String text = payload!;
  List<String> cols = text.substring(1, text.length - 1).split(', ');
  final Map<String, String> data = {};
  for (int i = 0; i < cols.length; i++) {
    List<String> obj = cols[i].split(': ');
    data[obj[0]] = crypto.decrypt(obj[1]);
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.getString("email") != null &&
      prefs.getString("name") != null &&
      prefs.getString("token") != null &&
      prefs.getString("pushToken") != null) {
    data["email"] = prefs.getString("email")!;
    data["token"] = prefs.getString("token")!;
    return data;
  } else {
    return {};
  }
}

onException(BuildContext context) async {
  bool result = await InternetConnectionChecker().hasConnection;

  if (result) {
    showToast(context, "Server Error Try Again", flag: false);
  } else {
    showToast(context, "No Internet Connection", flag: false);
  }
}

commaSeperator(String amount) {
  final numberFormatter = new NumberFormat('##,##,###.##');
  return numberFormatter.format(double.parse(amount));
}
