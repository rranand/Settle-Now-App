import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/internetConnectivity.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;

class LendPage extends StatefulWidget {
  final String roomkey;
  const LendPage({
    Key? key,
    required this.roomkey,
  }) : super(key: key);

  @override
  State<LendPage> createState() => _LendPageState();
}

class _LendPageState extends State<LendPage> {
  String _email = "";
  String _token = "";
  String roomLink = "";
  String objID = "";
  final roomName = TextEditingController();
  List<dynamic> data = [];
  bool load = false;
  bool isPreviousPageNeedToBeUpdated = false;
  int expenseIndex = -1;
  bool firstTimeLoad = true;
  List<Map> getContactsFromDB = [];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getContactsFromLocal() async {
    try {
      String path = await getDBFilePath('contact_data.db');

      Database database = await openDatabase(path);
      getContactsFromDB =
          await database.rawQuery('SELECT * FROM ContactHasAccountOnSN');
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendPage->getContactsFromLocal"]);
      }
    }
  }

  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _Epurpose = TextEditingController();
  final TextEditingController _Eamount = TextEditingController();
  final TextEditingController _searchFriend = TextEditingController();
  AutoScrollController controller = AutoScrollController();
  List<FriendEach> friendDataSearched = [];
  List<FriendEach> friendData = [];
  bool loadFriendData = false;
  Map<String, dynamic> userData = {};
  Map<String, dynamic> otherUserData = {};
  DateTime expenseDate = DateTime.now();
  bool closed = false;
  bool isClosedByYou = false;
  GlobalKey<FormState> _formKeyLendPage = GlobalKey<FormState>();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyLendPage =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<FormState> _updateExpenseLendPage = GlobalKey<FormState>();
  bool isFriendDataLoaded = false;
  bool gaveMoney = false;
  bool EgaveMoney = false;

  Future<void> addLoan(BuildContext context) async {
    if (_formKeyLendPage.currentState!.validate()) {
      try {
        Map<String, String> jsonInputData = {
          "email": crypto.encrypt(_email),
          "key": crypto.encrypt(widget.roomkey),
          "amount": crypto.encrypt((gaveMoney ? "" : "-") + _amount.text),
          "purpose": crypto.encrypt(_purpose.text),
          'date': crypto
              .encrypt(DateFormat("MMM dd yyyy h:mm a").format(expenseDate))
        };

        final response = await createHTTPreq(
            'lend', http.delete, _token, jsonInputData, context);

        if (response.statusCode == 200) {
          isPreviousPageNeedToBeUpdated = true;
          _purpose.text = "";
          _amount.text = "";
          if (this.mounted) {
            context.pop();
          }
          _refreshIndicatorKeyLendPage.currentState?.show();
        } else {
          showToast(
              context,
              crypto.decrypt(jsonDecode(response.body)["Message"]),
              Icons.close);
        }
      } on Exception catch (err, stackTrace) {
        if (this.mounted) {
          context.pop();
        }

        if (this.mounted) {
          onException(context, err, stackTrace,
              reason: "Unknwon Error", info: ["LendPage->addLoan"]);
        }
      }
    }
  }

  getFriendData() async {
    try {
      if (this.mounted) {
        setState(() {
          loadFriendData = false;
          friendData.clear();
        });
      }
      Map<String, String> jsonInputData = {
        'key': crypto.encrypt(widget.roomkey),
        'email': crypto.encrypt(_email),
      };

      final response = await createHTTPreq(
          'friend/lend', http.patch, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loadFriendData = true;
        List<dynamic> tempData = data['data'];
        for (int i = 0; i < tempData.length; i++) {
          FriendEach friend = FriendEach.fromJson(tempData[i]);
          if (friend.email != _email) {
            friendData.add(FriendEach.fromJson(tempData[i]));
          }
        }
      } else {
        if (this.mounted) {
          showToast(context, crypto.decrypt(data["Message"]), Icons.close);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendPage->getFriendData"]);
      }
    }
    if (!kIsWeb) {
      friendData = getUnionOfContacts(getContactsFromDB, friendData);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  updateRoomName(BuildContext context, String newRoomName) async {
    var Tdata = null;
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomID': crypto.encrypt(widget.roomkey),
        'roomName': crypto.encrypt(newRoomName),
      };

      final response = await createHTTPreq(
          'updateRoomName/lendRoom', http.post, _token, jsonInputData, context);

      Tdata = jsonDecode(response.body);
      isPreviousPageNeedToBeUpdated = true;

      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        context.pop();
      }

      showToast(context, crypto.decrypt(Tdata["Message"]),
          response.statusCode == 200 ? Icons.check : Icons.close);

      if (response.statusCode == 200) {
        roomName.setText(newRoomName);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }

      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendPage->updateRoomName"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  SearchFriend() {
    if (this.mounted) {
      setState(() {
        friendDataSearched.clear();
      });
    }

    for (int i = 0; i < friendData.length; i++) {
      if (friendData[i]
          .name
          .toString()
          .toLowerCase()
          .contains(_searchFriend.text.toLowerCase())) {
        friendDataSearched.add(friendData[i]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  sendJoinRequest(String email, bool isFromContact, int index) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'key': crypto.encrypt(widget.roomkey),
        'email': crypto.encrypt(_email),
        'fEmail': crypto.encrypt(email),
        'isFromContact': crypto.encrypt(isFromContact.toString())
      };

      final response = await createHTTPreq(
          'friend/lend', http.post, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      friendData[index].fromContact = false;
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendPage->sendJoinRequest"]);
      }
    }
    if (this.mounted) {
      context.pop();
    }
  }

  cancelJoinRequest(String email, String id) async {
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      Map<String, String> jsonInputData = {
        'id': crypto.encrypt(id),
        'email': crypto.encrypt(email),
        'confirm': crypto.encrypt("0")
      };

      final response = await createHTTPreq(
          'friend/lend', http.put, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendPage->cancelJoinRequest"]);
      }
    }
    if (this.mounted) {
      context.pop();
    }
  }

  updateRoomNameDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    GlobalKey<FormState> _roomUpdateKeyLendPage = GlobalKey<FormState>();
    final _roomNameController = TextEditingController();
    _roomNameController.setText(roomName.text);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: SizedBox(
                    width: kIsWeb
                        ? max(MediaQuery.of(context).size.width * 0.5,
                            min(400, MediaQuery.of(context).size.width * 0.95))
                        : MediaQuery.of(context).size.width * 0.95,
                    child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Form(
                            key: _roomUpdateKeyLendPage,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _roomNameController,
                                  keyboardType: TextInputType.text,
                                  maxLength: 70,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 18),
                                  autocorrect: false,
                                  validator: (value) {
                                    RegExp validateText =
                                        RegExp(r'\b[\w]{4,}\b');
                                    if (!validateText
                                        .hasMatch(_roomNameController.text)) {
                                      return "Enter Valid Room Name";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.all(8.0),
                                    hintText: "Enter Room Name",
                                    errorStyle: TextStyle(fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 43,
                                      width: 130,
                                      child: OutlinedButton(
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkTheme
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            side: BorderSide(
                                                color: Colors.redAccent),
                                          ),
                                          onPressed: () {
                                            if (this.mounted) {
                                              context.pop();
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 43,
                                      width: 130,
                                      child: OutlinedButton(
                                          child: Text(
                                            "Update",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: themeProvider.isDarkTheme
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          onPressed: () async {
                                            if (_roomUpdateKeyLendPage
                                                .currentState!
                                                .validate()) {
                                              await updateRoomName(context,
                                                  _roomNameController.text);
                                            }
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ]))));
          });
        });
  }

  Widget friendListWidget(BuildContext context, List<FriendEach> data) {
    return StatefulBuilder(builder: (context, setState) {
      return Scrollbar(
        radius: Radius.circular(10.0),
        thickness: 5.5,
        child: ListView.separated(
            separatorBuilder: (context, index) => SizedBox(
                  height: 5,
                ),
            shrinkWrap: true,
            physics: ScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              return SizedBox(
                  height: 80,
                  child: Center(
                    child: Card(
                      elevation: 1.0,
                      shadowColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 51,
                                child: CachedNetworkImage(
                                  httpHeaders: {
                                    'Access-Control-Allow-Origin': '*'
                                  },
                                  imageUrl: data[index].pic.length == 0
                                      ? addCorsinImage(global.driveUrl +
                                          global.unknown_avatar_id)
                                      : addCorsinImage(data[index].pic),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 45.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Images/unknown.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 45.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 250,
                                child: InkWell(
                                  onTap: () {
                                    showToast(context, data[index].name,
                                        Icons.person);
                                  },
                                  child: AutoSizeText(
                                    data[index].name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 17),
                                    maxFontSize: 21,
                                    minFontSize: 17,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    if (data[index].status == "NJ") {
                                      await sendJoinRequest(data[index].email,
                                          data[index].fromContact, index);
                                      data[index].status = "S";
                                    } else {
                                      await cancelJoinRequest(
                                          data[index].email, widget.roomkey);
                                      data[index].status = "NJ";
                                    }
                                    if (this.mounted) {
                                      setState(() {});
                                    }
                                  },
                                  icon: Icon(data[index].status == "NJ"
                                      ? Icons.person_add_alt
                                      : Icons.cancel_outlined))
                            ]),
                      ),
                    ),
                  ));
            }),
      );
    });
  }

  _updateTransaction(BuildContext context, String purpose, String id,
      String amount, String flag) async {
    try {
      Map<String, String> jsonInputData = {
        "roomID": crypto.encrypt(widget.roomkey),
        'email': crypto.encrypt(_email),
        'purpose': crypto.encrypt(purpose),
        'amount': crypto.encrypt(amount),
        'id': crypto.encrypt(id),
        'flag': crypto.encrypt(flag)
      };

      final response = await createHTTPreq(
          'lend/transaction', http.delete, _token, jsonInputData, context);

      var updateMessage = jsonDecode(response.body);
      showToast(context, crypto.decrypt(updateMessage["Message"]), Icons.check);
      isPreviousPageNeedToBeUpdated = true;
      _refreshIndicatorKeyLendPage.currentState?.show();
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendPage->_updateTransaction"]);
      }
    }
  }

  Widget _buildUpdateDialog(
      BuildContext context, String id, String purpose, String amount) {
    if (amount.isNotEmpty && amount[0] != "-") {
      EgaveMoney = true;
    }
    return StatefulBuilder(builder: (context, setState) {
      _Epurpose.text = purpose;
      _Eamount.text = amount.replaceAll("-", "");

      final themeProvider = Provider.of<ThemeProvider>(context);
      return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: SingleChildScrollView(
            child: Container(
                width: kIsWeb
                    ? max(MediaQuery.of(context).size.width * 0.5,
                        min(400, MediaQuery.of(context).size.width))
                    : MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Form(
                      key: _updateExpenseLendPage,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (this.mounted) {
                                    setState(() {
                                      EgaveMoney = true;
                                    });
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: EgaveMoney
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).cardColor),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "You gave",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (this.mounted) {
                                    setState(() {
                                      EgaveMoney = false;
                                    });
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: EgaveMoney
                                            ? Theme.of(context).cardColor
                                            : Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      "You owe",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextFormField(
                            controller: _Eamount,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateNumber =
                                  RegExp(r'^\d+(\.\d{1,2})?$');
                              if (!validateNumber.hasMatch(_Eamount.text)) {
                                return "Enter Valid Amount";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(8.0),
                              hintText: "Enter Amount",
                              counterText: "",
                              labelText: "Amount",
                              errorStyle: TextStyle(fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _Epurpose,
                            keyboardType: TextInputType.text,
                            maxLength: 1000,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateText = RegExp(r'\b[\w]+\b');
                              if (!validateText.hasMatch(_Epurpose.text)) {
                                return "Enter Valid Purpose";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(8.0),
                              hintText: "Enter Purpose",
                              labelText: "Purpose",
                              counterText: "",
                              errorStyle: TextStyle(fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 43,
                                child: OutlinedButton(
                                    child: Text(
                                      "Update",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onPressed: () async {
                                      if (_updateExpenseLendPage.currentState!
                                          .validate()) {
                                        if (this.mounted) {
                                          buildShowDialog(context);
                                        }
                                        await _updateTransaction(
                                            context,
                                            _Epurpose.text,
                                            id,
                                            (EgaveMoney ? "" : "-") +
                                                _Eamount.text,
                                            "0");
                                        if (this.mounted) {
                                          context.pop();
                                        }
                                        if (this.mounted) {
                                          context.pop();
                                        }
                                      }
                                    }),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                height: 43,
                                child: OutlinedButton(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onPressed: () async {
                                      if (_updateExpenseLendPage.currentState!
                                          .validate()) {
                                        if (this.mounted) {
                                          buildShowDialog(context);
                                        }
                                        await _updateTransaction(
                                            context,
                                            _Epurpose.text,
                                            id,
                                            (EgaveMoney ? "" : "-") +
                                                _Eamount.text,
                                            "1");
                                        if (this.mounted) {
                                          context.pop();
                                        }
                                        if (this.mounted) {
                                          context.pop();
                                        }
                                      }
                                    }),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              SizedBox(
                                height: 43,
                                child: OutlinedButton(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      side: BorderSide(color: Colors.redAccent),
                                    ),
                                    onPressed: () async {
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ))),
          ));
    });
  }

  Future _initialization() async {
    try {
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
      if (this.mounted) {
        setState(() {
          expenseIndex = -1;
          load = false;
          data.clear();
        });
      }
      Map<String, String> jsonInputData = {
        "email": crypto.encrypt(_email),
        "key": crypto.encrypt(widget.roomkey)
      };

      final response =
          await createHTTPreq('lend', http.put, _token, jsonInputData, context);

      var resData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        data = resData['data'];
        roomName.setText(crypto.decrypt(resData['name']));
        roomLink = crypto.decrypt(resData['roomLink']);
        objID = crypto.decrypt(resData['key']);
        data.sort((b, a) {
          DateTime tempDate_1 = new DateFormat(global.dateTimeFormat)
              .parse(crypto.decrypt(a["date"]));
          DateTime tempDate_2 = new DateFormat(global.dateTimeFormat)
              .parse(crypto.decrypt(b["date"]));
          return tempDate_1.compareTo(tempDate_2);
        });
        if (firstTimeLoad) {
          expenseIndex = data
              .indexWhere((element) => crypto.decrypt(element['_id']) == objID);
          if (expenseIndex != -1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.scrollToIndex(expenseIndex,
                  preferPosition: AutoScrollPosition.begin);
            });
          }
        }
        firstTimeLoad = false;
        userData = jsonDecode(response.body)['user'];
        otherUserData = jsonDecode(response.body)['otherUser'];
        closed = jsonDecode(response.body)['closed'] ||
            jsonDecode(response.body)['closedOther'];
        isClosedByYou = jsonDecode(response.body)['closed'];
      } else if (response.statusCode == 503) {
        while (context.canPop()) {
          if (this.mounted) {
            context.pop();
          }
        }
        context.push(AppRouteConstants.maintainRouteName);
      } else if (response.statusCode == 422) {
        if (crypto.decrypt(resData["Message"]) == "Room Not Found") {
          context.push(AppRouteConstants.errorPageRouteName);
        }
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
            reason: "Unknwon Error", info: ["LendPage->_initialization"]);
      }
    }

    load = true;
    if (this.mounted) {
      setState(() {});
    }

    if (otherUserData.isEmpty && !isFriendDataLoaded) {
      isFriendDataLoaded = true;
      await getFriendData();

      if (this.mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getContactsFromLocal();
    _initialization();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical,
        suggestedRowHeight: 200);
  }

  CloseRoom(BuildContext context) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      var CloseData = null;
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomID': crypto.encrypt(widget.roomkey),
      };

      final response = await createHTTPreq(
          'lend/delete', http.post, _token, jsonInputData, context);

      CloseData = jsonDecode(response.body);
      isPreviousPageNeedToBeUpdated = true;
      for (int i = 0; i < 2 && context.canPop(); i++) {
        if (this.mounted) {
          context.pop();
        }
      }
      context.pop(isPreviousPageNeedToBeUpdated);
      showToast(context, crypto.decrypt(CloseData["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["LendPage->_initialization"]);
      }
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
                width: kIsWeb
                    ? max(MediaQuery.of(context).size.width * 0.5,
                        min(400, MediaQuery.of(context).size.width))
                    : MediaQuery.of(context).size.width,
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
                                if (this.mounted) {
                                  context.pop();
                                }
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
                                await CloseRoom(context);
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
    final internetConnProvider =
        Provider.of<InternetconnectivityProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(roomName.text),
          actions: load
              ? [
                  InkWell(
                    onTap: () async {
                      await updateRoomNameDialog(context);
                    },
                    child: Icon(Icons.edit_outlined),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  (otherUserData.isNotEmpty || closed)
                      ? SizedBox()
                      : IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder:
                                    (BuildContext context) => StatefulBuilder(
                                            builder: (context, setState) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.0)),
                                            child: Container(
                                                width: kIsWeb
                                                    ? max(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.5,
                                                        min(
                                                            400,
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width))
                                                    : MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              "Invite Member",
                                                              style: TextStyle(
                                                                  fontSize: 22),
                                                            ),
                                                            Row(
                                                              children: [
                                                                kIsWeb
                                                                    ? SizedBox()
                                                                    : IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          await Share.share("Join " +
                                                                              roomName.text +
                                                                              " (Len-Den) " +
                                                                              "\n" +
                                                                              roomLink);
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .send,
                                                                          size:
                                                                              26,
                                                                        )),
                                                                IconButton(
                                                                    onPressed:
                                                                        () async {
                                                                      if (this
                                                                          .mounted) {
                                                                        setState(
                                                                            () {
                                                                          loadFriendData =
                                                                              false;
                                                                          friendData
                                                                              .clear();
                                                                        });
                                                                      }
                                                                      await getFriendData();
                                                                      if (this
                                                                          .mounted) {
                                                                        setState(
                                                                            () {});
                                                                      }
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .refresh_outlined,
                                                                      size: 26,
                                                                    )),
                                                                IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      if (this
                                                                          .mounted) {
                                                                        context
                                                                            .pop();
                                                                      }
                                                                    },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .cancel_outlined,
                                                                      size: 26,
                                                                    ))
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        loadFriendData
                                                            ? friendData.isEmpty
                                                                ? SizedBox(
                                                                    height: MediaQuery.of(context)
                                                                            .size
                                                                            .height -
                                                                        310,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        "No User Found",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Column(
                                                                    children: [
                                                                      TextField(
                                                                        controller:
                                                                            _searchFriend,
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        maxLines:
                                                                            1,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15),
                                                                        autocorrect:
                                                                            false,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          contentPadding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          labelText:
                                                                              "Enter Name",
                                                                          counterText:
                                                                              "",
                                                                          errorStyle:
                                                                              const TextStyle(fontSize: 15),
                                                                        ),
                                                                        onChanged:
                                                                            (String
                                                                                s) {
                                                                          _searchFriend.text =
                                                                              s;
                                                                          _searchFriend.selection =
                                                                              TextSelection.collapsed(offset: _searchFriend.text.length);
                                                                          SearchFriend();
                                                                          if (this
                                                                              .mounted) {
                                                                            setState(() {});
                                                                          }
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            13,
                                                                      ),
                                                                      SingleChildScrollView(
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              MediaQuery.of(context).size.height - 310,
                                                                          child: _searchFriend.text.isEmpty
                                                                              ? friendListWidget(context, friendData)
                                                                              : (friendDataSearched.isEmpty
                                                                                  ? Center(
                                                                                      child: Text(
                                                                                        "No User Found",
                                                                                        style: TextStyle(fontSize: 18),
                                                                                      ),
                                                                                    )
                                                                                  : friendListWidget(context, friendDataSearched)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                            : SizedBox(
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height -
                                                                    310,
                                                                child: Center(
                                                                  child: CircularProgressIndicator
                                                                      .adaptive(),
                                                                ),
                                                              )
                                                      ],
                                                    ))),
                                          );
                                        }));
                          },
                          icon: Icon(Icons.person_add)),
                  isClosedByYou
                      ? SizedBox()
                      : IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  closeRoomWidget(context),
                            );
                          },
                          icon: Icon(Icons.delete))
                ]
              : [],
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: ((didPop) {
            if (didPop) {
              return;
            }
            context.pop(isPreviousPageNeedToBeUpdated);
          }),
          child: RefreshIndicator(
              color: Theme.of(context).primaryColor,
              key: _refreshIndicatorKeyLendPage,
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
                                controller: controller,
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return AutoScrollTag(
                                    controller: controller,
                                    index: index,
                                    key: ValueKey(index),
                                    child: Card(
                                      elevation: 1.0,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      shadowColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: index == expenseIndex
                                                ? Colors.redAccent
                                                : Theme.of(context)
                                                    .cardColor
                                                    .withAlpha(95)),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: (crypto.decrypt(
                                                        data[index]["by"]) ==
                                                    _email
                                                ? 5.0
                                                : 18.0),
                                            horizontal: (crypto.decrypt(
                                                        data[index]["by"]) ==
                                                    _email
                                                ? 8.0
                                                : 12.0)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    (crypto.decrypt(data[index]
                                                                ["by"]) ==
                                                            _email
                                                        ? CachedNetworkImage(
                                                            httpHeaders: {
                                                              'Access-Control-Allow-Origin':
                                                                  '*'
                                                            },
                                                            imageUrl: crypto
                                                                        .decrypt(userData[
                                                                            'pic'])
                                                                        .length ==
                                                                    0
                                                                ? addCorsinImage(
                                                                    global.driveUrl +
                                                                        global
                                                                            .unknown_avatar_id)
                                                                : addCorsinImage(
                                                                    crypto.decrypt(
                                                                        userData[
                                                                            'pic'])),
                                                            progressIndicatorBuilder: (context,
                                                                    url,
                                                                    downloadProgress) =>
                                                                CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Container(
                                                              width: 28,
                                                              height: 28,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/Images/unknown.jpeg'),
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              width: 28,
                                                              height: 28,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                          )
                                                        : CachedNetworkImage(
                                                            httpHeaders: {
                                                              'Access-Control-Allow-Origin':
                                                                  '*'
                                                            },
                                                            imageUrl: crypto
                                                                        .decrypt(otherUserData[
                                                                            'pic'])
                                                                        .length ==
                                                                    0
                                                                ? addCorsinImage(
                                                                    global.driveUrl +
                                                                        global
                                                                            .unknown_avatar_id)
                                                                : addCorsinImage(
                                                                    crypto.decrypt(
                                                                        otherUserData[
                                                                            'pic'])),
                                                            progressIndicatorBuilder: (context,
                                                                    url,
                                                                    downloadProgress) =>
                                                                CircularProgressIndicator(
                                                                    value: downloadProgress
                                                                        .progress),
                                                            errorWidget:
                                                                (context, url,
                                                                        error) =>
                                                                    Container(
                                                              width: 28,
                                                              height: 28,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    image: AssetImage(
                                                                        'assets/Images/unknown.jpeg'),
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              width: 28,
                                                              height: 28,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    image:
                                                                        imageProvider,
                                                                    fit: BoxFit
                                                                        .cover),
                                                              ),
                                                            ),
                                                          )),
                                                    SizedBox(
                                                      width: 6,
                                                    ),
                                                    Text(
                                                      (crypto.decrypt(
                                                                  data[index]
                                                                      ["by"]) ==
                                                              _email
                                                          ? crypto.decrypt(
                                                              userData['name'])
                                                          : crypto.decrypt(
                                                              otherUserData[
                                                                  'name'])),
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    data[index]["isEdited"]
                                                        ? Container(
                                                            width: 55,
                                                            height: 30,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: themeProvider
                                                                              .isDarkTheme
                                                                          ? (index == expenseIndex
                                                                              ? Colors.redAccent
                                                                              : Theme.of(context).primaryColor)
                                                                          : Colors.white,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(12))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(
                                                                  "Edited",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                          .white)),
                                                            ))
                                                        : SizedBox(),
                                                    crypto.decrypt(data[index]
                                                                ["by"]) ==
                                                            _email
                                                        ? IconButton(
                                                            onPressed:
                                                                () async {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (BuildContext context) => _buildUpdateDialog(
                                                                    context,
                                                                    crypto.decrypt(
                                                                        data[index]
                                                                            [
                                                                            "_id"]),
                                                                    crypto.decrypt(
                                                                        data[index]
                                                                            [
                                                                            "purpose"]),
                                                                    crypto.decrypt(
                                                                        data[index]
                                                                            [
                                                                            "amount"])),
                                                              );
                                                            },
                                                            icon: Icon(
                                                                Icons.edit))
                                                        : SizedBox(),
                                                  ],
                                                )
                                              ],
                                            ),
                                            (crypto.decrypt(
                                                        data[index]["by"]) ==
                                                    _email
                                                ? SizedBox()
                                                : SizedBox(height: 8.0)),
                                            Text.rich(TextSpan(children: [
                                              TextSpan(
                                                text: (crypto.decrypt(data[
                                                                index]
                                                            ["amount"])[0] ==
                                                        "-")
                                                    ? "You owe "
                                                    : "You gave ",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: ("₹ " +
                                                    commaSeperator(crypto
                                                        .decrypt(data[index]
                                                            ["amount"])
                                                        .replaceFirst(
                                                            "-", " "))),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: (crypto.decrypt(data[
                                                                    index][
                                                                "amount"])[0] ==
                                                            "-"
                                                        ? Colors.red
                                                        : Colors.green)),
                                              ),
                                              TextSpan(
                                                  text: " for ",
                                                  style:
                                                      TextStyle(fontSize: 18)),
                                              TextSpan(
                                                text: (crypto.decrypt(
                                                    data[index]["purpose"])),
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: " on ",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              TextSpan(
                                                text: formatDateTime(
                                                    crypto.decrypt(
                                                        data[index]["date"])),
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ])),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ))
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
                                              Row(
                                                children: [
                                                  Container(
                                                      width: 28,
                                                      height: 28,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                'assets/Images/unknown.jpeg'),
                                                            fit: BoxFit.cover),
                                                      )),
                                                  SizedBox(
                                                    width: 6,
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        height: 15.0,
                                                        decoration:
                                                            BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20))),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 6,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    50,
                                                height: 15.0,
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
                                                        .width -
                                                    50,
                                                height: 15.0,
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
              )),
        ),
        floatingActionButton: closed
            ? null
            : FloatingActionButton(
                onPressed: () {
                  expenseDate = DateTime.now();
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
                                    key: _formKeyLendPage,
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                if (this.mounted) {
                                                  setState(() {
                                                    gaveMoney = true;
                                                  });
                                                }
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: gaveMoney
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .cardColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Text(
                                                    "You gave",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (this.mounted) {
                                                  setState(() {
                                                    gaveMoney = false;
                                                  });
                                                }
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: gaveMoney
                                                          ? Theme.of(context)
                                                              .cardColor
                                                          : Theme.of(context)
                                                              .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Text(
                                                    "You owe",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextFormField(
                                          controller: _amount,
                                          keyboardType: TextInputType.number,
                                          maxLength: 20,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 18),
                                          validator: (value) {
                                            RegExp validateNumber =
                                                RegExp(r'^\d+(\.\d{1,2})?$');
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
                                        SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          controller: _purpose,
                                          keyboardType: TextInputType.text,
                                          maxLength: 1000,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 18),
                                          validator: (value) {
                                            RegExp validateText =
                                                RegExp(r'\b[\w]+\b');
                                            if (!validateText
                                                .hasMatch(_purpose.text)) {
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
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat(
                                                    global.dateTimeFormat_new)
                                                .format(expenseDate),
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              DateTime? dateTime =
                                                  await showOmniDateTimePicker(
                                                context: context,
                                                is24HourMode: false,
                                                isShowSeconds: false,
                                                initialDate: expenseDate,
                                                firstDate: DateTime(2018),
                                                lastDate: DateTime.now(),
                                                borderRadius:
                                                    BorderRadius.circular(16.0),
                                              );

                                              if (dateTime != null) {
                                                if (this.mounted) {
                                                  setState(() {
                                                    expenseDate = dateTime;
                                                  });
                                                }
                                              }
                                            },
                                            child: Icon(
                                              Icons.edit_calendar,
                                              size: 22,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
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
                                        if (this.mounted) {
                                          buildShowDialog(context);
                                        }
                                        await addLoan(context);
                                        if (this.mounted) {
                                          context.pop();
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(13.0),
                                        ),
                                        side: BorderSide(
                                            color:
                                                Theme.of(context).primaryColor),
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
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 3,
                        color: Theme.of(context).primaryColor.withOpacity(0.7)),
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                ),
              ),
        bottomNavigationBar: internetConnProvider.isAlertSet
            ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: internetConnProvider.isDeviceConnected
                      ? Colors.green
                      : Colors.red,
                ),
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Center(
                      child: Text(
                    internetConnProvider.isDeviceConnected
                        ? "You are connected to Internet"
                        : "You aren't connected to Internet",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  )),
                ),
              )
            : null);
  }
}
