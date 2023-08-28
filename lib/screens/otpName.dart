import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:settlenow/screens/onBoarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contents.dart' as global;

import '../others/themes.dart';

class OtpName extends StatefulWidget {
  final String email;
  final String version;

  const OtpName({Key? key, required this.email, required this.version})
      : super(key: key);

  @override
  _OtpNameState createState() => _OtpNameState();
}

class _OtpNameState extends State<OtpName> {
  bool error = false;
  String errorText = "Invalid OTP!";
  bool errorN = false;
  final String errorTextN = "Invalid Name!";
  late var data = null;
  bool verified = false;
  var JsonData = null;
  var JD = null;
  String token = "";
  String deviceToken = "";
  final TextEditingController _name = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  late SharedPreferences prefs;
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  bool isOnBoardingCompleted = false;

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future _initialisation() async {
    prefs = await SharedPreferences.getInstance();
    _deviceData = await initPlatformState();
    getDeviceTokenToSendNotification();

    final response = await http.post(Uri.parse(global.url + 'login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.email),
        }));
    token = crypto.encrypt(widget.email +
        "#" +
        _deviceData['id'] +
        "#" +
        DateTime.now().toString());

    if (response.statusCode == 200) {
      if (this.mounted) {
        setState(() {
          data = jsonDecode(response.body);
        });
      }

      final ipAdd = await http.get(
        Uri.parse('http://ip-api.com/json'),
      );

      if (this.mounted) {
        setState(() {
          JD = jsonDecode(ipAdd.body);
        });
      }
    } else if (jsonDecode(response.body)['maintenance'] != null &&
        jsonDecode(response.body)['maintenance']) {
      if (this.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Maintenance()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']),
          Icons.close);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }

