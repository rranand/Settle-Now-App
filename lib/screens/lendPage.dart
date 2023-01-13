import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/themes.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

class LendPage extends StatefulWidget {
  final String email;
  final String token;
  final String name;
  const LendPage(
      {Key? key, required this.email, required this.token, required this.name})
      : super(key: key);

  @override
  State<LendPage> createState() => _LendPageState();
}

class _LendPageState extends State<LendPage> {
  List<dynamic> data = [];
  bool load = false;

  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> addLoan(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.delete(Uri.parse(global.url + 'lend'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': widget.token
            },
            body: jsonEncode({
              "email": crypto.encrypt(widget.email),
              "name": crypto.encrypt(widget.name),
              "amount": crypto.encrypt(_amount.text),
              "purpose": crypto.encrypt(_purpose.text)
            }));

        if (response.statusCode == 200) {
          _purpose.text = "";
          _amount.text = "";
          Navigator.pop(context);
          _refreshIndicatorKey.currentState?.show();
        } else {
          showToast(
              context,
              crypto.decrypt(jsonDecode(response.body)["Message"]),
              Icons.close);
        }
      } on Exception catch (_) {
        Navigator.pop(context);
        await onException(context);
      }
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

      final response = await http.put(Uri.parse(global.url + 'lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            "email": crypto.encrypt(widget.email),
            "name": crypto.encrypt(widget.name)
          }));

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

  CloseRoom(BuildContext context) async {
    try {
      var CloseData = null;
      final response = await http.post(Uri.parse(global.url + 'lend/delete'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'name': crypto.encrypt(widget.name),
          }));

      CloseData = jsonDecode(response.body);
      showToast(context, crypto.decrypt(CloseData["Message"]), Icons.check);
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  closeRoomWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Are You Sure?",
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 37,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "No",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 37,
                            child: OutlinedButton(
                              onPressed: () async {
                                buildShowDialog(context);
                                await CloseRoom(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ))));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => closeRoomWidget(context),
                );
              },
              icon: Icon(Icons.delete))
        ],
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
                            height: MediaQuery.of(context).size.height - 100,
                            child: Center(
                              child: Text(
                                "No Record Found",
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          )
                        ],
                      )
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - 100,
                        width: MediaQuery.of(context).size.width * 0.95,
                        child: ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(
                            height: 6,
                          ),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 1.0,
                              color:
                                  Theme.of(context).scaffoldBackgroundColor,
                              shadowColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .cardColor
                                        .withAlpha(95)),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 18.0, horizontal: 8),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                    text: (crypto.decrypt(
                                                data[index]["amount"])[0] ==
                                            "-")
                                        ? "You owe "
                                        : "You gave ",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  TextSpan(
                                    text: ("₹ " +
                                        commaSeperator(crypto
                                            .decrypt(data[index]["amount"])
                                            .replaceFirst("-", " "))),
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: (crypto.decrypt(data[index]
                                                    ["amount"])[0] ==
                                                "-"
                                            ? Colors.red
                                            : Colors.green)),
                                  ),
                                  TextSpan(
                                      text: " for ",
                                      style: TextStyle(fontSize: 18)),
                                  TextSpan(
                                    text: (crypto
                                        .decrypt(data[index]["purpose"])),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ])),
                              ),
                            );
                          },
                        ),
                      ),
                    ))
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Text("Loading..."),
                    ),
                  ),
          )),
      floatingActionButton: FloatingActionButton(
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
                            "Add Credit/Debit",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _purpose,
                                  keyboardType: TextInputType.text,
                                  maxLength: 150,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 18),
                                  validator: (value) {
                                    RegExp validateText = RegExp(r'\b[\w]+\b');
                                    if (!validateText.hasMatch(_purpose.text)) {
                                      return "Enter Valid Purpose";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.all(8.0),
                                    hintText: "Enter Purpose",
                                    labelText: "Purpose",
                                    errorStyle: TextStyle(fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _amount,
                                  keyboardType: TextInputType.number,
                                  maxLength: 20,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 18),
                                  validator: (value) {
                                    RegExp validateNumber =
                                        RegExp(r'\b[1-9]{1}[\d]*\b');
                                    if (!validateNumber
                                        .hasMatch(_amount.text)) {
                                      return "Enter Valid Amount";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.all(8.0),
                                    hintText: "Enter Amount",
                                    labelText: "Amount",
                                    errorStyle: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: OutlinedButton(
                              child: Text(
                                "Add",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              onPressed: () async {
                                buildShowDialog(context);
                                await addLoan(context);
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
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
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
