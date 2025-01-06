import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/manualUpdateWidget.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/others/GoogleSignIN.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/internetConnectivity.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:settlenow/others/themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailId = TextEditingController();
  bool canLoad = false;
  String deviceToken = "";
  GlobalKey<FormState> _formKeyLoginPage = GlobalKey<FormState>();
  bool darkTheme = false;
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String version = "";
  bool isOnBoardingCompleted = false;
  bool isItAndroidDevice = false;
  String ipAddress = "";
  bool importantUpdate = false;
  dynamic updateData = null;
  AppUpdateInfo? _updateInfo;
  // ignore: unused_field
  bool _flexibleUpdateAvailable = false;
  // final connectionChecker = InternetConnectionChecker();
  // late StreamSubscription<InternetConnectionStatus> subscription;

  @override
  void dispose() {
    // subscription.cancel();
    super.dispose();
  }

  Future<void> manualUpdateCheck() async {
    try {
      Map<String, dynamic> jsonInputData = {};

      final response =
          await createHTTPreq('login', http.patch, "", jsonInputData, context);

      if (response.statusCode == 200) {
        updateData = jsonDecode(response.body);
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        int currentVerionCode = int.parse(await packageInfo.buildNumber);
        int updatedVersionCode =
            int.parse(crypto.decrypt(updateData['Version']).split('+').last);
        if (updatedVersionCode > currentVerionCode) {
          importantUpdate = true;
        }
      }
    } on Exception catch (err, stackTrace) {
      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["LoginPage->manualUpdateCheck"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> deleteTempData() async {
    removePref(["token", "__token", "___token"]);
    if (!kIsWeb) {
      String path = await getDBFilePath('contact_data.db');
      await deleteDatabase(path);
      Database database = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await Future.wait([
          db.execute(
              'CREATE TABLE ContactHasNoAccountOnSN (phoneNo TEXT PRIMARY KEY)'),
          db.execute(
              'CREATE TABLE ContactHasAccountOnSN (phoneNo TEXT PRIMARY KEY, name TEXT, email TEXT)')
        ]);
      });

      Future.wait([
        AwesomeNotifications().cancelAllSchedules(),
        database.close(),
      ]);
    }
  }

  Future<void> checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {});

    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      await InAppUpdate.startFlexibleUpdate().then((_) {
        setState(() {
          _flexibleUpdateAvailable = true;
        });
      }).catchError((e) {});

      await InAppUpdate.completeFlexibleUpdate();
    }
  }

  Future<void> _extractEmail() async {
    var futureOut = await Future.wait([
      getAppVersion(),
      initPlatformState(),
      checkAndroidInsideWeb(),
      getTheme(context),
      getBoardingStatus(),
      getStringPref('token'),
    ]);

    version = futureOut[0] as String;
    _deviceData = futureOut[1] as Map<String, dynamic>;
    isItAndroidDevice = futureOut[2] as bool;
    darkTheme = futureOut[3] as bool;
    isOnBoardingCompleted = futureOut[4] as bool;
    var tempData = futureOut[5] as String?;
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.toggleTheme(darkTheme);
    final internetProvider =
        Provider.of<InternetconnectivityProvider>(context, listen: false);
    internetProvider.toggleDeviceConnected(true);

    if (tempData == null) {
      while (this.mounted && context.canPop()) {
        context.pop();
      }
      while (this.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (kIsWeb) {
        await Future.wait([deleteTempData()]);
      } else {
        await Future.wait(
            [deleteTempData(), manualUpdateCheck(), checkForUpdate()]);
      }
      if (this.mounted) {
        setState(() {
          canLoad = true;
        });
      }

      return;
    } else {
      var checkJWTToken =
          await JWT.tryDecode(crypto.decrypt(tempData.toString()));

      if (checkJWTToken == null) {
        if (kIsWeb) {
          await Future.wait([deleteTempData()]);
        } else {
          await Future.wait(
              [deleteTempData(), manualUpdateCheck(), checkForUpdate()]);
        }
        if (this.mounted) {
          setState(() {
            canLoad = true;
          });
        }
        return;
      } else {
        if (this.mounted) {
          while (context.canPop()) {
            context.pop();
          }
          isOnBoardingCompleted
              ? context.go(AppRouteConstants.dashboardRouteName,
                  extra: {"firstTime": false})
              : context.go(
                  AppRouteConstants.onBoardingRouteName,
                );
        }
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> fetchIP() async {
    try {
      final ipAddressReq = await http.get(Uri.parse('https://api64.ipify.org'));

      if (ipAddressReq.statusCode == 200) {
        if (this.mounted) {
          setState(() {
            ipAddress = ipAddressReq.body;
          });
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LoginPage->fetchIP"]);
      }
    }
  }

  Future<void> getDeviceTokenToSendNotification() async {
    if (kIsWeb) {
      return;
    }
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceToken = token.toString();
  }

  @override
  void initState() {
    super.initState();
    // if (!kIsWeb) {
    //   subscription = InternetConnectionChecker.createInstance(
    //     checkInterval: Duration(seconds: 30),
    //     customCheckOptions: [
    //       AddressCheckOption(uri: Uri.parse('https://1.1.1.1')),
    //     ],
    //     useDefaultOptions: false,
    //   ).onStatusChange.listen(
    //     (InternetConnectionStatus status) {
    //       final provider =
    //           Provider.of<InternetconnectivityProvider>(context, listen: false);
    //       bool isDeviceConnected =
    //           (status == InternetConnectionStatus.connected);
    //       if (isDeviceConnected != provider.isDeviceConnected) {
    //         provider.toggleDeviceConnected(isDeviceConnected);
    //       }
    //       if (!isDeviceConnected && provider.isAlertSet == false) {
    //         provider.toggleAlertSet(true);
    //       } else if (isDeviceConnected && provider.isAlertSet == true) {
    //         Future.delayed(Duration(seconds: 1), () {
    //           provider.toggleAlertSet(false);
    //         });
    //       }
    //     },
    //   );
    // }
    fetchIP();
    _extractEmail();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final internetConnProvider =
        Provider.of<InternetconnectivityProvider>(context, listen: false);

    return importantUpdate
        ? updateWidget(context, updateData)
        : Scaffold(
            body: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    (isItAndroidDevice ? 150 : 50),
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
                              color: darkTheme
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Form(
                              key: _formKeyLoginPage,
                              child: AutofillGroup(
                                child: TextFormField(
                                  controller: _emailId,
                                  autofillHints: [AutofillHints.email],
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    RegExp validateEmail = RegExp(
                                        r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
                                    if (!validateEmail
                                        .hasMatch(_emailId.text)) {
                                      return "Invalid Email!";
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
                            height: 20,
                          ),
                          SizedBox(
                              width: 140,
                              height: 47,
                              child: OutlinedButton(
                                child: Text(
                                  "Send OTP",
                                  style: TextStyle(
                                      color: themeProvider.isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 17),
                                ),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                onPressed: () async {
                                  if (this.mounted &&
                                      _formKeyLoginPage.currentState!
                                          .validate()) {
                                    context.push(
                                        AppRouteConstants.loginRouteName +
                                            AppRouteConstants.verifyRouteName,
                                        extra: {
                                          "version": version,
                                          "email": _emailId.text,
                                          "ipAddress": ipAddress,
                                        });
                                  }
                                },
                              )),
                          SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            width: 260,
                            height: 50,
                            child: OutlinedButton(
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
                                          fontSize: 17, color: Colors.white),
                                    )
                                  ]),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                try {
                                  final user = await GoogleSignIN.login();
                                  if (user != null) {
                                    if (this.mounted) {
                                      buildShowDialog(context);
                                    }
                                    String token = crypto.encrypt(
                                        (user.email).toString() +
                                            "#" +
                                            _deviceData['id'] +
                                            "#" +
                                            DateTime.now().toString());
                                    Map<String, String> jsonInputData = {
                                      "email": (user.email).toString(),
                                      "name": (user.displayName).toString(),
                                      "token": token
                                    };
                                    String jwToken = await createJWT(
                                        (user.email).toString(),
                                        jsonEncode(jsonInputData));

                                    await Future.wait([
                                      setStringPref('token', jwToken),
                                      setBoolPrefs('isGoogle', true),
                                    ]);

                                    var resp = null;
                                    await getDeviceTokenToSendNotification();

                                    jsonInputData = {
                                      'email': crypto
                                          .encrypt((user.email).toString()),
                                      'name': crypto.encrypt(
                                          (user.displayName).toString()),
                                      'profilePic': crypto
                                          .encrypt((user.photoUrl).toString()),
                                      'ip': crypto.encrypt(ipAddress),
                                      'device':
                                          crypto.encrypt(_deviceData['device']),
                                      'deviceToken': crypto.encrypt(
                                          kIsWeb ? "web" : deviceToken),
                                      "token": crypto.encrypt(token),
                                      'userAgent': crypto
                                          .encrypt(_deviceData['userAgent']),
                                    };

                                    resp = await createHTTPreq('login/google',
                                        http.post, "", jsonInputData, context);

                                    var remainingData =
                                        jsonDecode(resp.body)['data'];

                                    if (resp.statusCode == 200) {
                                      await Future.wait([
                                        setStringPref('___token',
                                            remainingData['createdOn']),
                                        setStringPref(
                                            '__token', remainingData['phoneNo'])
                                      ]);
                                    } else {
                                      await Future.wait([
                                        setStringPref(
                                            '___token', crypto.encrypt("")),
                                        setStringPref(
                                            '__token', crypto.encrypt(""))
                                      ]);
                                    }

                                    if (this.mounted) {
                                      while (context.canPop()) {
                                        context.pop();
                                      }
                                    }

                                    if (this.mounted) {
                                      isOnBoardingCompleted
                                          ? context.go(
                                              AppRouteConstants
                                                  .dashboardRouteName,
                                              extra: {
                                                  "version": version,
                                                  "firstTime": true
                                                })
                                          : context.go(
                                              AppRouteConstants
                                                  .onBoardingRouteName,
                                              extra: {"version": version});
                                    }
                                  }
                                } on Exception catch (err, stackTrace) {
                                  if (this.mounted) {
                                    onException(context, err, stackTrace,
                                        reason: "Unknwon Error",
                                        info: ["LoginPage->SignInWithGoogle"]);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
              ),
            ),
            bottomNavigationBar: internetConnProvider.isAlertSet
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      color: internetConnProvider.isDeviceConnected
                          ? Colors.green
                          : Colors.red,
                    ),
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Center(
                          child: Text(
                        internetConnProvider.isDeviceConnected
                            ? "You are connected to Internet"
                            : "You aren't connected to Internet",
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      )),
                    ),
                  )
                : (canLoad
                    ? BottomAppBar(
                        elevation: 0,
                        height: isItAndroidDevice ? 150 : 50,
                        color: Colors.transparent,
                        child: ListView(shrinkWrap: true, children: [
                          SizedBox(
                            height: 8,
                          ),
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
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.blueAccent),
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
                            height: kIsWeb ? 10 : 25,
                          ),
                          isItAndroidDevice
                              ? InkWell(
                                  onTap: () async {
                                    launchUrl(
                                      Uri.parse(
                                          "https://play.google.com/store/apps/details?id=com.rohit.settlenow"),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  child: Image(
                                    width: 250,
                                    height: 80,
                                    image: AssetImage(
                                        'assets/Images/play_store.png'),
                                  ))
                              : SizedBox()
                        ]),
                      )
                    : null),
          );
  }
}
