import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/models/ContactEach.dart';
import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;
import '../others/themes.dart';

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
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

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
  void dispose() {
    subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  sendContactData(BuildContext context) async {
    if (!isDeviceConnected) {
      if (this.mounted) {
          Navigator.pop(context);
        }
      return;
    }
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
        if (this.mounted) {
          Navigator.pop(context);
        }

        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.check);
      } on Exception catch (_) {
        if (this.mounted) {
          Navigator.pop(context);
        }
        if (this.mounted) {
          await onException(context);
        }
      }

      if (this.mounted) {
        setState(() {});
      }
    }
  }

  Future<List<ContactEach>> fetchContactData() async {
    if (!isDeviceConnected) {
      return [];
    }
    List<ContactEach> contactData = [];
    try {
      final response = await http.patch(Uri.parse(global.url + 'contact'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
          }));

      if (response.statusCode == 200) {
        List<dynamic> tempData = jsonDecode(response.body)['data'];
        for (int i = 0; i < tempData.length; i++) {
          contactData.add(ContactEach.fromJson(tempData[i]));
        }
      }
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
      }
    }
    return contactData;
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
  }

  Widget contactData() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FutureBuilder<List<ContactEach>>(
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 100,
                child: snapshot.data!.isEmpty
                    ? ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 100,
                            child: Center(
                              child: Text(
                                "No Data Found",
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 1.0,
                            clipBehavior: Clip.antiAlias,
                            shadowColor: Theme.of(context).primaryColor,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withAlpha(95)),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data![index].subject,
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: snapshot.data![index].pic
                                                        .length ==
                                                    0
                                                ? global.driveUrl +
                                                    "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                : snapshot.data![index].pic,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              width: 28.0,
                                              height: 28.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/Images/unknown.jpeg'),
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              width: 28.0,
                                              height: 28.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(snapshot.data![index].name,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                      Text(snapshot.data![index].date,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    snapshot.data![index].message,
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
              ),
            );
          } else if (snapshot.hasError) {
            return SizedBox();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: fetchContactData(),
      ),
    );
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
        title: Text(widget.email == "rrohitanand3336@gmail.com"
            ? "Contact Data"
            : "Contact Us"),
      ),
      body: widget.email == "rrohitanand3336@gmail.com"
          ? contactData()
          : contactForm(),
    );
  }
}
