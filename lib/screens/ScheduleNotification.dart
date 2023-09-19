import 'dart:async';
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';
import 'package:shimmer/shimmer.dart';
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
  int currentDateIndex = 0;
  bool load = true;
  final _formKey = GlobalKey<FormState>();
  List<dynamic> data = [];
  List<String> dates = [];

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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  Future _initialization() async {
    try {
      if (this.mounted) {
        setState(() {
          load = false;
          data.clear();
          dates.clear();
        });
      }

      currentDateIndex = DateTime.now().day - 1;
      for (int i = 0; i < 31; i++) {
        dates.add((i + 1).toString());
      }

      Map<String, String> jsonInputData = {
        "email": crypto.encrypt(widget.email),
      };

      final response = await createHTTPreq(
          'remainder', http.post, widget.token, jsonInputData);

      if (response.statusCode == 200) {
        var tempData = jsonDecode(response.body);
        data = tempData['data'];
      } else if (response.statusCode == 503) {
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
      }
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

  Future _deleteRemainder(String id, int index, String notID) async {
    notID = crypto.decrypt(notID);
    List<String> IDs = notID.substring(1, notID.length - 1).split(', ');
    if (this.mounted) {
      if (this.mounted) {
        buildShowDialog(context);
      }
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'id': crypto.encrypt(id)
      };

      final response = await createHTTPreq(
          'remainder', http.delete, widget.token, jsonInputData);

      if (this.mounted) {
        Navigator.pop(context);
      }

      var Tdata = jsonDecode(response.body);
      if (response.statusCode == 200) {
        for (int i = 0; i < IDs.length; i++) {
          await AwesomeNotifications().cancelSchedule(int.parse(IDs[i]));
        }
        data.removeAt(index);
        showToast(context, "Remainder Deleted", Icons.check);
      } else {
        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
      }
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

  Future _addRemainder() async {
    if (_formKey.currentState!.validate()) {
      if (this.mounted) {
        if (this.mounted) {
          buildShowDialog(context);
        }
      }

      List<int> IDs = [];
      for (int i = 0; i < 4; i++) {
        IDs.add(
            DateTime.now().add(Duration(hours: i * 4)).millisecondsSinceEpoch ~/
                1000);
      }

      try {
        Map<String, String> jsonInputData = {
          'email': crypto.encrypt(widget.email),
          'name': crypto.encrypt(_name.text),
          'date': crypto.encrypt(dates[currentDateIndex]),
          'notID': crypto.encrypt(IDs.toString())
        };

        final response = await createHTTPreq(
            'remainder', http.patch, widget.token, jsonInputData);

        _name.text = "";
        if (this.mounted) {
          Navigator.pop(context);
        }
        if (this.mounted) {
          Navigator.pop(context);
        }

        var Tdata = jsonDecode(response.body);
        if (response.statusCode == 200) {
          data.add(Tdata['data']);
          for (int i = 0; i < IDs.length; i++) {
            await AwesomeNotifications().createNotification(
                content: NotificationContent(
                    id: IDs[i],
                    channelKey: 'remainderID',
                    title: "Remainder",
                    body: crypto.decrypt(data.last['name']),
                    payload: null),
                schedule: NotificationCalendar(
                    day: int.parse(dates[currentDateIndex]),
                    hour: 7 + (i * 4),
                    minute: 0,
                    second: 0,
                    allowWhileIdle: true,
                    timeZone: "Asia/Kolkata"));
          }

          showToast(context, "Remainder Created", Icons.check);
        } else {
          showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
        }
      } on Exception catch (_) {
        if (this.mounted) {
          await onException(context);
        }
      }
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  void showDetailsPopUp(
      String name, String dates, String id, int index, String notID) {
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
                              crypto.decrypt(name),
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                                "On Every " +
                                    crypto.decrypt(dates) +
                                    " of Month",
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
                                    onPressed: () async {
                                      await _deleteRemainder(id, index, notID);
                                      if (this.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
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
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Form(
                        key: _formKey,
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
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "On Every " +
                                      dates[currentDateIndex] +
                                      " of Month",
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              SizedBox(
                                height: 220,
                                child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          (MediaQuery.of(context).size.width /
                                                  60)
                                              .round(),
                                      childAspectRatio: 1.1,
                                    ),
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: dates.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return InkWell(
                                        onTap: () async {
                                          if (this.mounted) {
                                            setState(() {
                                              currentDateIndex = index;
                                            });
                                          }
                                        },
                                        child: Container(
                                          width: 25,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (currentDateIndex == index)
                                                ? Theme.of(context).primaryColor
                                                : null,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                dates[index],
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await _addRemainder();
                                  },
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
        bottomNavigationBar: isAlertSet
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: isDeviceConnected ? Colors.green : Colors.red,
                ),
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                      child: Text(
                    isDeviceConnected
                        ? "You are connected to Internet"
                        : "You aren't connected to Internet",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  )),
                ),
              )
            : null,
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
                                      "No Remainder",
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
                                              data[index]["id"],
                                              index,
                                              data[index]["notID"]);
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
                                                    Text(
                                                        crypto.decrypt(
                                                            data[index]
                                                                ["name"]),
                                                        style: TextStyle(
                                                            fontSize: 18)),
                                                    SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                        "On Every " +
                                                            crypto.decrypt(
                                                                data[index]
                                                                    ["dates"]) +
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
