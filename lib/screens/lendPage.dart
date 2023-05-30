import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

class LendPage extends StatefulWidget {
  final String email;
  final String token;
  final String name;
  final String roomkey;
  final String roomLink;
  final String objID;
  const LendPage(
      {Key? key,
      required this.email,
      required this.token,
      required this.name,
      required this.roomkey,
      required this.roomLink,
      required this.objID})
      : super(key: key);

  @override
  State<LendPage> createState() => _LendPageState();
}

class _LendPageState extends State<LendPage> {
  List<dynamic> data = [];
  bool load = false;
  bool isPreviousPageNeedToBeUpdated = false;
  int expenseIndex = -1;
  bool firstTimeLoad = true;
  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

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
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final _updateExpense = GlobalKey<FormState>();
  bool isFriendDataLoaded = false;
  bool gaveMoney = false;
  bool EgaveMoney = false;

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
              "key": crypto.encrypt(widget.roomkey),
              "amount": crypto.encrypt((gaveMoney ? "" : "-") + _amount.text),
              "purpose": crypto.encrypt(_purpose.text),
              'date': crypto
                  .encrypt(DateFormat("MMM dd yyyy h:mm a").format(expenseDate))
            }));

        if (response.statusCode == 200) {
          isPreviousPageNeedToBeUpdated = true;
          _purpose.text = "";
          _amount.text = "";
          if (this.mounted) {
            Navigator.pop(context);
          }
          _refreshIndicatorKey.currentState?.show();
        } else {
          showToast(
              context,
              crypto.decrypt(jsonDecode(response.body)["Message"]),
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
      final response = await http.patch(Uri.parse(global.url + 'friend/lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'key': crypto.encrypt(widget.roomkey),
            'email': crypto.encrypt(widget.email),
          }));

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loadFriendData = true;
        List<dynamic> tempData = data['data'];
        for (int i = 0; i < tempData.length; i++) {
          friendData.add(FriendEach.fromJson(tempData[i]));
        }
      } else {
        if (this.mounted) {
          showToast(context, crypto.decrypt(data["Message"]), Icons.close);
        }
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

  sendJoinRequest(String email) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      final response = await http.post(Uri.parse(global.url + 'friend/lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'key': crypto.encrypt(widget.roomkey),
            'email': crypto.encrypt(widget.email),
            'fEmail': crypto.encrypt(email)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
      }
    }
    if (this.mounted) {
      Navigator.pop(context);
    }
  }

  cancelJoinRequest(String email, String id) async {
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      final response = await http.put(Uri.parse(global.url + 'friend/lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'id': crypto.encrypt(id),
            'email': crypto.encrypt(email),
            'confirm': crypto.encrypt("0")
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
      }
    }
    if (this.mounted) {
      Navigator.pop(context);
    }
  }

  Widget addFriendWidget(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Invite Member",
                        style: TextStyle(fontSize: 22),
                      ),
                      IconButton(
                          onPressed: () async {
                            await Share.share("Join " +
                                widget.name +
                                " (Len-Den) " +
                                "\n" +
                                widget.roomLink);
                          },
                          icon: Icon(
                            Icons.send,
                            size: 26,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  loadFriendData
                      ? friendData.isEmpty
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height - 310,
                              child: Center(
                                child: Text(
                                  "No User Found",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                TextField(
                                  controller: _searchFriend,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 15),
                                  autocorrect: false,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.all(8.0),
                                    labelText: "Enter Name",
                                    counterText: "",
                                    errorStyle: const TextStyle(fontSize: 15),
                                  ),
                                  onChanged: (String s) {
                                    _searchFriend.text = s;
                                    _searchFriend.selection =
                                        TextSelection.collapsed(
                                            offset: _searchFriend.text.length);
                                    SearchFriend();
                                    if (this.mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 13,
                                ),
                                SingleChildScrollView(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        310,
                                    child: _searchFriend.text.isEmpty
                                        ? friendListWidget(context, friendData)
                                        : (friendDataSearched.isEmpty
                                            ? Center(
                                                child: Text(
                                                  "No User Found",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              )
                                            : friendListWidget(
                                                context, friendDataSearched)),
                                  ),
                                ),
                              ],
                            )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height - 310,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                ],
              ))),
    );
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
                                  imageUrl: data[index].pic.length == 0
                                      ? global.driveUrl +
                                          "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                      : data[index].pic,
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
                                      await sendJoinRequest(data[index].email);
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
      final response = await http.delete(
          Uri.parse(global.url + 'lend/transaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            "roomID": crypto.encrypt(widget.roomkey),
            'email': crypto.encrypt(widget.email),
            'purpose': crypto.encrypt(purpose),
            'amount': crypto.encrypt(amount),
            'id': crypto.encrypt(id),
            'flag': crypto.encrypt(flag)
          }));

      var updateMessage = jsonDecode(response.body);
      showToast(context, crypto.decrypt(updateMessage["Message"]), Icons.check);
      isPreviousPageNeedToBeUpdated = true;
      _refreshIndicatorKey.currentState?.show();
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
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
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Form(
                      key: _updateExpense,
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
                                  RegExp(r'\b[1-9]{1}[\d]*\b');
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 43,
                                width: MediaQuery.of(context).size.width * 0.3,
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
                                      if (_updateExpense.currentState!
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
                                          Navigator.pop(context);
                                        }
                                        if (this.mounted) {
                                          Navigator.pop(context);
                                        }
                                      }
                                    }),
                              ),
                              SizedBox(
                                height: 43,
                                width: MediaQuery.of(context).size.width * 0.3,
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
                                      if (_updateExpense.currentState!
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
                                          Navigator.pop(context);
                                        }
                                        if (this.mounted) {
                                          Navigator.pop(context);
                                        }
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
      if (this.mounted) {
        setState(() {
          expenseIndex = -1;
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
            "key": crypto.encrypt(widget.roomkey)
          }));

      if (response.statusCode == 200) {
        data = jsonDecode(response.body)['data'];
        data.sort((b, a) {
          DateTime tempDate_1 = new DateFormat(global.dateTimeFormat)
              .parse(crypto.decrypt(a["date"]));
          DateTime tempDate_2 = new DateFormat(global.dateTimeFormat)
              .parse(crypto.decrypt(b["date"]));
          return tempDate_1.compareTo(tempDate_2);
        });
        if (firstTimeLoad) {
          expenseIndex = data.indexWhere(
              (element) => crypto.decrypt(element['_id']) == widget.objID);
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
    getConnectivity();
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
      isPreviousPageNeedToBeUpdated = true;
      if (this.mounted) {
        Navigator.pop(context);
      }
      if (this.mounted) {
        Navigator.pop(context);
      }
      Navigator.pop(context, isPreviousPageNeedToBeUpdated);
      showToast(context, crypto.decrypt(CloseData["Message"]), Icons.check);
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
                                if (this.mounted) {
                                  Navigator.pop(context);
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
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          actions: [
            otherUserData.isNotEmpty
                ? SizedBox()
                : IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            addFriendWidget(context),
                      );
                    },
                    icon: Icon(Icons.person_add)),
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
        body: WillPopScope(
          onWillPop: () {
            Navigator.pop(context, isPreviousPageNeedToBeUpdated);
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
                                                    widget.email
                                                ? 5.0
                                                : 18.0),
                                            horizontal: (crypto.decrypt(
                                                        data[index]["by"]) ==
                                                    widget.email
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
                                                            widget.email
                                                        ? CachedNetworkImage(
                                                            imageUrl: crypto
                                                                        .decrypt(userData[
                                                                            'pic'])
                                                                        .length ==
                                                                    0
                                                                ? global.driveUrl +
                                                                    "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                                : crypto.decrypt(
                                                                    userData[
                                                                        'pic']),
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
                                                            imageUrl: crypto
                                                                        .decrypt(otherUserData[
                                                                            'pic'])
                                                                        .length ==
                                                                    0
                                                                ? global.driveUrl +
                                                                    "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                                : crypto.decrypt(
                                                                    otherUserData[
                                                                        'pic']),
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
                                                              widget.email
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
                                                            widget.email
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
                                                    widget.email
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
                                    key: _formKey,
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
                                                primaryColor: Theme.of(context)
                                                    .primaryColor,
                                                backgroundColor:
                                                    themeProvider.isDarkTheme
                                                        ? Colors.grey[900]
                                                        : Colors.white,
                                                calendarTextColor:
                                                    !themeProvider.isDarkTheme
                                                        ? Colors.grey[900]
                                                        : Colors.white,
                                                tabTextColor:
                                                    !themeProvider.isDarkTheme
                                                        ? Colors.grey[900]
                                                        : Colors.white,
                                                unselectedTabBackgroundColor:
                                                    Colors.grey[700],
                                                buttonTextColor:
                                                    !themeProvider.isDarkTheme
                                                        ? Colors.grey[900]
                                                        : Colors.white,
                                                timeSpinnerTextStyle: TextStyle(
                                                    color: !themeProvider
                                                            .isDarkTheme
                                                        ? Colors.grey[900]
                                                        : Colors.white70,
                                                    fontSize: 18),
                                                timeSpinnerHighlightedTextStyle:
                                                    TextStyle(
                                                        color: !themeProvider
                                                                .isDarkTheme
                                                            ? Colors.grey[900]
                                                            : Colors.white,
                                                        fontSize: 24),
                                                is24HourMode: false,
                                                isShowSeconds: false,
                                                startInitialDate: expenseDate,
                                                startFirstDate: DateTime(2018),
                                                startLastDate: DateTime.now(),
                                                borderRadius:
                                                    const Radius.circular(16),
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
                                          Navigator.pop(context);
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
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
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
            : null);
  }
}
