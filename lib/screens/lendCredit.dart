import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:shimmer/shimmer.dart';
import 'package:settlenow/others/crypto.dart';

class LendCredit extends StatefulWidget {
  const LendCredit({
    Key? key,
  }) : super(key: key);

  @override
  State<LendCredit> createState() => _LendCreditState();
}

class _LendCreditState extends State<LendCredit> {
  String _email = "";
  String _token = "";
  List<dynamic> data = [];
  bool load = false;
  bool validateText = false;
  int indexLoading = -1;
  TextEditingController _name = TextEditingController();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyLendCredit =
      new GlobalKey<RefreshIndicatorState>();

  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  getConnectivity() async {
    subscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> result) async {
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

    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    setState(() {});
    if (!isDeviceConnected && isAlertSet == false) {
      setState(() => isAlertSet = true);
    } else if (isDeviceConnected && isAlertSet == true) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() => isAlertSet = false);
      });
    }
  }

  Future createRoom(BuildContext context) async {
    try {
      Map<String, String> jsonInputData = {
        "email": crypto.encrypt(_email),
        "name": crypto.encrypt(_name.text)
      };

      final response =
          await createHTTPreq('lend', http.post, _token, jsonInputData);

      if (response.statusCode == 200) {
        if (this.mounted) {
          context.pop();
        }
        data.add(jsonDecode(response.body)['data']);
        _name.text = "";
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']),
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendCredit->createRoom"]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future updateRoom(BuildContext context, int index, String roomID) async {
    if (this.mounted) {
      setState(() {
        indexLoading = index;
      });
    }
    try {
      Map<String, String> jsonInputData = {
        "email": crypto.encrypt(_email),
        "roomKey": roomID
      };

      final response =
          await createHTTPreq('update/lend', http.post, _token, jsonInputData);

      if (response.statusCode == 200) {
        bool isDeleted = jsonDecode(response.body)["isDeleted"];
        if (isDeleted) {
          data.removeAt(index);
        } else {
          data[index] = jsonDecode(response.body)["data"];
        }
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']),
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendCredit->updateRoom"]);
      }
    }

    indexLoading = -1;
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

      var tokenData = await getStringPref('token');

      if (tokenData != null) {
        Map<String, dynamic> jsonOutData = parseJWT(tokenData.toString());
        if (this.mounted) {
          setState(() {
            _email = jsonOutData["email"]!;
            _token = jsonOutData["token"]!;
          });
        }
      }

      Map<String, String> jsonInputData = {"email": crypto.encrypt(_email)};

      final response =
          await createHTTPreq('lend', http.patch, _token, jsonInputData);

      if (response.statusCode == 200) {
        data = jsonDecode(response.body)['data'];
      } else if (response.statusCode == 503) {
        while (context.canPop()) {
          if (this.mounted) {
            context.pop();
          }
        }
        context.push(AppRouteConstants.maintainRouteName);
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]),
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendCredit->_initialization"]);
      }
    }

    load = true;

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _refreshIndicatorKeyLendCredit.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: RefreshIndicator(
          key: _refreshIndicatorKeyLendCredit,
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
                                onTap: () async {
                                  if (this.mounted) {
                                    final dataFrom = await context.push(
                                      AppRouteConstants.lendByTitleRouteName +
                                          "/" +
                                          crypto.decrypt(data[index]["key"]),
                                    ) as bool;
                                    if (dataFrom) {
                                      await updateRoom(
                                          context, index, data[index]["key"]);
                                    }
                                  }
                                },
                                child: Card(
                                  elevation: 2.0,
                                  shadowColor: Theme.of(context).primaryColor,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: data[index]["isClosedByYou"]
                                            ? Colors.red
                                            : Theme.of(context).cardColor),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: indexLoading == index
                                      ? Shimmer.fromColors(
                                          baseColor:
                                              Theme.of(context).cardColor,
                                          highlightColor:
                                              Theme.of(context).primaryColor,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 180,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      width: 110,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                              InkWell(
                                                child: Text(
                                                  crypto.decrypt(
                                                      data[index]["name"]),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w500,
                                                    foreground: kIsWeb
                                                        ? null
                                                        : (Paint()
                                                          ..shader =
                                                              linearGradient_1),
                                                  ),
                                                ),
                                                onTap: () async {
                                                  showToast(
                                                      context,
                                                      crypto.decrypt(
                                                          data[index]["name"]),
                                                      Icons.check);
                                                },
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                "₹ " +
                                                    commaSeperator(crypto
                                                        .decrypt(data[index]
                                                            ["total"])),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: crypto.decrypt(data[
                                                                  index]
                                                              ["total"])[0] ==
                                                          '-'
                                                      ? Colors.red
                                                      : Colors.green,
                                                  fontWeight: FontWeight.w500,
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
                      child: Shimmer.fromColors(
                          baseColor: Theme.of(context).cardColor,
                          highlightColor: Theme.of(context).primaryColor,
                          child: Padding(
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
                              itemCount: 16,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 180,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.white,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            width: 110,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.white,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          )
                                        ],
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                        ),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                  ),
                                );
                              },
                            ),
                          )),
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
                            maxLength: 1000,
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
                                  if (this.mounted) {
                                    buildShowDialog(context);
                                  }
                                  await createRoom(context);
                                  if (this.mounted) {
                                    context.pop();
                                  }
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
