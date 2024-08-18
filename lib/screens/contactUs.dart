import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/internetConnectivity.dart';
import 'package:settlenow/routes/route_constant.dart';
import '../others/themes.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({
    Key? key,
  }) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  String _email = "";
  String _token = "";
  TextEditingController _subject = TextEditingController();
  TextEditingController _message = TextEditingController();
  GlobalKey<FormState> _formKeyContactUs = GlobalKey<FormState>();
  ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  sendContactData(BuildContext context) async {
    final internetConnProvider =
        Provider.of<InternetconnectivityProvider>(context);
    if (!internetConnProvider.isDeviceConnected) {
      if (this.mounted) {
        context.pop();
      }
      showToast(context, "No Internet Connection", Icons.wifi_off);
      return;
    }
    if (_formKeyContactUs.currentState!.validate()) {
      var Tdata = null;
      if (this.mounted) {
        buildShowDialog(context);
      }

      try {
        Map<String, String> jsonInputData = {
          'email': crypto.encrypt(_email),
          'subject': crypto.encrypt(_subject.text),
          'message': crypto.encrypt(_message.text),
        };

        final response = await createHTTPreq(
            'contact', http.post, _token, jsonInputData, context);

        _subject.text = "";
        _message.text = "";
        Tdata = jsonDecode(response.body);
        if (this.mounted) {
          context.pop();
        }

        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.check);
      } on Exception catch (err, stackTrace) {
        if (this.mounted) {
          context.pop();
        }

        if (this.mounted) {
          onException(context, err, stackTrace,
              reason: "Unknwon Error", info: ["ContactUs->sendContactData"]);
        }
      }

      if (this.mounted) {
        setState(() {});
      }
    }
  }

  initialisation() async {
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
  }

  @override
  void initState() {
    super.initState();
    initialisation();
  }

  Widget contactForm() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              controller: _controller,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  "You can suggest new features or report bug.",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(
                  height: 25,
                ),
                Form(
                    key: _formKeyContactUs,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _subject,
                          keyboardType: TextInputType.text,
                          maxLength: 100,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 18),
                          autocorrect: false,
                          validator: (value) {
                            RegExp validateText = RegExp(r'\b[\w]+\b');
                            if (!validateText.hasMatch(_subject.text)) {
                              return "Enter Valid Subject";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(8.0),
                            counterText: "",
                            hintText: "Enter Subject",
                            labelText: "Subject",
                            errorStyle: TextStyle(fontSize: 15),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                                width: 0.6,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextFormField(
                          controller: _message,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 18),
                          autocorrect: false,
                          maxLines: null,
                          maxLength: null,
                          validator: (value) {
                            RegExp validateText = RegExp(r'\b[\w]+\b');
                            if (!validateText.hasMatch(_message.text)) {
                              return "Enter Valid Message";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(8.0),
                            constraints:
                                BoxConstraints(maxHeight: 350, minHeight: 50),
                            hintText: "Enter Message",
                            labelText: "Message",
                            errorStyle: TextStyle(fontSize: 15),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                                width: 0.6,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 46,
                            width: 100,
                            child: OutlinedButton(
                                child: Text(
                                  "Send",
                                  style: TextStyle(
                                      color: themeProvider.isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16),
                                ),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13.0),
                                  ),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                onPressed: () {
                                  sendContactData(context);
                                }),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
      ),
      body: contactForm(),
    );
  }
}
