import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/themes.dart';

class Profile extends StatefulWidget {
  final String picUrl;
  final String email;
  final String name;
  final String token;

  const Profile(
      {Key? key,
      required this.picUrl,
      required this.email,
      required this.name,
      required this.token})
      : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool canResendOTP = false;
  final CountdownController _OTPCountdownController =
      new CountdownController(autoStart: true);
  bool isAlertSet = false;
  final _deleteConfirmationText = new TextEditingController();
  final _deleteConfirmationForm = GlobalKey<FormState>();
  final _phoneNo = new TextEditingController();
  final _otp = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String verificationOTP = "";
  String OTPverificationError = "";
  bool isVerificationSuccessful = false;
  bool havePhoneNo = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  String createdOn = "";
  bool isDataLoading = false;
  late SharedPreferences prefs;

  deleteAccount() async {
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      final response = await http.post(
          Uri.parse(global.url + 'profile/deleteAccount'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
          }));

      if (response.statusCode == 200) {
        String responseMessage =
            crypto.decrypt(jsonDecode(response.body)['Message']);

        if (responseMessage.toLowerCase().contains("soon")) {
          if (this.mounted) {
            Navigator.pop(context);
          }
          if (this.mounted) {
            Navigator.pop(context);
          }
          showToast(context, responseMessage, Icons.warning);
        } else {
          prefs = await SharedPreferences.getInstance();
          await Future.wait([
            prefs.remove("token"),
            prefs.remove("__token"),
            prefs.remove("___token")
          ]);

          if (this.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false,
            );

            showToast(context, responseMessage, Icons.done);
          }
        }
      }
    } on Exception catch (_) {
      if (this.mounted) {
        Navigator.pop(context);
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

  initialization() async {
    if (this.mounted) {
      setState(() {
        isDataLoading = true;
      });
    }

    prefs = await SharedPreferences.getInstance();
    _phoneNo.text = crypto.decrypt(await prefs.getString("__token")!);
    createdOn = crypto.decrypt(await prefs.getString("___token")!);
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
    getConnectivity();
    initialization();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  pushPhoneToDB(String phoneNo) async {
    try {
      final response = await http.post(
          Uri.parse(global.url + 'profile/phoneNo'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'phoneNo': crypto.encrypt(phoneNo)
          }));

      if (response.statusCode == 200) {
        havePhoneNo = true;
        prefs = await SharedPreferences.getInstance();
        await prefs.setString("__token", crypto.encrypt(_phoneNo.text));
      }
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
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
                width: MediaQuery.of(context).size.width * 0.9,
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
                                  Navigator.pop(context);
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
                          androidSmsAutofillMethod:
                              AndroidSmsAutofillMethod.smsUserConsentApi,
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
                                  Navigator.pop(context);
                                }
                                showToast(context,
                                    "OTP Verification Successful", Icons.done);
                              } catch (e) {
                                OTPverificationError = "Invalid OTP";
                              }
                              if (this.mounted) {
                                Navigator.pop(context);
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
                width: MediaQuery.of(context).size.width * 0.9,
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
                        key: _deleteConfirmationForm,
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
                                Navigator.pop(context);
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
                                if (_deleteConfirmationForm.currentState!
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
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        verificationOTP = verificationId;
      },
      timeout: Duration(seconds: 0),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    if (this.mounted) {
      Navigator.pop(context);
    }
    if (!isVerificationPageOpened) {
      verifyOTPDialog(context, themeProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: Center(
          child: isDataLoading
              ? SizedBox(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    CachedNetworkImage(
                      httpHeaders: {'Access-Control-Allow-Origin': '*'},
                      imageUrl: addCorsinImage(widget.picUrl),
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
                            controller:
                                TextEditingController(text: widget.name),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Name",
                                counterText: ""),
                          ),
                          TextField(
                            style: TextStyle(fontSize: 16),
                            readOnly: true,
                            controller:
                                TextEditingController(text: widget.email),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Email",
                              counterText: "",
                            ),
                          ),
                          Form(
                            key: _formKey,
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
                                  RegExp validateEmail = RegExp(r'^[\d]{10}$');
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
                                      if (_formKey.currentState!.validate()) {
                                        await sendOTP(
                                            _phoneNo.text, themeProvider);
                                      }
                                    },
                                  ),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 15,
                          ),
                          createdOn.length >= 12
                              ? Text(
                                  "Member Since " + createdOn.substring(0, 11),
                                  style: TextStyle(fontSize: 16),
                                )
                              : SizedBox()
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
            : null);
  }
}
