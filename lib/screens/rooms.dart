import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;
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

class _RoomExpenseState extends State<RoomExpense> {
  List<dynamic> list = [];
  List<dynamic> TransList = [];
  List<FriendEach> friendData = [];
  List<dynamic> allTransactionData = [];
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

  String expenseTitle = "All Expense";
  String expenseDetailByMember = "all";
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

  _getPaymentData() async {
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
        showToast(context, crypto.decrypt(data["Message"]));
      }
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future _initialisation() async {
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
        list.clear();
        list = data['data'];
        isClear = list[0]["done"];
        membersListName.clear();
        membersListEmail.clear();
        for (int i = 1; i < list.length; i++) {
          membersListName.add(crypto.decrypt(list[i]["Name"]));
          membersListEmail.add(crypto.decrypt(list[i]["email"]));
          if (list[i]["done"]) {
            locked = true;
          }
        }

        if (this.mounted) {
          setState(() {});
        }
      } else {
        showToast(context, crypto.decrypt(data["Message"]));
      }
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
    }

    _extractExpenseData(expenseDetailByMember);
    if (widget.isRoomActive) {
      getFriendData();
    }
    _getPaymentData();
  }

  getFriendData() async {
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
        showToast(context, crypto.decrypt(data["Message"]));
      }
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
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

  Future _extractExpenseData(String email) async {
    if (this.mounted) {
      setState(() {
        heightExpense = 0;
        loaded = false;
        TransList.clear();
      });
    }
    try {
      final response = await http.post(Uri.parse(global.url + 'transaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(email),
            'roomKey': crypto.encrypt(widget.roomKey),
          }));

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        if (TransData != null) {
          TransList = jsonDecode(response.body)['data'];
        }
      } else {
        showToast(context, crypto.decrypt(TransData["Message"]));
      }
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
    }

    heightExpense = 30 + TransList.length * 125 + (TransList.length - 1) * 5;

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
          showToast(context, crypto.decrypt(Tdata["Message"]));
        }
      } on Exception catch (_) {
        Navigator.pop(context);
        showToast(context, "No Internet Connection");
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

        showToast(context, crypto.decrypt(Tdata["Message"]));
      } on Exception catch (_) {
        Navigator.pop(context);
        showToast(context, "No Internet Connection");
      }
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  retrievePaymentData() async {
    try {
      if (membersListIndexS == membersListIndexR) {
        showToast(context, "Same User");
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
              context, crypto.decrypt(jsonDecode(response.body)["Message"]));
        }
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      showToast(context, "No Internet Connection");
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
      showToast(context, crypto.decrypt(CloseData["Message"]));
      Navigator.pop(context);
      _refreshIndicatorKey.currentState?.show();
    } on Exception catch (_) {
      Navigator.pop(context);
      showToast(context, "No Internet Connection");
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  closeRoomWidget(BuildContext context) {
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () async {
                                buildShowDialog(context);
                                await CloseRoom(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(color: Colors.white),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  Widget addFriendWidget(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Add Member",
                            style: TextStyle(fontSize: 22),
                          ),
                          SizedBox(
                            height: 20,
                          ),
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
                              SearchFriend();
                            },
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
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
                                          context, friendDataSearched)))
                        ],
                      )))));
    });
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
      showToast(context, crypto.decrypt(data["Message"]));
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
    }
    Navigator.pop(context);
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
      showToast(context, crypto.decrypt(data["Message"]));
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
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
      showToast(context, crypto.decrypt(data["Message"]));
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
    }
  }

  Widget friendListWidget(BuildContext context, List<FriendEach> data) {
    return StatefulBuilder(builder: (context, setState) {
      return ListView.separated(
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
                                      image: imageProvider, fit: BoxFit.cover),
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
                                    await cancelJoinRequest(data[index].email);
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
          });
    });
  }

  Widget memberCard(BuildContext context, int index) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            if (this.mounted) {
              expenseDetailByMember = crypto.decrypt(list[index]['email']);
              expenseTitle =
                  crypto.decrypt(list[index]['Name']) + "\'s Expense";
            }
            _extractExpenseData(crypto.decrypt(list[index]['email']));
          },
          child: Card(
            elevation: 1.0,
            shadowColor: Theme.of(context).primaryColor,
            shape: list[index]['done']
                ? RoundedRectangleBorder(
                    side: BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(15.0),
                  )
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                    padding: const EdgeInsets.all(8.0),
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
                          onTap: () => showToast(
                              context, crypto.decrypt(list[index]['Name'])),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Total: ₹ " + crypto.decrypt(list[index]['Expense']),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            foreground: Paint()..shader = linearGradient_2,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        double.parse(double.parse(
                                        crypto.decrypt(list[index]["current"]))
                                    .toStringAsFixed(2)) >
                                0
                            ? Text(
                                "Gain: ₹ " +
                                    double.parse(crypto
                                            .decrypt(list[index]["current"]))
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              )
                            : double.parse(double.parse(crypto
                                            .decrypt(list[index]["current"]))
                                        .toStringAsFixed(2)) <
                                    0
                                ? Text(
                                    "Loss: ₹ " +
                                        double.parse(crypto.decrypt(
                                                list[index]["current"]))
                                            .toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                                  )
                                : SizedBox(),
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
        elevation: 1.4,
        shadowColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
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
              shape: RoundedRectangleBorder(
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

  Widget memberAll(BuildContext context) {
    return SizedBox(
        width: 140,
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: InkWell(
                onTap: () {
                  if (this.mounted) {
                    setState(() {
                      expenseTitle = "All Expense";
                      expenseDetailByMember = "all";
                    });
                  }
                  _extractExpenseData("all");
                },
                child: Card(
                    elevation: 1.0,
                    shadowColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.roomName),
          actions: [
            locked
                ? SizedBox()
                : IconButton(
                    onPressed: () async {
                      if (loadFriendData) {
                        if (friendData.isEmpty) {
                          showToast(context, "No Friend Found");
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                addFriendWidget(context),
                          );
                        }
                      } else {
                        showToast(context, "Loading Data");
                      }
                    },
                    icon: Icon(
                      Icons.person_add,
                      color:
                          themeProvider.darkTheme ? Colors.white : Colors.black,
                    )),
            IconButton(
                onPressed: () {
                  if (membersListName.length <= 1) {
                    showToast(context, "More Than One Member Required");
                  } else {
                    setState(() {
                      defaultPage = !defaultPage;
                    });
                  }
                },
                icon: Icon(
                  Icons.transfer_within_a_station_rounded,
                  color: themeProvider.darkTheme ? Colors.white : Colors.black,
                ))
          ],
        ),
        body: defaultPage
            ? RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _initialisation,
                child: list.isEmpty
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text("Loading..."),
                        ),
                      )
                    : NestedScrollView(
                        controller: _scrollController,
                        headerSliverBuilder: (context, value) {
                          return [
                            SliverToBoxAdapter(
                              child: Slidable(
                                endActionPane: ActionPane(
                                    motion: const BehindMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) async {
                                          await Share.share("Join " +
                                              widget.roomName +
                                              "\nRoom Key: " +
                                              widget.roomKey +
                                              "\n" +
                                              widget.roomLink);
                                        },
                                        backgroundColor: Colors.blue,
                                        label: 'Share',
                                        icon: Icons.share,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      )
                                    ]),
                                child: ListTile(
                                  title: Text("Room Key"),
                                  trailing: Text(widget.roomKey),
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: ListTile(
                                title: const Text("Total Expense"),
                                trailing: Text(
                                    crypto.decrypt(list[0]["TotalExpense"])),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: ListTile(
                                title: const Text("Average Expense"),
                                trailing: Text(
                                    crypto.decrypt(list[0]["AverageExpense"])),
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
                                trailing: Text(crypto.decrypt(list[0]["date"])),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: !isClear
                                  ? Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: SizedBox(
                                        height: 45,
                                        child: ElevatedButton(
                                          child: const Text(
                                            "Close Room",
                                            style:
                                                TextStyle(color: Colors.white),
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
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          if (index == 0) {
                                            return memberAll(context);
                                          } else {
                                            return memberCard(context, index);
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
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
                        body: TransList.isEmpty
                            ? (Center(
                                child: loaded
                                    ? Text(
                                        "No Expense Found",
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      )
                                    : CircularProgressIndicator()))
                            : SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: heightExpense,
                                child: ExpenseData(
                                  TransList: TransList,
                                  RoomKey: widget.roomKey,
                                  Email: widget.email,
                                  Token: widget.token,
                                  refreshIndicatorKey: _refreshIndicatorKey,
                                  locked: locked,
                                ),
                              ),
                      ),
              )
            : Scrollbar(
                radius: Radius.circular(10.0),
                thickness: 5.5,
                child: Padding(
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
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: list.length - 1,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Card(
                                      elevation: 1.4,
                                      shadowColor:
                                          Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: membersListEmail[index] ==
                                                    membersListEmail[
                                                        membersListIndexS]
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .backgroundColor),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl: crypto
                                                          .decrypt(
                                                              list[index + 1]
                                                                  ['pic'])
                                                          .length ==
                                                      0
                                                  ? global.driveUrl +
                                                      "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                  : crypto.decrypt(
                                                      list[index + 1]['pic']),
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                              errorWidget:
                                                  (context, url, error) =>
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
                                              imageBuilder:
                                                  (context, imageProvider) =>
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
                                                  list[index + 1]['Name']),
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
                              height: 70,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: list.length - 1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Card(
                                          elevation: 1.4,
                                          shadowColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: membersListEmail[
                                                            index] ==
                                                        membersListEmail[
                                                            membersListIndexR]
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .backgroundColor),
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: crypto
                                                              .decrypt(list[
                                                                      index + 1]
                                                                  ['pic'])
                                                              .length ==
                                                          0
                                                      ? global.driveUrl +
                                                          "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                      : crypto.decrypt(
                                                          list[index + 1]
                                                              ['pic']),
                                                  progressIndicatorBuilder: (context,
                                                          url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                                  errorWidget:
                                                      (context, url, error) =>
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
                                                  imageBuilder: (context,
                                                          imageProvider) =>
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
                                                      list[index + 1]['Name']),
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                      ElevatedButton(
                        child: const Text(
                          "Search",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          retrievePaymentData();
                        },
                      ),
                      showAllTransactionData
                          ? (paidTransactionData
                              ? (allTransactionData.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No Results Found!!!",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Total Amount Paid: ₹ " +
                                              paymentTotalALL,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ListView.separated(
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                        height: 5,
                                                      ),
                                              shrinkWrap: true,
                                              physics: ScrollPhysics(),
                                              itemCount:
                                                  allTransactionData.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return Card(
                                                  elevation: 1.0,
                                                  shadowColor: Theme.of(context)
                                                      .primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: Text(
                                                            crypto.decrypt(
                                                                    allTransactionData[
                                                                            index]
                                                                        [
                                                                        "sender"]) +
                                                                " -> " +
                                                                crypto.decrypt(
                                                                    allTransactionData[
                                                                            index]
                                                                        [
                                                                        "receiver"]),
                                                            style:
                                                                const TextStyle(
                                                              overflow:
                                                                  TextOverflow
                                                                      .clip,
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
                                                                  child:
                                                                      Opacity(
                                                                    opacity:
                                                                        0.8,
                                                                    child: Text(
                                                                      crypto.decrypt(
                                                                          allTransactionData[index]
                                                                              [
                                                                              "Date"]),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
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
                                                                        crypto.decrypt(allTransactionData[index]
                                                                            [
                                                                            "Amount"]),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          16,
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
                                      ],
                                    ))
                              : Center(
                                  child: Text("Loading..."),
                                ))
                          : (isLoadedDef
                              ? paymentData.isEmpty
                                  ? (payment
                                      ? Center(
                                          child: Text("Loading..."),
                                        )
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
                                        "Total Amount Paid: ₹ " + paymentTotal,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ListView.separated(
                                            separatorBuilder:
                                                (context, index) => SizedBox(
                                                      height: 5,
                                                    ),
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            itemCount: paymentData.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return SizedBox(
                                                  height: 70,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: Card(
                                                    elevation: 1.0,
                                                    shadowColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Opacity(
                                                              opacity: 0.8,
                                                              child: Text(
                                                                crypto.decrypt(
                                                                    paymentData[
                                                                            index]
                                                                        [
                                                                        "Date"]),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 18,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              "₹ " +
                                                                  crypto.decrypt(
                                                                      paymentData[
                                                                              index]
                                                                          [
                                                                          "Amount"]),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ]),
                                                    ),
                                                  ));
                                            }),
                                      ),
                                    ])
                              : SizedBox())
                    ],
                  ),
                )),
        floatingActionButton: widget.isRoomActive
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
                                    borderRadius: BorderRadius.circular(12.0)),
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: SizedBox(
                                    height: isClear ? 60 : (locked ? 120 : 170),
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
                                                      showToast(context,
                                                          "More Than One Member Required");
                                                    } else {
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (BuildContext
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
                                                                                          child: ElevatedButton(
                                                                                              child: const Text(
                                                                                                "Close",
                                                                                                style: TextStyle(color: Colors.white),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                Navigator.pop(context);
                                                                                              }),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: 40,
                                                                                          width: 100,
                                                                                          child: ElevatedButton(
                                                                                              child: const Text(
                                                                                                "Add",
                                                                                                style: TextStyle(color: Colors.white),
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
                                                  title:
                                                      const Text("Add Expense"),
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (BuildContext
                                                            context) {
                                                          return StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                            return Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12.0)),
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.9,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          18.0),
                                                                  child: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          "Add Expense",
                                                                          style:
                                                                              TextStyle(fontSize: 22),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Form(
                                                                          key:
                                                                              _formKey,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
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
                                                                                                  elevation: 1.4,
                                                                                                  shadowColor: Theme.of(context).primaryColor,
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    side: BorderSide(color: addExpenseTo.isEmpty ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor),
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
                                                                                    } else if (membersListEmail[index - 1] == widget.email) {
                                                                                      return SizedBox();
                                                                                    } else {
                                                                                      return InkWell(
                                                                                        child: Padding(
                                                                                          padding: EdgeInsets.all(8.0),
                                                                                          child: Card(
                                                                                            elevation: 1.4,
                                                                                            shadowColor: Theme.of(context).primaryColor,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              side: BorderSide(color: findElement(addExpenseTo, membersListEmail[index - 1]) ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor),
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
                                                                                      height: 40,
                                                                                      width: 100,
                                                                                      child: ElevatedButton(
                                                                                          child: const Text(
                                                                                            "Close",
                                                                                            style: TextStyle(color: Colors.white),
                                                                                          ),
                                                                                          onPressed: () {
                                                                                            Navigator.pop(context);
                                                                                          }),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      height: 40,
                                                                                      width: 100,
                                                                                      child: ElevatedButton(
                                                                                          child: const Text(
                                                                                            "Add",
                                                                                            style: TextStyle(color: Colors.white),
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
      String amount, String flag) async {
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
            'flag': crypto.encrypt(flag)
          }));

      var updateMessage = jsonDecode(response.body);
      showToast(context, crypto.decrypt(updateMessage["Message"]));
      widget.refreshIndicatorKey.currentState?.show();
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
    }
  }

  Widget _buildUpdateDialog(
      BuildContext context, String id, String purpose, String amount) {
    return StatefulBuilder(builder: (context, setState) {
      _purpose.text = purpose;
      _amount.text = amount;

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: ElevatedButton(
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      buildShowDialog(context);
                                      await _updateTransaction(context,
                                          _purpose.text, id, _amount.text, "1");
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    }),
                              ),
                              SizedBox(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.3,
                                child: ElevatedButton(
                                    child: const Text(
                                      "Update",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      if (_updateExpense.currentState!
                                          .validate()) {
                                        buildShowDialog(context);
                                        await _updateTransaction(
                                            context,
                                            _purpose.text,
                                            id,
                                            _amount.text,
                                            "0");
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
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

  addToPersonalExpense(String objId) async {
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
            'id': crypto.encrypt(objId)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]));
    } on Exception catch (_) {
      showToast(context, "No Internet Connection");
    }
    Navigator.pop(context);
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
      List<dynamic> partialExpense) {
    return StatefulBuilder(builder: (context, setState) {
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
                        ? IconButton(
                            onPressed: () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    _buildUpdateDialog(
                                        context, id, purpose, amount),
                              );
                            },
                            icon: Icon(Icons.edit))
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
                        height: 10,
                      ),
                partialExpense.isEmpty
                    ? SizedBox()
                    : SizedBox(
                        height: 10,
                      ),
                partialExpense.isEmpty
                    ? SizedBox()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width - 65,
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: partialExpense.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 1.4,
                                shadowColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: crypto
                                                    .decrypt(
                                                        partialExpense[index]
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
                                                value:
                                                    downloadProgress.progress),
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
                                        imageBuilder:
                                            (context, imageProvider) =>
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
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(
                  height: 25,
                ),
                SizedBox(
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.95 - 25,
                  child: ElevatedButton(
                    onPressed: () async {
                      buildShowDialog(context);
                      await addToPersonalExpense(id);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Add To Personal Expense",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                SizedBox(
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.95 - 25,
                  child: ElevatedButton(
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
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
                      crypto.decrypt(widget.TransList[index]["Date"]),
                      crypto.decrypt(widget.TransList[index]["Email"]),
                      crypto.decrypt(widget.TransList[index]["id"]),
                      crypto.decrypt(widget.TransList[index]["Purpose"]),
                      crypto.decrypt(widget.TransList[index]["Amount"]),
                      widget.locked,
                      partialExpense),
                );
              },
              child: SizedBox(
                  height: 150,
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
                                        height: 10,
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
                                        height: 10,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          "Expense Type : " +
                                              (partialExpense.isEmpty
                                                  ? "All"
                                                  : "Partial"),
                                          style: const TextStyle(
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          crypto.decrypt(
                                              widget.TransList[index]["Date"]),
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
