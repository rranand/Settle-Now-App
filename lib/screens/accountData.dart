import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/themes.dart';

class AccountData extends StatefulWidget {
  final String picUrl;
  final String email;
  final String name;
  final String token;

  const AccountData(
      {Key? key,
      required this.picUrl,
      required this.email,
      required this.name,
      required this.token})
      : super(key: key);

  @override
  State<AccountData> createState() => _AccountDataState();
}

class _AccountDataState extends State<AccountData> {
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  final _verifyOTPFormKey = GlobalKey<FormState>();
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
          Uri.parse(global.url + '/profile/deleteAccount'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
          }));

      if (response.statusCode == 200) {
        prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        if (this.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );

          showToast(context, "Account Deleted Successfully", Icons.done);
        }
      }
    } on Exception catch (_) {
      if (this.mounted) {
        Navigator.pop(context);
        await onException(context);
      }
    }
  }

  fetchRemainingData() async {
    if (this.mounted) {
      setState(() {
        isDataLoading = true;
      });
    }
    try {
      final response = await http.post(
          Uri.parse(global.url + '/profile/getRemainingData'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
          }));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['data'];
        _phoneNo.text = crypto.decrypt(data['phoneNo']);
        createdOn = crypto.decrypt(data['createdOn']);

        if (_phoneNo.text.isNotEmpty) {
          havePhoneNo = true;
        }
      }
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
      }
    }

    if (this.mounted) {
      setState(() {
        isDataLoading = false;
      });
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
    fetchRemainingData();
  }

  pushPhoneToDB(String phoneNo) async {
    try {
      final response = await http.post(
          Uri.parse(global.url + '/profile/phoneNo'),
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
    Navigator.pop(context);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Verify Phone Number",
                            style: TextStyle(
                              fontSize: 16,
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
                                size: 16,
                              ))
                        ],
                      ),
                      Form(
                        key: _verifyOTPFormKey,
                        child: AutofillGroup(
                          child: TextFormField(
                            style: TextStyle(fontSize: 16),
                            controller: _otp,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: "Enter OTP",
                              counterText: "",
                            ),
                            maxLength: 6,
                            autofillHints: [AutofillHints.telephoneNumber],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              RegExp validateEmail = RegExp(r'^[\d]{6}$');
                              if (!validateEmail.hasMatch(_otp.text)) {
                                return "Invalid OTP";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      OTPverificationError.isNotEmpty
                          ? Text(
                              OTPverificationError,
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            )
                          : SizedBox(),
                      OTPverificationError.isNotEmpty
                          ? SizedBox(
                              height: 8,
                            )
                          : SizedBox(),
                      Center(
                        child: SizedBox(
                          width: 110,
                          height: 40,
                          child: OutlinedButton(
                            child: Text(
                              "Verify",
                              style: TextStyle(
                                  color: themeProvider.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () async {
                              if (_verifyOTPFormKey.currentState!.validate()) {
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
                                  showToast(
                                      context,
                                      "OTP Verification Successful",
                                      Icons.done);
                                } catch (e) {
                                  OTPverificationError = "Invalid OTP";
                                }
                                if (this.mounted) {
                                  Navigator.pop(context);
                                  setState((() {}));
                                  setStates((() {}));
                                }
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

  sendOTP(String phoneNo, ThemeProvider themeProvider) async {
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
        verifyOTPDialog(context, themeProvider);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
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
                      imageUrl: widget.picUrl,
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
