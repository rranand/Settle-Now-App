import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../contents.dart' as global;
import '../models/ChartData.dart';
import '../others/themes.dart';
import 'package:share_plus/share_plus.dart';

class RoomExpense extends StatefulWidget {
  final String roomKey;
  final String email;
  final String roomName;
  final String token;
  final String roomLink;
  final bool isRoomActive;

  const RoomExpense(
      {Key? key,
      required this.roomKey,
      required this.email,
      required this.roomName,
      required this.token,
      required this.roomLink,
      required this.isRoomActive})
      : super(key: key);

  @override
  _RoomExpenseState createState() => _RoomExpenseState();
}

class _RoomExpenseState extends State<RoomExpense>
    with SingleTickerProviderStateMixin {
  List<dynamic> list = [];
  List<dynamic> allExpenseList = [];
  List<dynamic> TransList = [];
  List<FriendEach> friendData = [];
  List<dynamic> allTransactionData = [];
  int dash = 0;
  bool locked = false;
  final TextEditingController _amt = TextEditingController();
  final TextEditingController _searchFriend = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool isClear = false;
  bool loaded = false;
  bool loadFriendData = false;
  double heightExpense = 0;
  String paymentTotalALL = "";
  bool paidTransactionData = false;
  final _formKey = GlobalKey<FormState>();
  bool showExpenseYouAreIn = false;
  String yourExpense = "";
  double totalExpense = 0;
  List<ChartData> dataMap = [];
  List<ChartData> dataMapByUser = [];

  String expenseTitle = "All Expense";
  List<String> membersListName = [];
  List<String> membersListEmail = [];
  int membersListIndex = 0;
  int membersListIndexS = 0;
  int membersListIndexR = 1;
  bool defaultPage = true;
  bool payment = false;
  String paymentTotal = "";
  bool isLoadedDef = false;
  List<dynamic> paymentData = [];
  List<FriendEach> friendDataSearched = [];
  bool showAllTransactionData = true;
  ScrollController _scrollController = ScrollController();
  List<String> addExpenseTo = [];
  List<dynamic> roomExpenseCategory = [];
  int roomExpenseCategoryIndex = 0;
  List<dynamic> filterResult = [];
  double totalAmount = 0;

  Future<void> initChart() async {
    Map<String, double> tempMap = {};
    for (int i = 0; i < roomExpenseCategory.length; i++) {
      tempMap[roomExpenseCategory[i]] = 0;
    }
    totalAmount = 0;

    for (int i = 0; i < TransList.length; i++) {
      tempMap[crypto.decrypt(TransList[i]["Type"])] =
          (tempMap[crypto.decrypt(TransList[i]["Type"])]! +
              double.parse(crypto.decrypt(TransList[i]["Amount"])));
    }

    for (int i = 0; i < roomExpenseCategory.length; i++) {
      totalAmount += tempMap[roomExpenseCategory[i]]!;
      dataMap.add(ChartData.byType(
          roomExpenseCategory[i], tempMap[roomExpenseCategory[i]]!));
    }
  }

  Future<void> _getPaymentData() async {
    paidTransactionData = false;
    if (this.mounted) {
      setState(() {});
    }
    try {
      final response = await http.delete(
          Uri.parse(global.url + 'transaction/all'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(widget.roomKey),
            'email': crypto.encrypt(widget.email),
          }));

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        allTransactionData.clear();
        allTransactionData = data['data'];
        paymentTotalALL = crypto.decrypt(data['total']);
        paidTransactionData = true;
      } else {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future _initialisation() async {
    if (this.mounted) {
      setState(() {
        heightExpense = 0;
        loaded = false;
        allExpenseList.clear();
        TransList.clear();
        totalExpense = 0;
        list.clear();
        roomExpenseCategory.clear();
        membersListName.clear();
        membersListEmail.clear();
        dataMapByUser.clear();
        dataMap.clear();
      });
    }

    try {
      final response = await http.patch(Uri.parse(global.url + 'data'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(widget.roomKey),
            'email': crypto.encrypt(widget.email),
          }));

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        list = data['data'];
        roomExpenseCategory = data['roomExpenseCategory'];

        for (int i = 0; i < roomExpenseCategory.length; i++) {
          roomExpenseCategory[i] = crypto.decrypt(roomExpenseCategory[i]);
        }

        isClear = list[0]["done"];

        for (int i = 1; i < list.length; i++) {
          membersListName.add(crypto.decrypt(list[i]["Name"]));
          membersListEmail.add(crypto.decrypt(list[i]["email"]));
          dataMapByUser.add(ChartData.byUser(
              crypto.decrypt(list[i]["Name"]),
              crypto.decrypt(list[i]["email"]),
              crypto.decrypt(list[i]["pic"]),
              double.parse(crypto.decrypt(list[i]["yourExpense"]))));
          totalExpense += double.parse(crypto.decrypt(list[i]["Expense"])) +
              double.parse(crypto.decrypt(list[i]["TotalSplitExpense"]));
          if (crypto.decrypt(list[i]["email"]) == widget.email) {
            yourExpense = crypto.decrypt(list[i]["yourExpense"]);
            if (list[i]["done"]) {
              locked = true;
            }
          }
        }

        if (widget.email == membersListEmail[0]) {
          membersListIndex = 1;
        }

        if (this.mounted) {
          setState(() {});
        }
      } else if (jsonDecode(response.body)['maintenance'] != null &&
          jsonDecode(response.body)['maintenance']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Maintenance()),
          (Route<dynamic> route) => false,
        );
      } else {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
      }
    }
  }

  Future<void> getFriendData() async {
    if (!widget.isRoomActive) {
      return null;
    }

    try {
      if (this.mounted) {
        setState(() {
          loadFriendData = false;
          friendData.clear();
        });
      }
      final response = await http.patch(Uri.parse(global.url + 'friend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(widget.roomKey),
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
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
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

  Future<void> _extractExpenseData() async {
    try {
      final response = await http.post(Uri.parse(global.url + 'transaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'roomKey': crypto.encrypt(widget.roomKey),
          }));

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        if (TransData != null) {
          allExpenseList = jsonDecode(response.body)['data'];
          TransList = jsonDecode(response.body)['data'];
        }
      } else {
        showToast(context, crypto.decrypt(TransData["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }

    heightExpense =
        30 + allExpenseList.length * 125 + (allExpenseList.length - 1) * 5;

    if (this.mounted) {
      setState(() {});
    }
  }

  AddExpense(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var Tdata = null;
      buildShowDialog(context);

      try {
        final response = await http.delete(Uri.parse(global.url + 'data'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': widget.token
            },
            body: jsonEncode({
              'email': crypto.encrypt(widget.email),
              'roomKey': crypto.encrypt(widget.roomKey),
              'purpose': crypto.encrypt(_purpose.text),
              'amt': crypto.encrypt(_amt.text),
              'type':
                  crypto.encrypt(roomExpenseCategory[roomExpenseCategoryIndex]),
              "members": crypto.encrypt(addExpenseTo.toString())
            }));

        _amt.text = "";
        _purpose.text = "";
        Tdata = jsonDecode(response.body);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        _refreshIndicatorKey.currentState?.show();

        if (response.statusCode == 422) {
          showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
        }
      } on Exception catch (_) {
        Navigator.pop(context);
        await onException(context);
      }
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  PayToMember(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var Tdata = null;
      buildShowDialog(context);

      try {
        final response = await http.put(Uri.parse(global.url + 'data'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': widget.token
            },
            body: jsonEncode({
              'emailS': crypto.encrypt(widget.email),
              'emailR': crypto.encrypt(membersListEmail[membersListIndex]),
              'roomKey': crypto.encrypt(widget.roomKey),
              'amt': crypto.encrypt(_amt.text),
            }));

        _amt.text = "";
        Tdata = jsonDecode(response.body);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        _refreshIndicatorKey.currentState?.show();

        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.check);
      } on Exception catch (_) {
        Navigator.pop(context);
        await onException(context);
      }
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  retrievePaymentData() async {
    try {
      if (membersListIndexS == membersListIndexR) {
        showToast(context, "Same User", Icons.close);
      } else {
        paymentData.clear();
        if (this.mounted) {
          setState(() {
            isLoadedDef = true;
            payment = true;
          });
        }
        final response = await http.delete(
            Uri.parse(global.url + 'transaction'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': widget.token
            },
            body: jsonEncode({
              'emailS': crypto.encrypt(membersListEmail[membersListIndexS]),
              'emailR': crypto.encrypt(membersListEmail[membersListIndexR]),
              'roomKey': crypto.encrypt(widget.roomKey),
            }));

        if (response.statusCode == 200) {
          paymentData = jsonDecode(response.body)["data"];
          paymentTotal = crypto.decrypt(jsonDecode(response.body)["total"]);
          payment = false;
          showAllTransactionData = false;
          if (this.mounted) {
            setState(() {});
          }
        } else {
          showToast(
              context,
              crypto.decrypt(jsonDecode(response.body)["Message"]),
              Icons.close);
        }
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  CloseRoom(BuildContext context) async {
    buildShowDialog(context);
    try {
      var CloseData = null;
      final response = await http.delete(Uri.parse(global.url + 'room'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'roomKey': crypto.encrypt(widget.roomKey),
          }));
      isClear = true;
      CloseData = jsonDecode(response.body);
      showToast(context, crypto.decrypt(CloseData["Message"]), Icons.check);
      Navigator.pop(context);
      _refreshIndicatorKey.currentState?.show();
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
                            child: OutlinedButton(
                              onPressed: () {
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
                                "No",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                buildShowDialog(context);
                                await CloseRoom(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ))));
  }

  Future<void> executeParallel() async {
    await Future.wait([
      _initialisation(),
      _extractExpenseData(),
      _getPaymentData(),
      getFriendData(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    executeParallel();
  }

  Widget addFriendWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.all(15.0),
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
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (this.mounted) {
                                setState(() {
                                  loadFriendData = false;
                                });
                                await getFriendData();
                                setState(() {
                                  loadFriendData = true;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.refresh_outlined,
                              size: 26,
                            )),
                        IconButton(
                            onPressed: () async {
                              await Share.share("Join " +
                                  widget.roomName +
                                  "\nRoom Key: " +
                                  widget.roomKey +
                                  "\n" +
                                  widget.roomLink);
                            },
                            icon: Icon(
                              Icons.send,
                              size: 26,
                            )),
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
                                  if (this.mounted) {
                                    setState(() {
                                      _searchFriend.text = s;
                                      _searchFriend.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  _searchFriend.text.length);
                                    });
                                  }
                                  SearchFriend();
                                },
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              SingleChildScrollView(
                                child: SizedBox(
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
                                          : friendListWidget(
                                              context, friendDataSearched)),
                                ),
                              ),
                            ],
                          )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height - 310,
                        child: Shimmer.fromColors(
                            baseColor: Theme.of(context).cardColor,
                            highlightColor: Theme.of(context).primaryColor,
                            child: Column(
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
                                    if (this.mounted) {
                                      setState(() {
                                        _searchFriend.text = s;
                                        _searchFriend.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _searchFriend.text.length);
                                      });
                                    }
                                    SearchFriend();
                                  },
                                ),
                                SizedBox(
                                  height: 13,
                                ),
                                SingleChildScrollView(
                                  child: SizedBox(
                                      height: 500,
                                      child: ListView.separated(
                                          separatorBuilder: (context, index) =>
                                              SizedBox(
                                                height: 5,
                                              ),
                                          shrinkWrap: true,
                                          itemCount: 16,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.white,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                            width: 45,
                                                            height: 45,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/Images/unknown.jpeg'),
                                                                  fit: BoxFit
                                                                      .cover),
                                                            )),
                                                        Container(
                                                          width: 200,
                                                          height: 15.0,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        Icon(Icons.person_add)
                                                      ]),
                                                ),
                                              ),
                                            );
                                          })),
                                ),
                              ],
                            )))
              ],
            )));
  }

  sendJoinRequest(String email) async {
    buildShowDialog(context);
    try {
      final response = await http.post(Uri.parse(global.url + 'friend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(widget.roomKey),
            'email': crypto.encrypt(widget.email),
            'fEmail': crypto.encrypt(email)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (_) {
      await onException(context);
    }
    Navigator.pop(context);
  }

  keepAlive() async {
    await http.get(
      Uri.parse(global.url + 'login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  cancelJoinRequest(String email) async {
    buildShowDialog(context);
    try {
      final response = await http.put(Uri.parse(global.url + 'friend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(widget.roomKey),
            'email': crypto.encrypt(email),
            'confirm': crypto.encrypt("0")
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (_) {
      await onException(context);
    }
    Navigator.pop(context);
  }

  closeRoomRequest() async {
    try {
      final response = await http.put(Uri.parse(global.url + 'transaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(widget.roomKey),
            'email': crypto.encrypt(widget.email)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (_) {
      await onException(context);
    }
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
                              CachedNetworkImage(
                                imageUrl: data[index].pic.length == 0
                                    ? global.driveUrl +
                                        "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                    : data[index].pic,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Container(
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
                              Text(
                                data[index].name,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    if (data[index].status == "NJ") {
                                      await sendJoinRequest(data[index].email);
                                      data[index].status = "S";
                                    } else {
                                      await cancelJoinRequest(
                                          data[index].email);
                                      data[index].status = "NJ";
                                    }

                                    await keepAlive();
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

  Widget memberCard(BuildContext context, int index) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () async {
            TransList.clear();
            allExpenseList.forEach((element) {
              if (crypto.decrypt(list[index]['email']) ==
                  crypto.decrypt(element['Email'])) {
                TransList.add(element);
              }
            });

            expenseTitle = crypto.decrypt(list[index]['Name']) + "\'s Expense";
            if (this.mounted) {
              setState(() {});
            }

            if (showExpenseYouAreIn) {
              getFilterData();
            }
          },
          child: Card(
            elevation: 1.0,
            shadowColor: Theme.of(context).primaryColor,
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: list[index]['done']
                ? RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(15.0),
                  )
                : RoundedRectangleBorder(
                    side: BorderSide(
                        color: Theme.of(context).primaryColor.withAlpha(90)),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CachedNetworkImage(
                      imageUrl: crypto.decrypt(list[index]['pic']).length == 0
                          ? global.driveUrl +
                              "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                          : crypto.decrypt(list[index]['pic']),
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) => Container(
                        width: 65.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/Images/unknown.jpeg'),
                              fit: BoxFit.cover),
                        ),
                      ),
                      imageBuilder: (context, imageProvider) => Container(
                        width: 65.0,
                        height: 65.0,
                        decoration: BoxDecoration(
                          border: list[index]['own']
                              ? Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 3.4)
                              : null,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          child: Text(
                            crypto.decrypt(list[index]['Name']),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              foreground: Paint()..shader = linearGradient_1,
                            ),
                          ),
                          onTap: () => showToast(context,
                              crypto.decrypt(list[index]['Name']), Icons.check),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Contribution : ₹ " +
                              commaSeperator((double.parse(crypto
                                          .decrypt(list[index]['Expense'])) +
                                      double.parse(crypto.decrypt(
                                          list[index]['TotalSplitExpense'])))
                                  .toStringAsFixed(2)),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            foreground: Paint()..shader = linearGradient_2,
                          ),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                            "Spent : ₹ " +
                                commaSeperator((double.parse(crypto
                                        .decrypt(list[index]["yourExpense"])))
                                    .toStringAsFixed(2)),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              foreground: Paint()..shader = linearGradient_2,
                            )),
                        SizedBox(
                          height: 3,
                        ),
                        double.parse(double.parse(
                                        crypto.decrypt(list[index]["current"]))
                                    .toStringAsFixed(2)) >
                                0
                            ? Text(
                                "Gain : ₹ " +
                                    commaSeperator(double.parse(crypto
                                            .decrypt(list[index]["current"]))
                                        .toStringAsFixed(2)),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              )
                            : double.parse(double.parse(crypto
                                            .decrypt(list[index]["current"]))
                                        .toStringAsFixed(2)) <
                                    0
                                ? Text(
                                    "Owe : ₹ " +
                                        commaSeperator(double.parse(
                                                crypto.decrypt(
                                                    list[index]["current"]))
                                            .toStringAsFixed(2)),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  )
                                : SizedBox()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool findElement(List<String> arr, String ele) {
    for (int i = 0; i < arr.length; i++) {
      if (arr[i] == ele) {
        return true;
      }
    }

    return false;
  }

  Widget memberExpenseCard(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: (membersListIndex + 1) == index
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: crypto.decrypt(list[index]['pic']).length == 0
                    ? global.driveUrl + "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                    : crypto.decrypt(list[index]['pic']),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage('assets/Images/unknown.jpeg'),
                        fit: BoxFit.cover),
                  ),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
              Text(
                crypto.decrypt(list[index]['Name']),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget memberExpenseAll(BuildContext context) {
    return SizedBox(
      width: 85,
      child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Card(
              elevation: 1.4,
              shadowColor: Theme.of(context).primaryColor,
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "ALL",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  )))),
    );
  }

  getFilterData() async {
    if (this.mounted) {
      setState(() {
        filterResult.clear();
      });
    }

    TransList.forEach((element) {
      List<dynamic> partialExpense = element["members"];
      if (partialExpense.isEmpty) {
        filterResult.add(element);
      } else {
        for (int i = 0; i < partialExpense.length; i++) {
          if (crypto.decrypt(partialExpense[i]['Email']) == widget.email) {
            filterResult.add(element);
            break;
          }
        }
      }
    });

    if (this.mounted) {
      setState(() {});
    }
  }

  Widget memberAll(BuildContext context) {
    return SizedBox(
        width: 140,
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () async {
                  TransList.clear();
                  expenseTitle = "All Expense";
                  TransList.addAll(allExpenseList);

                  if (this.mounted) {
                    setState(() {});
                  }

                  if (showExpenseYouAreIn) {
                    getFilterData();
                  }
                },
                child: Card(
                    elevation: 1.0,
                    shadowColor: Theme.of(context).primaryColor,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(context).primaryColor.withAlpha(90)),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "ALL",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()..shader = linearGradient_4,
                            ),
                          ),
                        ))))));
  }

  Widget homeWidget() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return list.isEmpty
        ? ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).cardColor,
                    highlightColor: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text("Room Key"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          ListTile(
                            title: Text("Total Spent"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          ListTile(
                            title: Text("You Spent"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          ListTile(
                            title: Text("Members"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          ListTile(
                            title: Text("Created On"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Member",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 140,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: 4,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 170,
                                              width: 140,
                                              child: Center(
                                                  child: Text("All",
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ))),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                          );
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 170,
                                              width: 260,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
                                                      width: 65.0,
                                                      height: 65.0,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                'assets/Images/unknown.jpeg'),
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 150,
                                                          height: 18.0,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          width: 130,
                                                          height: 16,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          width: 130,
                                                          height: 16,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          width: 130,
                                                          height: 16,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Show Expenses You Are In",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        showExpenseYouAreIn
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
                                        size: 40,
                                        color: showExpenseYouAreIn
                                            ? Theme.of(context).primaryColor
                                            : null,
                                      )
                                    ],
                                  ),
                                  Divider(),
                                  Text(
                                    expenseTitle,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 135,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 200,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 150,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 120,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 170,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 100,
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
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 50,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    )),
              )
            ],
          )
        : NestedScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            headerSliverBuilder: (context, value) {
              return [
                SliverToBoxAdapter(
                  child: InkWell(
                    onTap: () async {
                      await Share.share("Join " +
                          widget.roomName +
                          "\nRoom Key: " +
                          widget.roomKey +
                          "\n" +
                          widget.roomLink);
                    },
                    onLongPress: () async {
                      Clipboard.setData(ClipboardData(text: widget.roomKey));
                      showToast(context, "Join Key Copied", Icons.check);
                    },
                    child: ListTile(
                      title: Text("Room Key   "),
                      trailing: Text(widget.roomKey),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    title: const Text("Total Spent"),
                    trailing: Text(
                        "₹ " + commaSeperator(totalExpense.toStringAsFixed(2))),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    title: const Text("You Spent"),
                    trailing: Text("₹ " + commaSeperator(yourExpense)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    title: const Text("Members"),
                    trailing: Text(crypto.decrypt(list[0]["cnt"])),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    title: const Text("Created On"),
                    trailing:
                        Text(formatDateTime(crypto.decrypt(list[0]["date"]))),
                  ),
                ),
                SliverToBoxAdapter(
                  child: !isClear
                      ? Padding(
                          padding: EdgeInsets.all(15.0),
                          child: SizedBox(
                            height: 45,
                            child: OutlinedButton(
                              child: Text(
                                "Close Room",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      closeRoomWidget(context),
                                );
                              },
                            ),
                          ),
                        )
                      : SizedBox(),
                ),
                SliverToBoxAdapter(child: const Divider()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Member",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return memberAll(context);
                              } else {
                                return memberCard(context, index);
                              }
                            },
                          ),
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Show Expenses You Are In",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  showExpenseYouAreIn = !showExpenseYouAreIn;
                                  getFilterData();
                                },
                                icon: Icon(
                                  showExpenseYouAreIn
                                      ? Icons.toggle_on
                                      : Icons.toggle_off,
                                  size: 40,
                                  color: showExpenseYouAreIn
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ))
                          ],
                        ),
                        Divider(),
                        Text(
                          expenseTitle,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ];
            },
            body: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: executeParallel,
              child: allExpenseList.isEmpty
                  ? Center(
                      child: loaded
                          ? Text(
                              "No Expense Found",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          : CircularProgressIndicator())
                  : (showExpenseYouAreIn
                      ? ExpenseData(
                          TransList: filterResult,
                          RoomKey: widget.roomKey,
                          Email: widget.email,
                          Token: widget.token,
                          refreshIndicatorKey: _refreshIndicatorKey,
                          locked: locked,
                        )
                      : ExpenseData(
                          TransList: TransList,
                          RoomKey: widget.roomKey,
                          Email: widget.email,
                          Token: widget.token,
                          refreshIndicatorKey: _refreshIndicatorKey,
                          locked: locked,
                        )),
            ),
          );
  }

  Widget paymentDataWidget() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Text(
                "From",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 65,
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length - 1,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Card(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: membersListEmail[index] ==
                                      membersListEmail[membersListIndexS]
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CachedNetworkImage(
                                imageUrl: crypto
                                            .decrypt(list[index + 1]['pic'])
                                            .length ==
                                        0
                                    ? global.driveUrl +
                                        "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                    : crypto.decrypt(list[index + 1]['pic']),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) => Container(
                                  width: 50.0,
                                  height: 50.0,
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
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Text(
                                crypto.decrypt(list[index + 1]['Name']),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        if (this.mounted) {
                          setState(() {
                            membersListIndexS = index;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "To",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 45,
                  height: 65,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length - 1,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          child: Card(
                            elevation: 1.4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: membersListEmail[index] ==
                                          membersListEmail[membersListIndexR]
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).cardColor),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: crypto
                                                .decrypt(list[index + 1]['pic'])
                                                .length ==
                                            0
                                        ? global.driveUrl +
                                            "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                        : crypto
                                            .decrypt(list[index + 1]['pic']),
                                    progressIndicatorBuilder: (context, url,
                                            downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 50.0,
                                      height: 50.0,
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
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    crypto.decrypt(list[index + 1]['Name']),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          onTap: () {
                            if (this.mounted) {
                              setState(() {
                                membersListIndexR = index;
                              });
                            }
                          },
                        );
                      })),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 45,
            width: 100,
            child: OutlinedButton(
              child: Text(
                "Search",
                style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : Colors.black),
              ),
              onPressed: () {
                retrievePaymentData();
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Scrollbar(
            radius: Radius.circular(10.0),
            thickness: 5.5,
            child: showAllTransactionData
                ? (paidTransactionData
                    ? (allTransactionData.isEmpty
                        ? Center(
                            child: Text(
                              "No Results Found!!!",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Total Amount Paid: ₹ " +
                                    commaSeperator(double.parse(paymentTotalALL)
                                        .toStringAsFixed(2)),
                              ),
                              SingleChildScrollView(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 390,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            SizedBox(
                                              height: 5,
                                            ),
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        itemCount: allTransactionData.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Card(
                                            elevation: 1.0,
                                            shadowColor:
                                                Theme.of(context).primaryColor,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withAlpha(80)),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Text(
                                                      crypto.decrypt(
                                                              allTransactionData[
                                                                      index]
                                                                  ["sender"]) +
                                                          " -> " +
                                                          crypto.decrypt(
                                                              allTransactionData[
                                                                      index]
                                                                  ["receiver"]),
                                                      style: const TextStyle(
                                                        overflow:
                                                            TextOverflow.clip,
                                                        fontSize: 21,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.90,
                                                            child: Opacity(
                                                              opacity: 0.8,
                                                              child: Text(
                                                                crypto.decrypt(
                                                                    allTransactionData[
                                                                            index]
                                                                        [
                                                                        "Date"]),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 0,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.20,
                                                            child: Text(
                                                              "₹ " +
                                                                  commaSeperator(
                                                                      crypto.decrypt(
                                                                          allTransactionData[index]
                                                                              [
                                                                              "Amount"])),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ))
                    : SizedBox(
                        height: MediaQuery.of(context).size.height - 380,
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
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 160,
                                              height: 20.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                            Container(
                                              width: 160,
                                              height: 20.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 180,
                                              height: 17.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                            Container(
                                              width: 120,
                                              height: 17.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ))))
                : (isLoadedDef
                    ? paymentData.isEmpty
                        ? (payment
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 380,
                                child: Shimmer.fromColors(
                                    baseColor: Theme.of(context).cardColor,
                                    highlightColor:
                                        Theme.of(context).primaryColor,
                                    child: ListView.builder(
                                      itemCount: 16,
                                      itemBuilder: (_, __) => Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 18, horizontal: 12),
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 180,
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
                                                Container(
                                                  width: 120,
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
                                            ),
                                          ),
                                        ),
                                      ),
                                    )))
                            : Center(
                                child: Text(
                                  "No Results Found!!!",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ))
                        : Column(children: [
                            Text(
                              "Total Amount Paid: ₹ " +
                                  commaSeperator(double.parse(paymentTotal)
                                      .toStringAsFixed(2)),
                            ),
                            SingleChildScrollView(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 390,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            height: 5,
                                          ),
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemCount: paymentData.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(
                                            height: 70,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Card(
                                              elevation: 1.0,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              shadowColor: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withAlpha(80)),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Opacity(
                                                        opacity: 0.8,
                                                        child: Text(
                                                          formatDateTime(
                                                              crypto.decrypt(
                                                                  paymentData[
                                                                          index]
                                                                      [
                                                                      "Date"])),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        "₹ " +
                                                            commaSeperator(crypto
                                                                .decrypt(paymentData[
                                                                        index][
                                                                    "Amount"])),
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ));
                                      }),
                                ),
                              ),
                            ),
                          ])
                    : SizedBox()),
          )
        ],
      ),
    );
  }

  Widget showChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: loaded
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Expense by Category",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: dataMap.isEmpty
                            ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.3,
                                ),
                              )
                            : SizedBox(
                                height: 50 * roomExpenseCategory.length * 1.0,
                                child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: SfCartesianChart(
                                        primaryXAxis:
                                            CategoryAxis(isVisible: false),
                                        primaryYAxis:
                                            NumericAxis(isVisible: false),
                                        tooltipBehavior: TooltipBehavior(
                                            enable: true,
                                            header: "",
                                            format: "point.x : ₹ point.y"),
                                        plotAreaBorderWidth: 0,
                                        series: <BarSeries<ChartData, String>>[
                                          BarSeries<ChartData, String>(
                                              dataSource: dataMap,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.type,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.amount,
                                              isVisibleInLegend: true,
                                              width: 0.8,
                                              pointColorMapper:
                                                  (ChartData data, _) => Color(
                                                      Random()
                                                          .nextInt(0xffffffff)),
                                              dataLabelMapper: (datum, index) =>
                                                  datum.type +
                                                  "\n₹ " +
                                                  datum.amount
                                                      .toStringAsFixed(2),
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: true),
                                              xAxisName: "Category",
                                              yAxisName: "Amount")
                                        ])),
                              ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Expense by User",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                        child: dataMapByUser.isEmpty
                            ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.3,
                                ),
                              )
                            : SizedBox(
                                height: 53 * membersListEmail.length * 1.0,
                                child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: SfCartesianChart(
                                        primaryXAxis:
                                            CategoryAxis(isVisible: false),
                                        primaryYAxis:
                                            NumericAxis(isVisible: false),
                                        tooltipBehavior: TooltipBehavior(
                                            enable: true,
                                            header: "",
                                            format: "point.x : ₹ point.y"),
                                        plotAreaBorderWidth: 0,
                                        series: <BarSeries<ChartData, String>>[
                                          BarSeries<ChartData, String>(
                                              dataSource: dataMapByUser,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              width: 0.8,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.name,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.amount,
                                              isVisibleInLegend: true,
                                              pointColorMapper:
                                                  (ChartData data, _) => Color(
                                                      Random()
                                                          .nextInt(0xffffffff)),
                                              dataLabelMapper: (datum, index) =>
                                                  datum.name +
                                                  "\n₹ " +
                                                  datum.amount
                                                      .toStringAsFixed(2),
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: true),
                                              xAxisName: "User",
                                              yAxisName: "Amount")
                                        ])),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }

  Widget chooseFromBottomNavigator(int dash) {
    if (widget.isRoomActive) {
      if (dash == 0) {
        return homeWidget();
      } else if (dash == 1) {
        return addFriendWidget();
      } else if (dash == 2) {
        initChart();
        return showChart();
      } else {
        return paymentDataWidget();
      }
    } else {
      if (dash == 0) {
        return homeWidget();
      } else if (dash == 1) {
        initChart();
        return showChart();
      } else {
        return paymentDataWidget();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.roomName),
        ),
        body: chooseFromBottomNavigator(dash),
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: dash,
            onTap: (index) => setState(() {
                  dash = index;
                }),
            items: widget.isRoomActive
                ? [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                        size: 27,
                      ),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.person_add,
                        size: 27,
                      ),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.analytics_outlined,
                        size: 27,
                      ),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.transfer_within_a_station_rounded,
                        size: 27,
                      ),
                      label: "",
                    )
                  ]
                : [
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.home,
                        size: 27,
                      ),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.analytics_outlined,
                        size: 27,
                      ),
                      label: "",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        Icons.transfer_within_a_station_rounded,
                        size: 27,
                      ),
                      label: "",
                    )
                  ]),
        floatingActionButton: dash == 0
            ? (widget.isRoomActive
                ? FloatingActionButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    child: Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: SizedBox(
                                        height:
                                            isClear ? 60 : (locked ? 120 : 170),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  Icons.close,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                title: const Text(
                                                    "Close Room Request"),
                                                onTap: () async {
                                                  buildShowDialog(context);
                                                  await closeRoomRequest();
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              !isClear
                                                  ? ListTile(
                                                      leading: Icon(
                                                        Icons.money,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      title: const Text(
                                                          "Pay to Member"),
                                                      onTap: () {
                                                        if (membersListName
                                                                .length <=
                                                            1) {
                                                          showToast(
                                                              context,
                                                              "More Than One Member Required",
                                                              Icons.close);
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return StatefulBuilder(
                                                                    builder:
                                                                        (context,
                                                                            setState) {
                                                                  return Dialog(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              12.0)),
                                                                      child:
                                                                          Container(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.9,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(18.0),
                                                                          child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              children: [
                                                                                Text(
                                                                                  "Pay to Member",
                                                                                  style: TextStyle(fontSize: 22),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Form(
                                                                                  key: _formKey,
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: <Widget>[
                                                                                      SizedBox(
                                                                                        width: MediaQuery.of(context).size.width * 0.8,
                                                                                        height: 80,
                                                                                        child: ListView.builder(
                                                                                          scrollDirection: Axis.horizontal,
                                                                                          itemCount: list.length - 1,
                                                                                          itemBuilder: (BuildContext context, int index) {
                                                                                            if (membersListEmail[index] == widget.email) {
                                                                                              return SizedBox();
                                                                                            } else {
                                                                                              return InkWell(
                                                                                                child: memberExpenseCard(context, index + 1),
                                                                                                onTap: () {
                                                                                                  if (this.mounted) {
                                                                                                    setState(
                                                                                                      () {
                                                                                                        membersListIndex = index;
                                                                                                      },
                                                                                                    );
                                                                                                  }
                                                                                                },
                                                                                              );
                                                                                            }
                                                                                          },
                                                                                        ),
                                                                                      ),
                                                                                      TextFormField(
                                                                                        controller: _amt,
                                                                                        keyboardType: TextInputType.number,
                                                                                        maxLength: 10,
                                                                                        maxLines: 1,
                                                                                        style: const TextStyle(fontSize: 18),
                                                                                        autocorrect: false,
                                                                                        validator: (value) {
                                                                                          RegExp validateNumber = RegExp(r'\b[1-9]{1}[\d]*\b');
                                                                                          if (!validateNumber.hasMatch(_amt.text)) {
                                                                                            return "Enter Valid Amount";
                                                                                          }
                                                                                          return null;
                                                                                        },
                                                                                        decoration: const InputDecoration(
                                                                                          contentPadding: EdgeInsets.all(8.0),
                                                                                          counterText: "",
                                                                                          hintText: "Enter Amount",
                                                                                          labelText: "Amount",
                                                                                          errorStyle: TextStyle(fontSize: 15),
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 10,
                                                                                      ),
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            SizedBox(
                                                                                              height: 40,
                                                                                              width: 100,
                                                                                              child: OutlinedButton(
                                                                                                  style: OutlinedButton.styleFrom(
                                                                                                    shape: RoundedRectangleBorder(
                                                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                                                    ),
                                                                                                    side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    "Close",
                                                                                                    style: TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                                                  ),
                                                                                                  onPressed: () {
                                                                                                    Navigator.pop(context);
                                                                                                  }),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 40,
                                                                                              width: 100,
                                                                                              child: OutlinedButton(
                                                                                                  style: OutlinedButton.styleFrom(
                                                                                                    shape: RoundedRectangleBorder(
                                                                                                      borderRadius: BorderRadius.circular(10.0),
                                                                                                    ),
                                                                                                    side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    "Add",
                                                                                                    style: TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                                                  ),
                                                                                                  onPressed: () {
                                                                                                    PayToMember(context);
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: 10,
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ]),
                                                                        ),
                                                                      ));
                                                                });
                                                              });
                                                        }
                                                      })
                                                  : SizedBox(),
                                              !(isClear || locked)
                                                  ? ListTile(
                                                      leading: Icon(
                                                        Icons.add,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      title: const Text(
                                                          "Add Expense"),
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                return Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12.0)),
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.9,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          18.0),
                                                                      child: Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Text(
                                                                              "Add Expense",
                                                                              style: TextStyle(fontSize: 22),
                                                                            ),
                                                                            SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Form(
                                                                              key: _formKey,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: <Widget>[
                                                                                  TextFormField(
                                                                                    controller: _amt,
                                                                                    keyboardType: TextInputType.number,
                                                                                    maxLength: 10,
                                                                                    maxLines: 1,
                                                                                    style: const TextStyle(fontSize: 18),
                                                                                    autocorrect: false,
                                                                                    validator: (value) {
                                                                                      RegExp validateNumber = RegExp(r'\b[1-9]{1}[\d]*\b');
                                                                                      if (!validateNumber.hasMatch(_amt.text)) {
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
                                                                                  TextFormField(
                                                                                    controller: _purpose,
                                                                                    keyboardType: TextInputType.text,
                                                                                    maxLength: 150,
                                                                                    maxLines: 1,
                                                                                    style: const TextStyle(fontSize: 18),
                                                                                    autocorrect: false,
                                                                                    validator: (value) {
                                                                                      RegExp validateText = RegExp(r'\b[\w]+\b');
                                                                                      if (!validateText.hasMatch(_purpose.text)) {
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
                                                                                    width: MediaQuery.of(context).size.width * 0.9,
                                                                                    height: 70,
                                                                                    child: ListView.builder(
                                                                                      scrollDirection: Axis.horizontal,
                                                                                      itemCount: roomExpenseCategory.length,
                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                        return SizedBox(
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.all(8.0),
                                                                                            child: InkWell(
                                                                                              child: Card(
                                                                                                color: Theme.of(context).dialogBackgroundColor,
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  side: BorderSide(color: roomExpenseCategoryIndex == index ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
                                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.all(12.0),
                                                                                                  child: Center(
                                                                                                    child: InkWell(
                                                                                                      child: Text(
                                                                                                        roomExpenseCategory[index],
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 16,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              onTap: () {
                                                                                                if (this.mounted) {
                                                                                                  setState(
                                                                                                    () {
                                                                                                      roomExpenseCategoryIndex = index;
                                                                                                    },
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 80,
                                                                                    child: ListView.builder(
                                                                                      scrollDirection: Axis.horizontal,
                                                                                      itemCount: list.length,
                                                                                      itemBuilder: (BuildContext context, int index) {
                                                                                        if (index == 0) {
                                                                                          return InkWell(
                                                                                            child: SizedBox(
                                                                                              width: 85,
                                                                                              child: Padding(
                                                                                                  padding: EdgeInsets.all(8.0),
                                                                                                  child: Card(
                                                                                                      color: Theme.of(context).dialogBackgroundColor,
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                        side: BorderSide(color: addExpenseTo.isEmpty ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
                                                                                                        borderRadius: BorderRadius.circular(15.0),
                                                                                                      ),
                                                                                                      child: Padding(
                                                                                                          padding: const EdgeInsets.all(8.0),
                                                                                                          child: Center(
                                                                                                            child: Text(
                                                                                                              "ALL",
                                                                                                              style: TextStyle(
                                                                                                                fontSize: 14,
                                                                                                              ),
                                                                                                            ),
                                                                                                          )))),
                                                                                            ),
                                                                                            onTap: () {
                                                                                              addExpenseTo.clear();
                                                                                              if (this.mounted) {
                                                                                                setState(() {});
                                                                                              }
                                                                                            },
                                                                                          );
                                                                                        } else if (list[index]['done'] || membersListEmail[index - 1] == widget.email) {
                                                                                          return SizedBox();
                                                                                        } else {
                                                                                          return InkWell(
                                                                                            child: Padding(
                                                                                              padding: EdgeInsets.all(8.0),
                                                                                              child: Card(
                                                                                                color: Theme.of(context).dialogBackgroundColor,
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  side: BorderSide(color: findElement(addExpenseTo, membersListEmail[index - 1]) ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
                                                                                                  borderRadius: BorderRadius.circular(15.0),
                                                                                                ),
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.all(5.0),
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                                    children: [
                                                                                                      CachedNetworkImage(
                                                                                                        imageUrl: crypto.decrypt(list[index]['pic']).length == 0 ? global.driveUrl + "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8" : crypto.decrypt(list[index]['pic']),
                                                                                                        progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                                                                                                        errorWidget: (context, url, error) => Container(
                                                                                                          width: 50.0,
                                                                                                          height: 50.0,
                                                                                                          decoration: BoxDecoration(
                                                                                                            shape: BoxShape.circle,
                                                                                                            image: DecorationImage(image: AssetImage('assets/Images/unknown.jpeg'), fit: BoxFit.cover),
                                                                                                          ),
                                                                                                        ),
                                                                                                        imageBuilder: (context, imageProvider) => Container(
                                                                                                          width: 50.0,
                                                                                                          height: 50.0,
                                                                                                          decoration: BoxDecoration(
                                                                                                            shape: BoxShape.circle,
                                                                                                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        crypto.decrypt(list[index]['Name']),
                                                                                                        overflow: TextOverflow.ellipsis,
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 18,
                                                                                                          fontWeight: FontWeight.w500,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            onTap: () {
                                                                                              if (findElement(addExpenseTo, membersListEmail[index - 1])) {
                                                                                                addExpenseTo.remove(membersListEmail[index - 1]);
                                                                                              } else {
                                                                                                addExpenseTo.add(membersListEmail[index - 1]);

                                                                                                if (addExpenseTo.length == membersListEmail.length - 1) {
                                                                                                  addExpenseTo.clear();
                                                                                                }
                                                                                              }

                                                                                              if (this.mounted) {
                                                                                                setState(() {});
                                                                                              }
                                                                                            },
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          height: 43,
                                                                                          width: 100,
                                                                                          child: OutlinedButton(
                                                                                              style: OutlinedButton.styleFrom(
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                                ),
                                                                                                side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                              ),
                                                                                              child: Text(
                                                                                                "Close",
                                                                                                style: TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                Navigator.pop(context);
                                                                                              }),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: 43,
                                                                                          width: 100,
                                                                                          child: OutlinedButton(
                                                                                              child: Text(
                                                                                                "Add",
                                                                                                style: TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                                              ),
                                                                                              style: OutlinedButton.styleFrom(
                                                                                                shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                                                ),
                                                                                                side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                AddExpense(context);
                                                                                              }),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 10,
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ]),
                                                                    ),
                                                                  ),
                                                                );
                                                              });
                                                            });
                                                      })
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                              },
                            );
                          });
                    },
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  )
                : null)
            : null);
  }
}

class ExpenseData extends StatefulWidget {
  final List<dynamic> TransList;
  final String RoomKey;
  final String Email;
  final String Token;
  final bool locked;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  ExpenseData(
      {Key? key,
      required this.TransList,
      required this.RoomKey,
      required this.Email,
      required this.Token,
      required this.refreshIndicatorKey,
      required this.locked})
      : super(key: key);

  @override
  State<ExpenseData> createState() => _ExpenseDataState();
}

class _ExpenseDataState extends State<ExpenseData> {
  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final _updateExpense = GlobalKey<FormState>();

  _updateTransaction(BuildContext context, String purpose, String id,
      String amount, String flag, String split) async {
    try {
      final response = await http.patch(Uri.parse(global.url + 'transaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.Token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.Email),
            'roomKey': crypto.encrypt(widget.RoomKey),
            'purpose': crypto.encrypt(purpose),
            'amount': crypto.encrypt(amount),
            'id': crypto.encrypt(id),
            'flag': crypto.encrypt(flag),
            'split': crypto.encrypt(split)
          }));

      var updateMessage = jsonDecode(response.body);
      showToast(context, crypto.decrypt(updateMessage["Message"]), Icons.check);
      widget.refreshIndicatorKey.currentState?.show();
    } on Exception catch (_) {
      await onException(context);
    }
  }

  Widget _buildUpdateDialog(BuildContext context, String id, String purpose,
      String amount, String split) {
    return StatefulBuilder(builder: (context, setState) {
      _purpose.text = purpose;
      _amount.text = amount;

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
                          TextFormField(
                            controller: _amount,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateNumber =
                                  RegExp(r'\b[1-9]{1}[\d]*\b');
                              if (!validateNumber.hasMatch(_amount.text)) {
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
                            controller: _purpose,
                            keyboardType: TextInputType.text,
                            maxLength: 150,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateText = RegExp(r'\b[\w]+\b');
                              if (!validateText.hasMatch(_purpose.text)) {
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
                          SizedBox(
                            height: 43,
                            width: MediaQuery.of(context).size.width * 0.9,
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
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                onPressed: () async {
                                  if (_updateExpense.currentState!.validate()) {
                                    buildShowDialog(context);
                                    await _updateTransaction(
                                        context,
                                        _purpose.text,
                                        id,
                                        _amount.text,
                                        "0",
                                        split);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }
                                }),
                          ),
                        ],
                      ),
                    ))),
          ));
    });
  }

  addToPersonalExpense(String objId, String split) async {
    buildShowDialog(context);
    try {
      final response = await http.post(
          Uri.parse(global.url + 'transaction/personalExpense'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.Token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(widget.RoomKey),
            'email': crypto.encrypt(widget.Email),
            'id': crypto.encrypt(objId),
            'split': crypto.encrypt(split)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (_) {
      await onException(context);
    }
    Navigator.pop(context);
  }

  bool userInPartialExpense(List<dynamic> partialExpense, String email) {
    for (int i = 0; i < partialExpense.length; i++) {
      if (crypto.decrypt(partialExpense[i]['Email']) == email) {
        return true;
      }
    }

    return false;
  }

  Widget _buildPopupDialog(
      BuildContext context,
      String name,
      String date,
      String email,
      String id,
      String purpose,
      String amount,
      bool locked,
      List<dynamic> partialExpense,
      String type) {
    return StatefulBuilder(builder: (context, setState) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Expense Detail",
                      style: TextStyle(fontSize: 23),
                    ),
                    widget.Email == email && !locked
                        ? Row(
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    buildShowDialog(context);
                                    await _updateTransaction(
                                        context,
                                        _purpose.text,
                                        id,
                                        _amount.text,
                                        "1",
                                        partialExpense.isEmpty ? "0" : "1");
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.delete)),
                              IconButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          _buildUpdateDialog(
                                              context,
                                              id,
                                              purpose,
                                              amount,
                                              partialExpense.isEmpty
                                                  ? "0"
                                                  : "1"),
                                    );
                                  },
                                  icon: Icon(Icons.edit)),
                            ],
                          )
                        : SizedBox()
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  _purpose.text,
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        partialExpense.isEmpty
                            ? Text(
                                name,
                                style: TextStyle(fontSize: 20),
                              )
                            : SizedBox(),
                        partialExpense.isEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox(),
                        Text(
                          date,
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          type,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      "₹ " + _amount.text,
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                partialExpense.isEmpty
                    ? SizedBox()
                    : SizedBox(
                        height: 20,
                      ),
                partialExpense.isEmpty
                    ? SizedBox()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width - 65,
                        height: 65,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: partialExpense.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              color: Theme.of(context).dialogBackgroundColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).cardColor),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: crypto
                                                  .decrypt(partialExpense[index]
                                                      ['pic'])
                                                  .length ==
                                              0
                                          ? global.driveUrl +
                                              "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                          : crypto.decrypt(
                                              partialExpense[index]['pic']),
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 50.0,
                                        height: 50.0,
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
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      crypto.decrypt(
                                          partialExpense[index]['Name']),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(
                  height: 25,
                ),
                partialExpense.isEmpty ||
                        userInPartialExpense(partialExpense, widget.Email)
                    ? SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width * 0.95 - 25,
                        child: OutlinedButton(
                          onPressed: () async {
                            buildShowDialog(context);
                            await addToPersonalExpense(
                                id, partialExpense.isEmpty ? "0" : "1");
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
                            "Add To Personal Expense",
                            style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkTheme
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      )
                    : SizedBox(),
                partialExpense.isEmpty ||
                        userInPartialExpense(partialExpense, widget.Email)
                    ? SizedBox(
                        height: 12,
                      )
                    : SizedBox(),
                SizedBox(
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.95 - 25,
                  child: OutlinedButton(
                    child: Text(
                      "Close",
                      style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
                height: 5,
              ),
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: widget.TransList.length,
          itemBuilder: (BuildContext context, int index) {
            List<dynamic> partialExpense = widget.TransList[index]["members"];

            return InkWell(
              onTap: () {
                _purpose.text =
                    crypto.decrypt(widget.TransList[index]["Purpose"]);
                _amount.text =
                    crypto.decrypt(widget.TransList[index]["Amount"]);
                showDialog(
                  context: context,
                  builder: (BuildContext context) => _buildPopupDialog(
                      context,
                      crypto.decrypt(widget.TransList[index]["Name"]),
                      formatDateTime(
                          crypto.decrypt(widget.TransList[index]["Date"])),
                      crypto.decrypt(widget.TransList[index]["Email"]),
                      crypto.decrypt(widget.TransList[index]["id"]),
                      crypto.decrypt(widget.TransList[index]["Purpose"]),
                      crypto.decrypt(widget.TransList[index]["Amount"]),
                      widget.locked,
                      partialExpense,
                      crypto.decrypt(widget.TransList[index]["Type"])),
                );
              },
              child: SizedBox(
                  height: 165,
                  child: Card(
                    elevation: 1.0,
                    shadowColor: Theme.of(context).primaryColor,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(context).primaryColor.withAlpha(80)),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.90,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        crypto.decrypt(
                                            widget.TransList[index]["Purpose"]),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          crypto.decrypt(
                                              widget.TransList[index]["Name"]),
                                          style: const TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          "Split In: " +
                                              (partialExpense.isEmpty
                                                  ? "All"
                                                  : "Partial"),
                                          style: const TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          "Category: " +
                                              crypto.decrypt(widget
                                                  .TransList[index]["Type"]),
                                          style: const TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          formatDateTime(crypto.decrypt(
                                              widget.TransList[index]["Date"])),
                                          style: const TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.20,
                                child: Text(
                                  "₹ " +
                                      crypto.decrypt(
                                          widget.TransList[index]["Amount"]),
                                  style: const TextStyle(
                                    fontSize: 19,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                    ),
                  )),
            );
          }),
    );
  }
}
