import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../contents.dart' as global;
import 'package:device_info_plus/device_info_plus.dart';

import '../others/themes.dart';

class OtpName extends StatefulWidget {
  final String email;

  const OtpName({ Key? key, required this.email}) : super(key: key);

  @override
  _OtpNameState createState() => _OtpNameState();
}

class _OtpNameState extends State<OtpName> {
  bool error = false;
  String errorText = "Invalid OTP!!!";
  bool errorN = false;
  final String errorTextN = "Invalid Name!!!";
  late var data = null;
  bool verified = false;
  var JsonData = null;
  var JD = null;
  String token = "";
  String deviceToken = "";
  final TextEditingController _name = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  late SharedPreferences prefs;
  late AndroidDeviceInfo androidInfo;

  Future _initialisation() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    androidInfo = await deviceInfo.androidInfo;
    prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse(global.url + 'login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': crypto.encrypt(widget.email),
      })
    );
    
    getDeviceTokenToSendNotification();
    token = crypto.encrypt(widget.email+"#"+androidInfo.androidId!+"#"+DateTime.now().toString());

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
    } else if (jsonDecode(response.body)['maintenance'] != null && jsonDecode(response.body)['maintenance']) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Maintainence()),
          (Route<dynamic> route) => false,
      );
    } else {
      _showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
    }
  }

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceToken = token.toString();
  }

  verifyStatus(String name, String otp, BuildContext context) async {
    buildShowDialog(context);

    try {
      final response = await http.post(
        Uri.parse(global.url + 'verify'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.email),
          'otp': crypto.encrypt(otp),
          'name': crypto.encrypt(name),
          'token': crypto.encrypt(token)
        })
      );

      JsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (crypto.decrypt(data['Name'])=='Unknown') {
          prefs.setString("name", name);
        } else {
          prefs.setString("name", crypto.decrypt(data['Name']));
        }
        
        prefs.setString("email", widget.email);
        prefs.setString("token", token);
        prefs.setString("pushToken", deviceToken);
        prefs.setBool("isGoogle", false);

        await http.patch(
          Uri.parse(global.url + 'verify'),
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
            'device': crypto.encrypt(androidInfo.device!),
            'deviceID': crypto.encrypt(androidInfo.androidId!),
            'deviceToken': crypto.encrypt(deviceToken)
          })
        );
        
        Navigator.pop(context);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashBoard()),
          (Route<dynamic> route) => false,
        );
      } else {
        error = true;
        if (this.mounted) {
          setState(() {
            errorText = crypto.decrypt(JsonData['Message']);
          });
        }
        Navigator.pop(context);
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      _showToast(context, "No Internet Connection");
    }
  }

  _showToast(BuildContext context, String show) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(show),
        action: SnackBarAction(label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
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
      }
    );
  }


  @override
  void initState() {
    super.initState();
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
            width: MediaQuery.of(context).size.width*0.8,
            child: (data==null?const Center(
              child: CircularProgressIndicator(),
              ):Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  height>=800?SizedBox(height: MediaQuery.of(context).size.height/4,):SizedBox(height: 60,),
                  Image.asset(
                    'assets/Images/SN.jpg',
                    height: 150,
                    width: 150,
                  ),
                  Text("Settle Now", style: TextStyle(
                      fontSize: height>=800?60:40,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.darkTheme?null:Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 50,),
                  (crypto.decrypt(data['Name'])=='Unknown')?
                    AutofillGroup(
                      child: TextFormField(
                        controller: _name,
                        keyboardType: TextInputType.text,
                        maxLength: 70,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 18),
                        autofillHints: [AutofillHints.email],
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(8.0),
                          hintText: "Aditya",
                          labelText: "Enter Name",
                          errorText: (errorN==true?errorTextN:null),
                          errorStyle: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ):const SizedBox(width: 0, height: 0,),
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
                        errorText: (error==true?errorText:null),
                        errorStyle: const TextStyle(fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 150,
                      height: 45,
                      child: ElevatedButton(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white
                          ),
                        ),
                        onPressed: () {
                          RegExp validateName = RegExp(r'[A-Za-z]{3,}');
                          RegExp validateOTP = RegExp(r'^[\d]{6}');
                          errorN = ((crypto.decrypt(data['Name'])!='Unknown')?false:!validateName.hasMatch(_name.text));
                          error = !validateOTP.hasMatch(_otp.text);
                          if (!(error || errorN)) {
                            if (crypto.decrypt(data['Name'])=='Unknown') {
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
              )
            ),
          )
        ),
      ),
    );
  }
}

