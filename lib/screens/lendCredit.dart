import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/screens/lendPage.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

class LendCredit extends StatefulWidget {
  final String email;
  final String token;

  const LendCredit({Key? key, required this.email, required this.token})
      : super(key: key);

  @override
  State<LendCredit> createState() => _LendCreditState();
}

class _LendCreditState extends State<LendCredit> {
  List<dynamic> data = [];
  bool load = false;
  bool validateText = false;
  final TextEditingController _name = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future createRoom(BuildContext context) async {
    try {
      final response = await http.post(Uri.parse(global.url + 'lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            "email": crypto.encrypt(widget.email),
            "name": crypto.encrypt(_name.text)
          }));

      if (response.statusCode == 200) {
        Navigator.pop(context);
        _refreshIndicatorKey.currentState?.show();
        _name.text = "";
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']),
            Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future _initialization() async {
    try {
      if (this.mounted) {
        setState(() {
          load = false;
          data.clear();
        });
      }

      final response = await http.patch(Uri.parse(global.url + 'lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({"email": crypto.encrypt(widget.email)}));

      if (response.statusCode == 200) {
        data = jsonDecode(response.body)['data'];
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]),
            Icons.close);
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }

    load = true;

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Len-Den"),
      ),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _initialization,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: load
                ? (data.isEmpty
                    ? ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: Center(
                              child: Text(
                                "No Room Found",
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          )
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (MediaQuery.of(context).size.width / 250)
                                    .round(),
                            childAspectRatio: 1.5,
                          ),
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LendPage(
                                              email: widget.email,
                                              token: widget.token,
                                              name: crypto
                                                  .decrypt(data[index]["name"]),
                                            ))),
                                child: Card(
                                  elevation: 2.0,
                                  shadowColor: Theme.of(context).primaryColor,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Theme.of(context).cardColor),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          crypto.decrypt(data[index]["name"]),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            foreground: Paint()
                                              ..shader = linearGradient_1,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "₹ " +
                                              commaSeperator(crypto.decrypt(
                                                  data[index]["total"])),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            foreground: Paint()
                                              ..shader = linearGradient_2,
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            );
                          },
                        ),
                      ))
                : ListView(physics: AlwaysScrollableScrollPhysics(), children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Text("Loading..."),
                      ),
                    )
                  ]),
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
                  return Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Create New Room",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextField(
                            controller: _name,
                            keyboardType: TextInputType.text,
                            maxLength: 150,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.all(8.0),
                                hintText: "Enter Room Name",
                                labelText: "Name",
                                errorStyle: TextStyle(fontSize: 15),
                                errorText: validateText
                                    ? "Enter Valid Room Name"
                                    : null),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: OutlinedButton(
                              child: Text(
                                "Create",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                if (_name.text.isNotEmpty) {
                                  validateText = false;
                                  buildShowDialog(context);
                                  await createRoom(context);
                                  Navigator.pop(context);
                                } else {
                                  validateText = true;
                                }
                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    ),
                  );
                });
              });
        },
      ),
    );
  }
}
