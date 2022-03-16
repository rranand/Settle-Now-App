import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settlenow/screens/dashboard.dart';
import 'package:settlenow/screens/otpName.dart';

import '../others/themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailId = TextEditingController();
  late SharedPreferences prefs;
  bool canLoad = false;
  final _formKey = GlobalKey<FormState>();
  bool darkTheme = false;

  Future _extractEmail() async {
    prefs = await SharedPreferences.getInstance();

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

  @override
  void initState() {
    super.initState();
    _extractEmail();
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
              SizedBox(height: MediaQuery.of(context).size.height/4,),
              Image.asset(
                'assets/Images/settle.jpg',
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
            ],
          ):Center(
            child: CircularProgressIndicator(),
          ),
        ),
        ),
    );
  }
}