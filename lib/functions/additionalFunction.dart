import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path/path.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
        'id': data.browserName.name,
        'device': data.browserName.name + " (" + data.platform! + ")",
        'userAgent': data.userAgent
      };
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
      return <String, dynamic>{
        'id': build.id,
        'device': build.product,
        'model': build.model,
        'product': build.product,
        'serial': build.serialNumber,
        'sdkInt': build.version.sdkInt.toString(),
        'release': build.version.release,
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo build = await deviceInfoPlugin.iosInfo;
      return <String, dynamic>{
        'id': build.identifierForVendor,
        'device': build.name,
        'model': build.model,
        'product': build.systemName,
        'serial': build.identifierForVendor,
        'sdkInt': build.utsname.version.toString(),
        'release': build.utsname.release
      };
    }
  } on PlatformException {}

  return <String, dynamic>{'id': 'Not Found', 'device': 'Not Found'};
}

addCorsinImage(String picUrl) {
  if (kIsWeb) {
    if (picUrl.contains("https://drive.google.com/uc?export=view&id=")) {
      return picUrl.replaceAll("https://drive.google.com/uc?export=view&id=",
              dotenv.env["drivewebUrl"]!) +
          '?key=' +
          dotenv.env["googleApiKey"]! +
          '&alt=media&source=downloadUrl';
    }
    return picUrl.replaceAll(
            "https://drive.google.com/uc?id=", dotenv.env["drivewebUrl"]!) +
        '?key=' +
        dotenv.env["googleApiKey"]! +
        '&alt=media&source=downloadUrl';
  } else {
    return picUrl;
  }
}

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return await packageInfo.version.toString();
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
          child: CircularProgressIndicator.adaptive(),
        );
      });
}

showToast(BuildContext context, String show, IconData icon) {
  FToast fToast = FToast();
  fToast.init(context);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.grey.shade700,
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        SizedBox(
          width: 12.0,
        ),
        Expanded(
          child: Text(
            show,
            style: TextStyle(color: Colors.white),
          ),
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
      foreground: kIsWeb ? null : (Paint()..shader = gradient),
    ),
  );
}

Future<Map<String, String>> getDataFromNotification(String? payload) async {
  String text = payload!;
  if (text.isEmpty || text == '{}') {
    return {};
  }
  List<String> cols = text.substring(1, text.length - 1).split(', ');
  final Map<String, String> data = {};
  for (int i = 0; i < cols.length; i++) {
    List<String> obj = cols[i].split(': ');
    data[obj[0]] = crypto.decrypt(obj[1]);
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  var tokenData = await prefs.getString("token");
  if (tokenData != null) {
    var parseTokenData = parseJWT(tokenData.toString());
    if (parseTokenData != null) {
      Map<String, dynamic> ma = parseTokenData;
      data["email"] = ma["email"];
      data["token"] = ma["token"];
      data["version"] = await getAppVersion();
      return data;
    } else {
      return {};
    }
  } else {
    return {};
  }
}

Future<bool> checkAndroidInsideWeb() async {
  if (kIsWeb) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
    final userAgent = webBrowserInfo.userAgent.toString().toLowerCase();
    if (userAgent.contains("android")) return true;
  }

  return false;
}

onException(BuildContext context, Exception err, StackTrace stackTrace,
    {String reason = "", List<String>? info}) async {
  pushCrashDataToFirebase(err, stackTrace, reason: reason, info: info);
  showToast(context, "Server Error Try Again", Icons.warning_rounded);
}

commaSeperator(String amount) {
  final numberFormatter = new NumberFormat('##,##,###.##');
  return numberFormatter.format(double.parse(amount));
}

formatDateTime(String dateTime) {
  DateFormat dateFormat = DateFormat(dotenv.env["dateTimeFormat"]!);
  DateFormat dateFormat_new = DateFormat("MMM dd yyyy h:mm a");
  DateTime olddateTime = dateFormat.parse(dateTime);
  return dateFormat_new.format(olddateTime);
}

