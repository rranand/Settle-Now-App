import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:shimmer/shimmer.dart';
import 'package:settlenow/others/crypto.dart';

class LendDenDashboard extends StatefulWidget {
  const LendDenDashboard({
    Key? key,
  }) : super(key: key);

  @override
  State<LendDenDashboard> createState() => _LendDenDashboardState();
}

class _LendDenDashboardState extends State<LendDenDashboard> {
  String _email = "";
  String _token = "";
  List<dynamic> data = [];
  List<dynamic> filteredResult = [];
  bool load = false;
  bool validateText = false;
  TextEditingController _name = TextEditingController();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyLendDenDashboard =
      new GlobalKey<RefreshIndicatorState>();

  bool searchTrigger = false;
  TextEditingController _searchText = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  Future createRoom(BuildContext context) async {
    try {
      Map<String, String> jsonInputData = {
        "email": crypto.encrypt(_email),
        "name": crypto.encrypt(_name.text)
      };

      final response = await createHTTPreq(
          'lend', http.post, _token, jsonInputData, context);

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
        onException(err, stackTrace,
            reason: "Unknwon Error", info: ["LendDenDashboard->createRoom"]);
      }
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

      var tokenData = await getStringPref('token');

      if (tokenData != null) {
        Map<String, dynamic> jsonOutData = parseJWT(tokenData.toString());
        if (this.mounted) {
          setState(() {
            _email = jsonOutData["email"]!;
            _token = jsonOutData["token"]!;
          });
        }
        Map<String, dynamic> jsonInputData = {
          'email': crypto.encrypt(_email),
          "url": crypto.encrypt(AppRouteConstants.lendRoomRouteName),
          "creationDate": crypto.encrypt(DateTime.now().toString())
        };
        pushAnalytics(context, jsonInputData, _token);
      } else {
        while (this.mounted && context.canPop()) {
          context.pop();
        }
        if (this.mounted) {
          context.go(AppRouteConstants.loginRouteName);
        }
        return;
      }

      Map<String, String> jsonInputData = {"email": crypto.encrypt(_email)};

      final response = await createHTTPreq(
          'lend', http.patch, _token, jsonInputData, context);

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
        String? apiErrorMessage = jsonDecode(response.body)["Message"];

        showToast(
            context,
            apiErrorMessage != null
                ? crypto.decrypt(apiErrorMessage)
                : "Some Unknown Error Occurred",
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        onException(err, stackTrace,
            reason: "Unknwon Error",
            info: ["LendDenDashboard->_initialization"]);
      }
    }

    load = true;

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getFilterResult() async {
    if (this.mounted) {
      setState(() {
        filteredResult.clear();
      });
    }

    if (_searchText.text.length > 0) {
      data.forEach((element) {
        if (crypto
            .decrypt(element["name"])
            .toLowerCase()
            .contains(_searchText.text.toLowerCase())) {
          filteredResult.add(element);
        }
      });
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _refreshIndicatorKeyLendDenDashboard.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: searchTrigger
          ? AppBar(
              title: TextField(
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                maxLines: 1,
                decoration: const InputDecoration(
                  counterText: "",
                  contentPadding: EdgeInsets.all(8.0),
                  hintText: "Search ...",
                ),
                onChanged: (String s) {
                  setState(() {
                    _searchText.setText(s);
                  });
                  getFilterResult();
                },
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        searchTrigger = false;
                      });
                      _searchText.setText("");
                      getFilterResult();
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      color:
                          themeProvider.darkTheme ? Colors.white : Colors.black,
                    )),
              ],
            )
          : null,
      body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          key: _refreshIndicatorKeyLendDenDashboard,
          onRefresh: _initialization,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: load
                ? (searchTrigger
                    ? (filteredResult.isEmpty
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
                              itemCount: filteredResult.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () async {
                                      if (this.mounted) {
                                        final dataFrom = await context.push(
                                          AppRouteConstants
                                                  .lendByTitleRouteName +
                                              "/" +
                                              crypto.decrypt(
                                                  filteredResult[index]["key"]),
                                        ) as Map<String, dynamic>;
                                        if (dataFrom.isNotEmpty) {
                                          filteredResult[index]["total"] =
                                              crypto.encrypt(
                                                  dataFrom["totalExp"]
                                                      .toStringAsFixed(2));
                                          filteredResult[index]["name"] = crypto
                                              .encrypt(dataFrom["roomName"]);
                                          filteredResult[index]
                                                  ["isClosedByYou"] =
                                              dataFrom["isClosed"];
                                          if (this.mounted) {
                                            setState(() {});
                                          }
                                        }
                                      }
                                    },
                                    child: Card(
                                      elevation: 2.0,
                                      shadowColor:
                                          Theme.of(context).primaryColor,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: filteredResult[index]
                                                    ["isClosedByYou"]
                                                ? Colors.red
                                                : Theme.of(context).cardColor),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              child: Text(
                                                crypto.decrypt(
                                                    filteredResult[index]
                                                        ["name"]),
                                                overflow: TextOverflow.ellipsis,
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
                                                        filteredResult[index]
                                                            ["name"]),
                                                    Icons.check);
                                              },
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "₹ " +
                                                  commaSeperator(crypto.decrypt(
                                                      filteredResult[index]
                                                          ["total"])),
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: crypto.decrypt(
                                                            filteredResult[
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
                    : (data.isEmpty
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
                                          AppRouteConstants
                                                  .lendByTitleRouteName +
                                              "/" +
                                              crypto
                                                  .decrypt(data[index]["key"]),
                                        ) as Map<String, dynamic>;
                                        if (dataFrom.isNotEmpty) {
                                          data[index]["total"] = crypto.encrypt(
                                              dataFrom["totalExp"]
                                                  .toStringAsFixed(2));
                                          data[index]["name"] = crypto
                                              .encrypt(dataFrom["roomName"]);
                                          data[index]["isClosedByYou"] =
                                              dataFrom["isClosed"];
                                          if (this.mounted) {
                                            setState(() {});
                                          }
                                        }
                                      }
                                    },
                                    child: Card(
                                      elevation: 2.0,
                                      shadowColor:
                                          Theme.of(context).primaryColor,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: data[index]["isClosedByYou"]
                                                ? Colors.red
                                                : Theme.of(context).cardColor),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              child: Text(
                                                crypto.decrypt(
                                                    data[index]["name"]),
                                                overflow: TextOverflow.ellipsis,
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
                                                  commaSeperator(crypto.decrypt(
                                                      data[index]["total"])),
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: crypto.decrypt(
                                                            data[index]
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
                          )))
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
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            ),
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 3,
                    color: Theme.of(context).primaryColor.withOpacity(0.7)),
                borderRadius: BorderRadius.circular(20)),
            onPressed: () {
              setState(() {
                searchTrigger = !searchTrigger;
              });
            },
          ),
          SizedBox(
            height: 8,
          ),
          FloatingActionButton(
            child: Icon(
              Icons.add,
              color: Theme.of(context).primaryColor,
            ),
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 3,
                    color: Theme.of(context).primaryColor.withOpacity(0.7)),
                borderRadius: BorderRadius.circular(20)),
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
        ],
      ),
    );
  }
}