    if (prefs.getBool("isOnBoardingCompleted") != null) {
      isOnBoardingCompleted = await prefs.getBool("isOnBoardingCompleted")!;
    } else {
      await prefs.setBool("isOnBoardingCompleted", false);
    }
  }

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceToken = token.toString();
  }

  verifyStatus(String name, String otp, BuildContext context) async {
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      final response = await http.post(Uri.parse(global.url + 'verify'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'otp': crypto.encrypt(otp),
            'name': crypto.encrypt(name),
            'token': crypto.encrypt(token)
          }));

      JsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Map<String, String> jsonInputData = {
          "email": widget.email,
          "name": "",
          "token": token,
          "pushToken": deviceToken
        };

        if (crypto.decrypt(data['Name']) == 'Unknown') {
          jsonInputData.update("name", (value) => name);
        } else {
          jsonInputData.update("name", (value) => crypto.decrypt(data['Name']));
        }

        String jwToken =
            await createJWT(widget.email, jsonEncode(jsonInputData));

        prefs.setString("token", jwToken);
        prefs.setBool("isGoogle", false);

        final resp = await http.patch(Uri.parse(global.url + 'verify'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({
              'email': crypto.encrypt(widget.email),
              'country': crypto.encrypt(JD['country']),
              'ip': crypto.encrypt(JD['query']),
              'state': crypto.encrypt(JD['regionName']),
              'city': crypto.encrypt(JD['city']),
              'isp': crypto.encrypt(JD['isp']),
              'device': crypto.encrypt(_deviceData['device']),
              'deviceID': crypto.encrypt(_deviceData['id']),
              'deviceToken': crypto.encrypt(deviceToken)
            }));

        var remainingData = jsonDecode(resp.body)['data'];

        if (resp.statusCode == 200) {
          await prefs.setString("___token", remainingData['createdOn']);
          await prefs.setString("__token", remainingData['phoneNo']);
        } else {
          await prefs.setString("___token", crypto.encrypt(""));
          await prefs.setString("__token", crypto.encrypt(""));
        }

        if (this.mounted) {
          Navigator.pop(context);
        }
        if (this.mounted) {
          isOnBoardingCompleted
              ? Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashBoard(
                      version: widget.version,
                      firstTime: true,
                    ),
                  ),
                  (Route<dynamic> route) => false,
                )
              : Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => onBoarding(
                      version: widget.version,
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
        }
      } else {
        error = true;
        if (this.mounted) {
          setState(() {
            errorText = crypto.decrypt(JsonData['Message']);
          });
        }
        if (this.mounted) {
          Navigator.pop(context);
        }
      }
    } on Exception catch (_) {
      if (this.mounted) {
        Navigator.pop(context);
      }
      if (this.mounted) {
        await onException(context);
      }
    }
  }

  getConnectivity() =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) async {
          isDeviceConnected = await InternetConnectionChecker().hasConnection;
          setState(() {});
          if (!isDeviceConnected && isAlertSet == false) {
            setState(() => isAlertSet = true);
          } else if (isDeviceConnected && isAlertSet == true) {
            Future.delayed(Duration(seconds: 1), () {
              setState(() => isAlertSet = false);
            });
          }
        },
      );

  @override
  void initState() {
    super.initState();
    getConnectivity();
    _initialisation();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: (data == null
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          themeProvider.darkTheme
                              ? 'assets/Images/SN_dark.jpg'
                              : 'assets/Images/SN.jpg',
                          height: 150,
                          width: 150,
                        ),
                        Text(
                          "Settle Now",
                          style: TextStyle(
                            fontSize: height >= 800 ? 60 : 40,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.darkTheme
                                ? null
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        (crypto.decrypt(data['Name']) == 'Unknown')
                            ? AutofillGroup(
                                child: TextFormField(
                                  controller: _name,
                                  keyboardType: TextInputType.text,
                                  maxLength: 70,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 18),
                                  autofillHints: [AutofillHints.email],
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: const EdgeInsets.all(8.0),
                                    hintText: "Aditya",
                                    labelText: "Enter Name",
                                    errorText:
                                        (errorN == true ? errorTextN : null),
                                    errorStyle: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              )
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              ),
                        TextField(
                          controller: _otp,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 18),
                          autocorrect: false,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(8.0),
                            hintText: "000000",
                            labelText: "Enter OTP",
                            counterText: "",
                            errorText: (error == true ? errorText : null),
                            errorStyle: const TextStyle(fontSize: 15),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 140,
                          height: 45,
                          child: ElevatedButton(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                            onPressed: () {
                              RegExp validateName = RegExp(r'[A-Za-z]{3,}');
                              RegExp validateOTP = RegExp(r'^[\d]{6}');
                              errorN =
                                  ((crypto.decrypt(data['Name']) != 'Unknown')
                                      ? false
                                      : !validateName.hasMatch(_name.text));
                              error = !validateOTP.hasMatch(_otp.text);
                              if (!(error || errorN)) {
                                if (crypto.decrypt(data['Name']) == 'Unknown') {
                                  verifyStatus(_name.text, _otp.text, context);
                                } else {
                                  verifyStatus("##", _otp.text, context);
                                }
                              }
                              if (this.mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    )),
            )),
      ),
      bottomNavigationBar: isAlertSet
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                color: isDeviceConnected ? Colors.green : Colors.red,
              ),
              height: 40,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Center(
                    child: Text(
                  isDeviceConnected
                      ? "You are connected to Internet"
                      : "You aren't connected to Internet",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                )),
              ),
            )
          : BottomAppBar(
              elevation: 0,
              color: Colors.transparent,
              child: ListView(shrinkWrap: true, children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: 'By Signing In, You Agree To The ',
                      style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                      children: [
                        TextSpan(
                          text: 'Privacy Policy',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              launchUrl(
                                Uri.parse(
                                    "https://settlenow.in/privacy-policy"),
                                mode: LaunchMode.inAppWebView,
                                webViewConfiguration:
                                    const WebViewConfiguration(
                                        enableJavaScript: true),
                              );
                            },
                        ),
                      ]),
                ),
                SizedBox(
                  height: 25,
                )
              ]),
            ),
    );
  }
}
