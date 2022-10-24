import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

showToast(BuildContext context, String show) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(show),
      action: SnackBarAction(
          label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
    ),
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
