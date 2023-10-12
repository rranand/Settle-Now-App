import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:settlenow/screens/onBoarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool canResendOTP = false;
  final CountdownController _OTPCountdownController =
      new CountdownController(autoStart: true);
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> resendOTP() async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
      };

      await createHTTPreq('login', http.post, "", jsonInputData);
    } on Exception catch (_) {
      setState(() {
        error = true;
        errorText = "Unable To Sent OTP";
      });
    }

    if (this.mounted) {
      Navigator.pop(context);
    }
  }

  Future _initialisation() async {
    Map<String, String> jsonInputData = {
      'email': crypto.encrypt(widget.email),
    };

    List<dynamic> fwaitTemp = await Future.wait([
      SharedPreferences.getInstance(),
      initPlatformState(),
      getDeviceTokenToSendNotification(),
      createHTTPreq('login', http.post, token, jsonInputData)
    ]);

    prefs = fwaitTemp[0];
    _deviceData = fwaitTemp[1];
    final response = fwaitTemp[3];

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

      if (!kIsWeb) {
        final ipAdd = await http.get(
          Uri.parse('http://ip-api.com/json'),
        );

        if (this.mounted) {
          setState(() {
            JD = jsonDecode(ipAdd.body);
          });
        }
      }
    } else if (response.statusCode == 503) {
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

    if (await prefs.getBool("isOnBoardingCompleted") != null) {
      isOnBoardingCompleted = await prefs.getBool("isOnBoardingCompleted")!;
    } else {
      await prefs.setBool("isOnBoardingCompleted", false);
    }
  }

  Future<void> getDeviceTokenToSendNotification() async {
    if (!kIsWeb) {
      final FirebaseMessaging _fcm = FirebaseMessaging.instance;
      final token = await _fcm.getToken();
      deviceToken = token.toString();
    }
  }

  verifyStatus(String name, String otp, BuildContext context) async {
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'otp': crypto.encrypt(otp),
        'name': crypto.encrypt(name),
        'token': crypto.encrypt(token),
        'deviceToken': crypto.encrypt(kIsWeb ? "web" : "android")
      };

      final response =
          await createHTTPreq('verify', http.post, "", jsonInputData);

      JsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Map<String, String> jsonInputData = {
          "email": widget.email,
          "name": "",
          "token": token
        };

        if (crypto.decrypt(data['Name']) == 'Unknown') {
          jsonInputData.update("name", (value) => name);
        } else {
          jsonInputData.update("name", (value) => crypto.decrypt(data['Name']));
        }

        String jwToken =
            await createJWT(widget.email, jsonEncode(jsonInputData));

        await Future.wait([
          prefs.setString("token", jwToken),
          prefs.setBool("isGoogle", false)
        ]);

        var resp = null;
        Map<String, String> jsonInputDataReq = {};
        if (kIsWeb) {
          jsonInputDataReq = {
            'email': crypto.encrypt(widget.email),
            'country': crypto.encrypt("Unknown"),
            'ip': crypto.encrypt("Unknown"),
            'state': crypto.encrypt("Unknown"),
            'city': crypto.encrypt("Unknown"),
            'isp': crypto.encrypt("Unknown"),
            'device': crypto.encrypt(_deviceData['device']),
            'deviceID': crypto.encrypt(_deviceData['id']),
            'deviceToken': crypto.encrypt("web")
          };
        } else {
          jsonInputDataReq = {
            'email': crypto.encrypt(widget.email),
            'country': crypto.encrypt(JD['country']),
            'ip': crypto.encrypt(JD['query']),
            'state': crypto.encrypt(JD['regionName']),
            'city': crypto.encrypt(JD['city']),
            'isp': crypto.encrypt(JD['isp']),
            'device': crypto.encrypt(_deviceData['device']),
            'deviceID': crypto.encrypt(_deviceData['id']),
            'deviceToken': crypto.encrypt(deviceToken),
            'model': crypto.encrypt(_deviceData['model']),
            'product': crypto.encrypt(_deviceData['product']),
            'serial': crypto.encrypt(_deviceData['serial']),
            'android': crypto.encrypt(_deviceData['sdkInt']),
            'release': crypto.encrypt(_deviceData['release']),
          };
        }
        resp = await createHTTPreq('verify', http.patch, "", jsonInputDataReq);

        var remainingData = jsonDecode(resp.body)['data'];

        if (resp.statusCode == 200) {
          await Future.wait([
            prefs.setString("___token", remainingData['createdOn']),
            prefs.setString("__token", remainingData['phoneNo'])
          ]);
        } else {
          await Future.wait([
            prefs.setString("___token", crypto.encrypt("")),
            prefs.setString("__token", crypto.encrypt(""))
          ]);
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
        if (this.mounted) {
          setState(() {
            error = true;
            errorText = crypto.decrypt(JsonData['Message']);
          });
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

    final defaultPinTheme = PinTheme(
      width: 45,
      height: 45,
      textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      decoration: BoxDecoration(
        border: Border.all(
            color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
        borderRadius: BorderRadius.circular(13),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Theme.of(context).primaryColor),
      borderRadius: BorderRadius.circular(13),
    );

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
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Pinput(
                            length: 6,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: focusedPinTheme,
                            errorPinTheme: defaultPinTheme.copyDecorationWith(
                              border: Border.all(color: Colors.redAccent),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            showCursor: true,
                            controller: _otp,
                            forceErrorState: error,
                            errorText: errorText,
                            onClipboardFound: kIsWeb
                                ? null
                                : (value) {
                                    RegExp validateOTP = RegExp(r'^[\d]{6}');
                                    if (validateOTP.hasMatch(value)) {
                                      if (this.mounted) {
                                        setState(() {
                                          error = false;
                                          _otp.text = value;
                                        });
                                      }
                                    }
                                  },
                          ),
                        ),
                        SizedBox(
                          height: 26,
                        ),
                        Text("Didn't Received Code?"),
                        SizedBox(
                          height: 4,
                        ),
                        canResendOTP
                            ? InkWell(
                                onTap: () async {
                                  await resendOTP();
                                  if (this.mounted) {
                                    setState(() {
                                      canResendOTP = false;
                                    });
                                  }
                                  _OTPCountdownController.restart();
                                },
                                child: Text(
                                  "Resend",
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ))
                            : Countdown(
                                seconds: 60,
                                build: (BuildContext context, double time) =>
                                    Text("Wait " +
                                        time.round().toString() +
                                        " Seconds"),
                                interval: Duration(seconds: 1),
                                onFinished: () {
                                  if (this.mounted) {
                                    setState(() {
                                      canResendOTP = true;
                                    });
                                  }
                                },
                              ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 55,
                          width: 150,
                          child: OutlinedButton(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                error = false;
                                errorN = false;
                                RegExp validateName = RegExp(r'[A-Za-z]{3,}');
                                RegExp validateOTP = RegExp(r'^[\d]{6}');
                                errorN =
                                    ((crypto.decrypt(data['Name']) != 'Unknown')
                                        ? false
                                        : !validateName.hasMatch(_name.text));
                                error = !validateOTP.hasMatch(_otp.text);
                                if (!(error || errorN)) {
                                  if (crypto.decrypt(data['Name']) ==
                                      'Unknown') {
                                    verifyStatus(
                                        _name.text, _otp.text, context);
                                  } else {
                                    verifyStatus("##", _otp.text, context);
                                  }
                                }
                                if (this.mounted) {
                                  setState(() {});
                                }
                              }),
                        )
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
