import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/GoogleSignIN.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/otpName.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../contents.dart' as global;

import '../others/themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailId = TextEditingController();
  late SharedPreferences prefs;
  bool canLoad = false;
  String deviceToken = "";
  final _formKey = GlobalKey<FormState>();
  bool darkTheme = false;
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  double textScale = 1.0;
  String version = "";

  Future _extractEmail() async {
    version = await getAppVersion();
    prefs = await SharedPreferences.getInstance();
    _deviceData = await initPlatformState();

    if (prefs.getBool('darkTheme') != null) {
      darkTheme = prefs.getBool('darkTheme')!;
    } else {
      darkTheme =
          (Brightness.dark == MediaQuery.of(context).platformBrightness);
      prefs.setBool('darkTheme', darkTheme);
    }

    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.toggleTheme(darkTheme);

    if (prefs.getString("email") != null &&
        prefs.getString("name") != null &&
        prefs.getString("token") != null &&
        prefs.getString("pushToken") != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => DashBoard(
            version: version,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      canLoad = true;
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceToken = token.toString();
  }

  @override
  void initState() {
    super.initState();
    _extractEmail();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: canLoad
              ? Column(
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
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color:
                            darkTheme ? null : Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: TextFormField(
                            controller: _emailId,
                            autofillHints: [AutofillHints.email],
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              RegExp validateEmail = RegExp(
                                  r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
                              if (!validateEmail.hasMatch(_emailId.text)) {
                                return "Invalid Email!!!";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "xyz@gmail.com",
                              labelText: "Enter Email",
                              counterText: "",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 140,
                      height: 45,
                      child: ElevatedButton(
                        child: Text(
                          "Send OTP",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white),
                        ),
                        onPressed: () => MoveToNext(
                            context,
                            OtpName(email: _emailId.text, version: version),
                            _formKey),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        final user = await GoogleSignIN.login();

                        buildShowDialog(context);
                        String token = crypto.encrypt((user?.email).toString() +
                            "#" +
                            _deviceData['id'] +
                            "#" +
                            DateTime.now().toString());
                        await getDeviceTokenToSendNotification();

                        final ipAdd = await http.get(
                          Uri.parse('http://ip-api.com/json'),
                        );

                        final JD = jsonDecode(ipAdd.body);
                        prefs.setBool("isGoogle", true);
                        prefs.setString("email", (user?.email).toString());
                        prefs.setString("name", (user?.displayName).toString());
                        prefs.setString("token", token);
                        prefs.setString("pushToken", deviceToken);

                        await http.post(Uri.parse(global.url + 'login/google'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode({
                              'email': crypto.encrypt((user?.email).toString()),
                              'name': crypto
                                  .encrypt((user?.displayName).toString()),
                              'profilePic':
                                  crypto.encrypt((user?.photoUrl).toString()),
                              'country': crypto.encrypt(JD['country']),
                              'ip': crypto.encrypt(JD['query']),
                              'state': crypto.encrypt(JD['regionName']),
                              'city': crypto.encrypt(JD['city']),
                              'isp': crypto.encrypt(JD['isp']),
                              'device': crypto.encrypt(_deviceData['device']),
                              'deviceID': crypto.encrypt(_deviceData['id']),
                              'deviceToken': crypto.encrypt(deviceToken),
                              "token": crypto.encrypt(token)
                            }));

                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DashBoard(
                              version: version,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: SizedBox(
                        width: 240,
                        child: Card(
                          color: Theme.of(context).primaryColor.withAlpha(255),
                          elevation: 2.5,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FaIcon(FontAwesomeIcons.google,
                                      color: Colors.white),
                                  SizedBox(
                                    width: 9,
                                  ),
                                  Text(
                                    "Sign In With Google",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.white),
                                  )
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
      bottomNavigationBar: canLoad
          ? BottomAppBar(
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
            )
          : null,
    );
  }
}
