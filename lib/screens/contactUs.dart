import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;

class ContactUs extends StatefulWidget {
  final String token;
  final String email;
  const ContactUs({Key? key, required this.email, required this.token})
      : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _message = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ScrollController _controller = ScrollController();

  sendContactData(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var Tdata = null;
      buildShowDialog(context);

      try {
        final response = await http.post(Uri.parse(global.url + 'contact'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': widget.token
            },
            body: jsonEncode({
              'email': crypto.encrypt(widget.email),
              'subject': crypto.encrypt(_subject.text),
              'message': crypto.encrypt(_message.text),
            }));

        _subject.text = "";
        _message.text = "";
        Tdata = jsonDecode(response.body);
        Navigator.pop(context);

        showToast(context, crypto.decrypt(Tdata["Message"]));
      } on Exception catch (_) {
        Navigator.pop(context);
        showToast(context, "No Internet Connection");
      }

      if (this.mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
      ),
      body: Center(
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
                    "You can request new features or report bug.",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Form(
                      key: _formKey,
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
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).backgroundColor,
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
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Theme.of(context).backgroundColor,
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
                              height: 40,
                              width: 100,
                              child: ElevatedButton(
                                  child: const Text(
                                    "Send",
                                    style: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
