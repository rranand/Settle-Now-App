import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:moment_dart/moment_dart.dart';
import 'package:pinput/pinput.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/LoggedInEach.dart';
import 'package:settlenow/others/internetConnectivity.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/themes.dart';

import '../others/GoogleSignIN.dart';

class Profile extends StatefulWidget {
  const Profile({
    Key? key,
  }) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _email = "";
  String _token = "";
  String picUrl = "";
  String name = "";
  bool isGoogle = false;
  GoogleSignInAccount? _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  bool canResendOTP = false;
  final CountdownController _OTPCountdownController =
      new CountdownController(autoStart: true);
  TextEditingController _deleteConfirmationText = new TextEditingController();
  GlobalKey<FormState> _deleteConfirmationFormLoginPage =
      GlobalKey<FormState>();
  TextEditingController _phoneNo = new TextEditingController();
  TextEditingController _otp = new TextEditingController();
  GlobalKey<FormState> _formKeyLoginPage = GlobalKey<FormState>();
  String verificationOTP = "";
  String OTPverificationError = "";
  bool isVerificationSuccessful = false;
  bool havePhoneNo = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  String createdOn = "";
  bool isDataLoading = false;
  List<LoggedInEach> loggedInData = [];

  Future<void> logOutFromGoogle() async {
    if (isGoogle) {
      await GoogleSignIN.logout();
    }
  }

  deleteAccount() async {
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
      };

      final response = await createHTTPreq(
          'profile/deleteAccount', http.post, _token, jsonInputData, context);

