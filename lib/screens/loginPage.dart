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
  int red = 103;
  int green = 58;
  int blue = 183;
  int alpha = 255;

  Future _extractEmail() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('darkTheme') != null) {
      darkTheme = prefs.getBool('darkTheme')!;
    } else {
      prefs.setBool('darkTheme', false);
    }
    
    if (prefs.getInt('alpha') != null) {
      alpha = prefs.getInt('alpha')!;
    } else {
      prefs.setInt('alpha', 255);
    }

    if (prefs.getInt('red') != null) {
      red = prefs.getInt('red')!;
    } else {
      prefs.setInt('red', 103);
    }

    if (prefs.getInt('green') != null) {
      green = prefs.getInt('green')!;
    } else {
      prefs.setInt('green', 58);
    }

    if (prefs.getInt('blue') != null) {
      blue = prefs.getInt('blue')!;
    } else {
      prefs.setInt('blue', 183);
    }

    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.toggleTheme(darkTheme);

    final cprovider = Provider.of<ColorProvider>(context, listen: false);
    cprovider.changeColor(Color.fromARGB(alpha, red, green, blue));

    if (prefs.getString("email") != null && prefs.getString("name") != null && prefs.getString("token") != null) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                        hintText: "Enter Email",
                        labelText: "Email",
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