createJWT(String email, String input) async {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  String key = '';
  final jwt = JWT(jsonDecode(input));

  if (kIsWeb) {
    WebBrowserInfo data = await deviceInfoPlugin.webBrowserInfo;
    key = data.browserName.name + '###' + data.platform! + '###' + email;
  } else if (Platform.isAndroid) {
    AndroidDeviceInfo build = await deviceInfoPlugin.androidInfo;
    key = build.id +
        '###' +
        build.serialNumber +
        '###' +
        build.fingerprint +
        '###' +
        email;
  } else if (Platform.isIOS) {
    IosDeviceInfo build = await deviceInfoPlugin.iosInfo;
    key = build.systemVersion +
        '###' +
        build.model +
        '###' +
        build.identifierForVendor.toString() +
        '###' +
        email;
  } else {
    key = DateTime.now().toString() + '###PLATFORM_NO_DEVICE_FOUND###' + email;
  }
  return crypto.encrypt(jwt.sign(SecretKey(key)));
}

parseJWT(String token) {
  try {
    String jwToken = crypto.decrypt(token);
    var jwtData = JWT.tryDecode(jwToken);
    if (jwtData == null) {
      return null;
    }
    return jwtData.payload;
  } on Exception catch (_) {
    return null;
  }
}

String fixPhoneNumber(String phone) {
  if (phone.startsWith("+91")) {
    phone = phone.substring(3);
  }
  if (phone.startsWith("0")) {
    phone = phone.substring(1);
  }
  return phone.replaceAll(" ", "");
}

Future<void> deleteDB() async {
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'contact_data.db');

  await deleteDatabase(path);
}

Future<String> getDBFilePath(String dbName) async {
  var databasesPath = await getDatabasesPath();
  return join(databasesPath, dbName);
}

List<FriendEach> getUnionOfContacts(
    List<Map> fromPhone, List<FriendEach> fromDB) {
  Set<String> st = new Set();

  for (int i = 0; i < fromDB.length; i++) {
    st.add(fromDB[i].email);
  }

  for (int i = 0; i < fromPhone.length; i++) {
    if (!st.contains(fromPhone[i]['email'])) {
      fromDB.add(FriendEach.fromLocal(fromPhone[i]));
    }
  }

  return fromDB;
}

createJSONDataTOJWT(dynamic data) {
  final jwt = JWT(data);

  return crypto.encrypt(jwt.sign(SecretKey(dotenv.env["jwtToken"]!),
      expiresIn: Duration(seconds: 100)));
}

extractJSONfromJWT(String data) async {
  try {
    data = crypto.decrypt(data);
    final reqData = await JWT.verify(data, SecretKey(dotenv.env["jwtToken"]!));
    return jsonEncode(reqData.payload);
  } on Exception catch (_) {}

  return {};
}

pushCrashDataToFirebase(Exception err, StackTrace stackTrace,
    {String reason = "", List<String>? info}) async {
  if (kIsWeb) {
    return;
  }
  Map<String, dynamic> additionalData = {};
  if (reason != "") {
    additionalData['reason'] = reason;
  } else {
    additionalData['reason'] = "Unknown";
  }
  if (info!.length > 0) {
    additionalData['information'] = info;
  } else {
    additionalData['information'] = [];
  }
  await FirebaseCrashlytics.instance.recordError(err, stackTrace,
      reason: additionalData['reason'],
      information: additionalData['information']);
}

Future<dynamic> createHTTPreq(String url, Function httpType, String token,
    dynamic JSONData, BuildContext context) async {
  try {
    String tokenization = createJSONDataTOJWT(JSONData);
    Response res = await httpType(Uri.parse(dotenv.env["url"]! + url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': token,
          'Access-Control-Allow-Origin': dotenv.env["url"]!
        },
        body: jsonEncode({"data": tokenization}));

    var resData = jsonDecode(res.body);

    if (resData['data'] != null) {
      String jsonJWTData = jsonDecode(res.body)['data'];
      String responseBody = await extractJSONfromJWT(jsonJWTData);
      if (res.statusCode == 422) {
        var decodedData = jsonDecode(responseBody);
        if (crypto.decrypt(decodedData['Message']) == "Login Expired") {
          removePref(["token", "__token", "___token"]);
          while (context.canPop()) {
            context.pop();
          }
          context.go(AppRouteConstants.loginRouteName);
        }
      }
      final newRes = new Response(responseBody, res.statusCode);
      return newRes;
    }
  } on Exception catch (err, stackTrace) {
    pushCrashDataToFirebase(err, stackTrace,
        reason: "API Error", info: ["createHTTPreq", url]);
  }

  bool isDeviceConnected = await InternetConnectionChecker().hasConnection;
  return new Response(
      jsonEncode({
        "status": false,
        "Message": crypto.encrypt(isDeviceConnected
            ? "Server Error, Try Again!"
            : "No Internet Connection!"),
      }),
      422);
}
