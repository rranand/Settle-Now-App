import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';
import 'package:shimmer/shimmer.dart';
import '../contents.dart' as global;
import '../others/themes.dart';
import 'maintain.dart';

class ScheduleNotification extends StatefulWidget {
  final String email;
  final String token;
  const ScheduleNotification(
      {Key? key, required this.email, required this.token})
      : super(key: key);

  @override
  State<ScheduleNotification> createState() => _ScheduleNotificationState();
}

class _ScheduleNotificationState extends State<ScheduleNotification> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final TextEditingController _name = TextEditingController();
  bool load = true;
  List<dynamic> data = [
    {"id": "A", "name": "Rent", "dates": "1"},
    {"id": "B", "name": "Checkup", "dates": "13"},
    {"id": "C", "name": "Bill", "dates": "15"}
  ];
  String currentDateTime = "";
  DateFormat dateFormat_new = DateFormat("EEE, MMM dd yyyy");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  Future _initialization() async {
    try {
      if (this.mounted) {
        setState(() {
          load = false;
          //data.clear();
        });
      }

      currentDateTime = dateFormat_new.format(DateTime.now());

      /*final response = await http.put(Uri.parse(global.url + 'lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            "email": crypto.encrypt(widget.email),
          }));

      if (response.statusCode == 200) {
      } else if (jsonDecode(response.body)['maintenance'] != null &&
          jsonDecode(response.body)['maintenance']) {
        if (this.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Maintenance()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]),
            Icons.close);
      }*/
    } on Exception catch (_) {
      if (this.mounted) {
        Navigator.pop(context);
      }
      if (this.mounted) {
        await onException(context);
      }
    }

    load = true;
    if (this.mounted) {
      setState(() {});
    }
  }

  void showDetailsPopUp(String name, String dates, String id) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              name,
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text("On Every " + dates + " of Month",
                                style: TextStyle(fontSize: 19)),
                            SizedBox(
                              height: 16,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 40,
                                  width: 100,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      side: BorderSide(color: Colors.redAccent),
                                    ),
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                SizedBox(
                                  height: 40,
                                  width: 100,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    child: Text(
                                      "Close",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ]),
                    ),
                  ),
                ));
          });
        });
  }

  void showAddPopUp() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              "Add Remainder",
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              controller: _name,
                              keyboardType: TextInputType.text,
                              maxLength: 1000,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 18),
                              autocorrect: false,
                              validator: (value) {
                                if (_name.text.length <= 2) {
                                  return "Enter Valid Remind Message";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.all(8.0),
                                hintText: "Enter Remind Message",
                                labelText: "Remind me to",
                                errorStyle: TextStyle(fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            InkWell(
                              onTap: () async {
                                DateTime? result = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030, 12, 31),
                                  initialDate: DateTime.now(),
                                );
                                if (result == null) {
                                  currentDateTime = currentDateTime;
                                } else {
                                  currentDateTime =
                                      dateFormat_new.format(result);
                                }

                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  currentDateTime,
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Text(
                                  "Add",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                            )
                          ]),
                    ),
                  ),
                ));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Remainder"),
        ),
        body: WillPopScope(
            onWillPop: () {
              Navigator.pop(context, false);
              return new Future(() => false);
            },
            child: RefreshIndicator(
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
                                  height:
                                      MediaQuery.of(context).size.height - 100,
                                  child: Center(
                                    child: Text(
                                      "No Notification Scheduled",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 100,
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          height: 6,
                                        ),
                                    itemCount: data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () async {
                                          showDetailsPopUp(
                                              data[index]["name"],
                                              data[index]["dates"],
                                              data[index]["id"]);
                                        },
                                        child: Card(
                                            elevation: 1.0,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shadowColor:
                                                Theme.of(context).primaryColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .cardColor
                                                      .withAlpha(95)),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: SizedBox(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(data[index]["name"],
                                                        style: TextStyle(
                                                            fontSize: 18)),
                                                    SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                        "On Every " +
                                                            data[index]
                                                                ["dates"] +
                                                            " of Month",
                                                        style: TextStyle(
                                                            fontSize: 16))
                                                  ],
                                                ),
                                              ),
                                            )),
                                      );
                                    }),
                              )))
                      : SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context).cardColor,
                            highlightColor: Theme.of(context).primaryColor,
                            child: ListView.builder(
                                itemCount: 16,
                                itemBuilder: (_, __) => Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 12),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.7,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: 20.0,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20))),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ))),
                          ),
                        ),
                ))),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            showAddPopUp();
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ));
  }
}