      String responseMessage =
          crypto.decrypt(jsonDecode(response.body)['Message']);
      if (response.statusCode == 200) {
        await Future.wait([
          removePref(["token", "__token", "___token"]),
          logOutFromGoogle()
        ]);

        if (this.mounted) {
          while (context.canPop()) {
            context.pop();
          }
          context.push(AppRouteConstants.loginRouteName);
          showToast(context, responseMessage, Icons.done);
        }
      } else {
        for (int i = 0; i < 2 && context.canPop(); i++) {
          if (this.mounted) {
            context.pop();
          }
        }
        showToast(context, responseMessage, Icons.warning_rounded);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Profile->deleteAccount"]);
      }
    }
  }

  logoutSpecific(String loggedInID, int index) async {
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'loggedInID': crypto.encrypt(loggedInID),
      };

      final response = await createHTTPreq(
          'verify/logoutSpecific', http.delete, _token, jsonInputData, context);

      String responseMessage =
          crypto.decrypt(jsonDecode(response.body)['Message']);

      if (response.statusCode == 200) {
        loggedInData.removeAt(index);
        if (this.mounted) {
          setState(() {});
        }
        if (this.mounted) {
          context.pop();
        }
        showToast(context, responseMessage, Icons.done);
      } else {
        if (this.mounted) {
          context.pop();
        }
        showToast(context, responseMessage, Icons.warning_outlined);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Profile->logoutSpecific"]);
      }
    }
  }

  fetchBasicInfo() async {
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
      };

      final response = await createHTTPreq(
          'profile/basic_info', http.post, _token, jsonInputData, context);

      String responseMessage =
          crypto.decrypt(jsonDecode(response.body)['Message']);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        for (int i = 0; i < data['data'].length; i++) {
          loggedInData.add(LoggedInEach.fromJson(data['data'][i]));
        }
        loggedInData.sort((a, b) => a.id.length.compareTo(b.id.length));
        if (this.mounted) {
          setState(() {
            picUrl = crypto.decrypt(data['picUrl']);
            name = crypto.decrypt(data['name']);
            isGoogle = crypto.decrypt(data['isGoogle']) == "true";
          });
        }
        if (isGoogle) {
          _googleSignIn.isSignedIn().then((value) {
            if (value) {
              _googleSignIn.signInSilently().then((value) {
                if (value != null && this.mounted) {
                  setState(() {
                    _currentUser = value;
                    picUrl = _currentUser!.photoUrl.toString();
                  });
                }
              });
            }
          });
        } else {
          if (this.mounted) {
            setState(() {
              picUrl = addCorsinImage(dotenv.get('driveUrl') +
                  (picUrl.length == 0
                      ? dotenv.get('unknown_avatar_id')
                      : picUrl));
            });
          }
        }
      } else {
        showToast(context, responseMessage, Icons.warning_rounded);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Profile->fetchBasicInfo"]);
      }
    }
  }

  initialization() async {
    if (this.mounted) {
      setState(() {
        isDataLoading = true;
      });
    }

    var tokenData = await getStringPref('token');

    if (tokenData != null) {
      Map<String, dynamic> jsonOutData = parseJWT(tokenData.toString());
      if (this.mounted) {
        setState(() {
          _email = jsonOutData["email"]!;
          _token = jsonOutData["token"]!;
        });
      }
    } else {
      while (this.mounted && context.canPop()) {
        context.pop();
      }
      if (this.mounted) {
        context.go(AppRouteConstants.loginRouteName);
      }
      return;
    }

    await fetchBasicInfo();

    _phoneNo.text =
        crypto.decrypt(await getStringPref("__token") ?? crypto.encrypt(""));
    createdOn =
        crypto.decrypt(await getStringPref("___token") ?? crypto.encrypt(""));

    if (_phoneNo.text.isNotEmpty) {
      havePhoneNo = true;
    }

    if (this.mounted) {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  void dispose() {
    super.dispose();
  }

  pushPhoneToDB(String phoneNo) async {
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'phoneNo': crypto.encrypt(phoneNo)
      };

      final response = await createHTTPreq(
          'profile/phoneNo', http.post, _token, jsonInputData, context);

      if (response.statusCode == 200) {
        havePhoneNo = true;
        setStringPref("__token", crypto.encrypt(_phoneNo.text));
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Profile->pushPhoneToDB"]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  void verifyOTPDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStates) {
            final defaultPinTheme = PinTheme(
              width: 45,
              height: 45,
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              decoration: BoxDecoration(
                border: Border.all(
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : Colors.black),
                borderRadius: BorderRadius.circular(13),
              ),
            );

            final focusedPinTheme = defaultPinTheme.copyDecorationWith(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(13),
            );
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                width: kIsWeb
                    ? max(MediaQuery.of(context).size.width * 0.5,
                        min(400, MediaQuery.of(context).size.width * 0.9))
                    : MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Verify Phone Number",
                            style: TextStyle(
                              fontSize: 19,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                if (this.mounted) {
                                  context.pop();
                                }
                              },
                              icon: Icon(
                                Icons.close,
                                size: 19,
                              ))
                        ],
                      ),
                      SizedBox(
                        height: 25,
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
                          forceErrorState: OTPverificationError.isNotEmpty,
                          errorText: OTPverificationError,
                        ),
                      ),
                      SizedBox(
                        height: 26,
                      ),
                      Center(child: Text("Didn't Received Code?")),
                      SizedBox(
                        height: 4,
                      ),
                      canResendOTP
                          ? Center(
                              child: InkWell(
                                  onTap: () async {
                                    await sendOTP(_phoneNo.text, themeProvider,
                                        isVerificationPageOpened: true);
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
                                  )),
                            )
                          : Center(
                              child: Countdown(
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
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: SizedBox(
                          width: 130,
                          height: 45,
                          child: OutlinedButton(
                            child: Text(
                              "Verify",
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
                            onPressed: () async {
                              if (this.mounted) {
                                buildShowDialog(context);
                              }
                              try {
                                PhoneAuthCredential credential =
                                    PhoneAuthProvider.credential(
                                        verificationId: verificationOTP,
                                        smsCode: _otp.text);

                                await auth.signInWithCredential(credential);
                                isVerificationSuccessful = true;
                                await pushPhoneToDB(_phoneNo.text);
                                if (this.mounted) {
                                  context.pop();
                                }
                                showToast(context,
                                    "OTP Verification Successful", Icons.done);
                              } catch (e) {
                                OTPverificationError = "Invalid OTP";
                              }
                              if (this.mounted) {
                                context.pop();
                                setState((() {}));
                                setStates((() {}));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  void deleteDialog(BuildContext context, ThemeProvider themeProvider) {
    if (this.mounted) {
      setState(() {
        _deleteConfirmationText.text = "";
      });
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setStates) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                width: kIsWeb
                    ? max(MediaQuery.of(context).size.width * 0.5,
                        min(400, MediaQuery.of(context).size.width * 0.9))
                    : MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Delete Account Form"),
                      SizedBox(
                        height: 10,
                      ),
                      Form(
                        key: _deleteConfirmationFormLoginPage,
                        child: TextFormField(
                          style: TextStyle(fontSize: 16),
                          controller: _deleteConfirmationText,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: "Type delete to Confirm",
                            counterText: "",
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value != "delete") {
                              return "Wrong Word";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 45,
                            child: OutlinedButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 19),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                context.pop();
                              },
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            height: 45,
                            child: OutlinedButton(
                              child: Text(
                                "Confirm",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 19),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(color: Colors.redAccent),
                              ),
                              onPressed: () async {
                                if (_deleteConfirmationFormLoginPage
                                    .currentState!
                                    .validate()) {
                                  await deleteAccount();
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  sendOTP(String phoneNo, ThemeProvider themeProvider,
      {bool isVerificationPageOpened = false}) async {
    if (this.mounted) {
      setState(() {
        _otp.text = "";
        OTPverificationError = "";
      });
    }
    buildShowDialog(context);

    await auth.verifyPhoneNumber(
      phoneNumber: "+91" + phoneNo,
      verificationCompleted: (PhoneAuthCredential credential) {
        _otp.setText(credential.smsCode!);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        verificationOTP = verificationId;
      },
      timeout: Duration(seconds: 0),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    if (this.mounted) {
      context.pop();
    }
    if (!isVerificationPageOpened) {
      verifyOTPDialog(context, themeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final internetConnProvider =
        Provider.of<InternetconnectivityProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: Center(
          child: isDataLoading
              ? SizedBox(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    CachedNetworkImage(
                      httpHeaders: {'Access-Control-Allow-Origin': '*'},
                      imageUrl: (isGoogle ? picUrl : addCorsinImage(picUrl)),
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/Images/unknown.jpeg'),
                              fit: BoxFit.cover),
                        ),
                      ),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            style: TextStyle(fontSize: 16),
                            readOnly: true,
                            controller: TextEditingController(text: name),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Name",
                                counterText: ""),
                          ),
                          TextField(
                            style: TextStyle(fontSize: 16),
                            readOnly: true,
                            controller: TextEditingController(text: _email),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Email",
                              counterText: "",
                            ),
                          ),
                          Form(
                            key: _formKeyLoginPage,
                            child: AutofillGroup(
                              child: TextFormField(
                                readOnly:
                                    (havePhoneNo || isVerificationSuccessful),
                                style: TextStyle(fontSize: 16),
                                controller: _phoneNo,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText:
                                      (havePhoneNo || isVerificationSuccessful)
                                          ? "Phone No"
                                          : "Enter Phone No",
                                  counterText: "",
                                ),
                                maxLength: 10,
                                autofillHints: [AutofillHints.telephoneNumber],
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  RegExp validateEmail = RegExp(r'^[\d]{10}');
                                  if (!validateEmail.hasMatch(_phoneNo.text)) {
                                    return "Invalid Phone No";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          !(havePhoneNo || isVerificationSuccessful)
                              ? SizedBox(
                                  width: 120,
                                  height: 45,
                                  child: OutlinedButton(
                                    child: Text(
                                      "Verify",
                                      style: TextStyle(
                                          color: themeProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onPressed: () async {
                                      if (_formKeyLoginPage.currentState!
                                          .validate()) {
                                        await sendOTP(
                                            _phoneNo.text, themeProvider);
                                      }
                                    },
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 7,
                          ),
                          createdOn.length >= 12
                              ? Text(
                                  "Member Since " + createdOn.substring(0, 11),
                                  style: TextStyle(fontSize: 16),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: loggedInData.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  height: 100,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Card(
                                      color: Theme.of(context)
                                          .dialogBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: loggedInData[index]
                                                        .id
                                                        .length ==
                                                    0
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).cardColor),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  loggedInData[index].device ==
                                                          "Android"
                                                      ? Icons
                                                          .phone_android_outlined
                                                      : Icons
                                                          .desktop_mac_outlined,
                                                  size: 35,
                                                ),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Text(
                                                  loggedInData[index].device +
                                                      "\n" +
                                                      "Last Used : " +
                                                      DateFormat(dotenv.get(
                                                              "dateTimeFormat_new"))
                                                          .parse(loggedInData[
                                                                  index]
                                                              .lastUsed)
                                                          .toMoment()
                                                          .fromNow(),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            loggedInData[index].id.length > 0
                                                ? ElevatedButton(
                                                    child: Text(
                                                      "Logout",
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.white),
                                                    ),
                                                    onPressed: () async {
                                                      await logoutSpecific(
                                                          loggedInData[index]
                                                              .id,
                                                          index);
                                                    })
                                                : SizedBox()
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex: 1, child: SizedBox()),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 55,
                      child: OutlinedButton(
                        child: Text(
                          "Delete Account",
                          style: TextStyle(
                              color: themeProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 19),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side: BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: () async {
                          deleteDialog(context, themeProvider);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    )
                  ],
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
            : null);
  }
}
