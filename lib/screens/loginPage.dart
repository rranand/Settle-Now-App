import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/others/GoogleSignIN.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/otpName.dart';
import 'package:http/http.dart' as http;
import '../contents.dart' as global;

import '../others/themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key}) : super(key: key);

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
  late AndroidDeviceInfo androidInfo;

  Future _extractEmail() async {
    prefs = await SharedPreferences.getInstance();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    androidInfo = await deviceInfo.androidInfo;

    if (prefs.getBool('darkTheme') != null) {
      darkTheme = prefs.getBool('darkTheme')!;
    } else {
      prefs.setBool('darkTheme', false);
    }

    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.toggleTheme(darkTheme);

    if (prefs.getString("email") != null && prefs.getString("name") != null && prefs.getString("token") != null && prefs.getString("pushToken") != null) {
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(
          builder: (context) => const DashBoard(),
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

  _MoveToNext(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpName(email: _emailId.text))
      );
    }
  }

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceToken = token.toString();
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

  @override
  void initState() {
    super.initState();
    _extractEmail();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: canLoad?Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height/5,),
              Image.asset(
                'assets/Images/SN.jpg',
                height: 150,
                width: 150,
              ),
              Text("Settle Now", style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: darkTheme?null:Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 60,),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.9,
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: TextFormField(
                      controller: _emailId,
                      autofillHints: [AutofillHints.email],
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        RegExp validateEmail = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
                        if (!validateEmail.hasMatch(_emailId.text)) {
                          return "Invalid Email!!!";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "xyz@gmail.com",
                        labelText: "Enter Email",
                      ),
                    ),
                  ),
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
                    "Send OTP",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white
                    ),
                  ),
                  onPressed: () => _MoveToNext(context),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                width: 220,
                height: 45,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white
                  ),
                  onPressed: () async {
                    final user = await GoogleSignIN.login();

                    buildShowDialog(context);
                    String token = crypto.encrypt((user?.email).toString()+"#"+androidInfo.androidId!+"#"+DateTime.now().toString());
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

                    await http.post(
                      Uri.parse(global.url + 'login/google'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode({
                        'email': crypto.encrypt((user?.email).toString()),
                        'name': crypto.encrypt((user?.displayName).toString()),
                        'profilePic': crypto.encrypt((user?.photoUrl).toString()),
                        'country': crypto.encrypt(JD['country']),
                        'ip': crypto.encrypt(JD['query']),
                        'state': crypto.encrypt(JD['regionName']),
                        'city': crypto.encrypt(JD['city']),
                        'isp': crypto.encrypt(JD['isp']),
                        'device': crypto.encrypt(androidInfo.device!),
                        'deviceID': crypto.encrypt(androidInfo.androidId!),
                        'deviceToken': crypto.encrypt(deviceToken),
                        "token": crypto.encrypt(token)
                      })
                    );

                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => const DashBoard(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }, 
                  icon: FaIcon(
                    FontAwesomeIcons.google,
                    color: Colors.red,
                  ), 
                  label: Text(
                    "Sign In With Google",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black
                    ),
                  )
                ),
              ),
            ],
          ):Center(
            child: CircularProgressIndicator(),
          ),
        ),
        ),
    );
  }
}