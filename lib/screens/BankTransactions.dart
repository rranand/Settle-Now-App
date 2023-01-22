import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';
import 'package:shimmer/shimmer.dart';

import '../functions/additionalFunction.dart';
import '../functions/filterBankSMS.dart';
import '../contents.dart' as global;

class BankTransactions extends StatefulWidget {
  final String email;
  final String token;
  final bool isBankMessageLoadedOnce;
  final List<dynamic> expenseCategory;
  final List<dynamic> investmentCategory;
  final List<dynamic> roomExpenseCategory;

  const BankTransactions({
    Key? key,
    required this.email,
    required this.token,
    required this.isBankMessageLoadedOnce,
    required this.expenseCategory,
    required this.investmentCategory,
    required this.roomExpenseCategory,
  }) : super(key: key);

  @override
  State<BankTransactions> createState() => _BankTransactionsState();
}

class _BankTransactionsState extends State<BankTransactions> {
  List<SmsMessage> _messages = [];
  late SharedPreferences pref;
  bool permissionGranted = false;
  final SmsQuery _query = SmsQuery();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<TransactionEach> allTransactions = [];
  int categoryIndex = 0;
  int investIndex = 0;
  int roomIndex = 0;
  int roomCategoryIndex = 0;
  List<dynamic> category = [];
  List<TextEditingController> _amountRangeValues = [
    new TextEditingController(text: "0"),
    new TextEditingController(text: "10000")
  ];
  List<String> transactionType = ["Credit", "Debit"];
  List<String> allBanks = ["SBI", "ICICI"];
  Set<int> allBanksIndex = Set();
  List<String> transactionMode = [
    "UPI",
    "NEFT",
    "IMPS",
    "Debit Card",
    "Credit Card"
  ];
  int lenDenIndex = 0;
  Set<int> transactionTypeIndex = Set();
  Set<int> transactionModeIndex = Set();
  List<dynamic> investmentCat = [];
  List<dynamic> roomData = [];
  List<dynamic> LenDenData = [];
  bool showFilterResult = false;
  final _formKey = GlobalKey<FormState>();
  final _formKeyRoom = GlobalKey<FormState>();
  final _formKeyLenDen = GlobalKey<FormState>();
  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _lenDenRoom = TextEditingController();
  String LenDenRoomID = "";
  List<dynamic> roomMembers = [];
  List<String> addExpenseTo = [];
  bool isSplitMemberLoading = false;
  bool openedOnce = false;
  bool filterDialog = false;
  Set<int> filtercategoryIndex = Set();
  bool dataFetched = false;
  DateTimeRange dateRange = DateTimeRange(
      start: new DateTime(DateTime.now().year, DateTime.now().month),
      end: DateTime.now());

  List<TransactionEach> filteredResult = [];

  Future<void> getLenDenData() async {
    try {
      final response = await http.patch(Uri.parse(global.url + 'lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({"email": crypto.encrypt(widget.email)}));

      if (response.statusCode == 200) {
        List<dynamic> temp = jsonDecode(response.body)['data'];

        for (int i = 0; i < temp.length; i++) {
          if (!temp[i]["closed"]) {
            LenDenData.add(temp[i]);
          }
        }
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]),
            Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getActiveRooms() async {
    try {
      final response = await http.post(
          Uri.parse(global.url + 'room/fullActiveRoom'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
          }));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        roomData = data['data'];
        if (roomData.isNotEmpty) {
          await getMembers(roomData[0]['Key']);
        }
      }
    } on Exception catch (_) {
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getMembers(String roomkey) async {
    if (this.mounted) {
      setState(() {
        isSplitMemberLoading = true;
      });
    }
    try {
      final response = await http.post(
          Uri.parse(global.url + 'room/roomSplitMembers'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode(
              {'email': crypto.encrypt(widget.email), 'roomKey': roomkey}));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        roomMembers = data['data'];
      }
    } on Exception catch (_) {
      await onException(context);
    }

    isSplitMemberLoading = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getAllSms() async {
    dataFetched = false;
    category = widget.expenseCategory;
    investmentCat = widget.investmentCategory;

    if (this.mounted) {
      setState(() {});
    }
    pref = await SharedPreferences.getInstance();

    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );
      _messages = messages;
      allTransactions = await filterSBISMS(_messages);
      allTransactions.addAll(await filterICICISMS(_messages));

      allTransactions.sort((b, a) {
        DateTime tempDate_1 =
            new DateFormat("MMM dd yyyy h:mm a").parse(a.date);
        DateTime tempDate_2 =
            new DateFormat("MMM dd yyyy h:mm a").parse(b.date);
        return tempDate_1.compareTo(tempDate_2);
      });

      await getActiveRooms();
      await getLenDenData();
      dataFetched = true;
    } else {
      await Permission.sms.request();
      permissionGranted = await Permission.sms.isDenied;
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  void showBankAlert(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
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
                            "Bank Supported",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                await pref.setBool(
                                    "isBankMessageLoadedOnce", true);
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "State Bank of India",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "ICICI",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Divider(),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                          "* Currently this feature in beta phase, may be transaction will not list properly.")
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  AddExpense(BuildContext context, String amount, String date) async {
    var Tdata = null;
    buildShowDialog(context);

    try {
      final response = await http.patch(Uri.parse(global.url + 'ptransaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'purpose': crypto.encrypt(_purpose.text),
            'amt': crypto.encrypt(amount),
            'date': crypto.encrypt(date),
            'type': crypto.encrypt(categoryIndex.toString()),
            'investType': crypto.encrypt(investIndex.toString()),
          }));

      _purpose.text = "";
      Tdata = jsonDecode(response.body);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);

      if (response.statusCode == 422) {
        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
      } else {
        showToast(context, "Expense Added Successfully", Icons.check);
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  void showPersonalExpenseDialog(String amount, String date) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                          counterText: "",
                          contentPadding: EdgeInsets.all(8.0),
                          hintText: "Enter Purpose",
                          labelText: "Purpose",
                          errorStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.96,
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: category.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: InkWell(
                                  child: Card(
                                    color:
                                        Theme.of(context).dialogBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: index == categoryIndex
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).cardColor),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: InkWell(
                                          child: Text(
                                            category[index],
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
                                          categoryIndex = index;
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
                      categoryIndex == 1
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.96,
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: investmentCat.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: InkWell(
                                        child: Card(
                                          color: Theme.of(context)
                                              .dialogBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: index == investIndex
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .cardColor),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                              child: InkWell(
                                                child: Text(
                                                  investmentCat[index],
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
                                                investIndex = index;
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 45,
                        width: 90,
                        child: OutlinedButton(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: themeProvider.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                AddExpense(context, amount, date);
                              }
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
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

  Future createLenDenRoom(BuildContext context) async {
    try {
      buildShowDialog(context);
      final response = await http.post(Uri.parse(global.url + 'lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            "email": crypto.encrypt(widget.email),
            "name": crypto.encrypt(_lenDenRoom.text)
          }));

      if (response.statusCode == 200) {
        LenDenRoomID = jsonDecode(response.body)["id"];
        _lenDenRoom.text = "";
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']),
            Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }

    Navigator.pop(context);
    if (this.mounted) {
      setState(() {});
    }
  }

  AddLenDen(BuildContext context, String amount, String date, String id) async {
    if (_formKeyLenDen.currentState!.validate()) {
      var Tdata = null;
      buildShowDialog(context);

      try {
        final response = await http.delete(Uri.parse(global.url + 'lend'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': widget.token
            },
            body: jsonEncode({
              'email': crypto.encrypt(widget.email),
              'key': id,
              'purpose': crypto.encrypt(_purpose.text),
              'amount': crypto.encrypt(amount),
              "date": crypto.encrypt(date)
            }));

        _purpose.text = "";
        Tdata = jsonDecode(response.body);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        if (response.statusCode == 422) {
          showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
        } else {
          showToast(context, "Expense Added Successfully", Icons.check);
        }
      } on Exception catch (_) {
        Navigator.pop(context);
        await onException(context);
      }
      LenDenRoomID = "";
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  AddRoomExpense(BuildContext context, String amount, String date) async {
    if (_formKeyRoom.currentState!.validate()) {
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
              'roomKey': roomData[roomIndex]["Key"],
              'purpose': crypto.encrypt(_purpose.text),
              'amt': crypto.encrypt(amount),
              'type':
                  crypto.encrypt(widget.roomExpenseCategory[roomCategoryIndex]),
              "members": crypto.encrypt(addExpenseTo.toString()),
              "date": crypto.encrypt(date)
            }));

        _purpose.text = "";
        Tdata = jsonDecode(response.body);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        if (response.statusCode == 422) {
          showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
        } else {
          showToast(context, "Expense Added Successfully", Icons.check);
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

  void showLenDenDialog(String amount, String date) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKeyLenDen,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                          counterText: "",
                          contentPadding: EdgeInsets.all(8.0),
                          hintText: "Enter Purpose",
                          labelText: "Purpose",
                          errorStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.96,
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: LenDenData.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index == LenDenData.length) {
                              return SizedBox(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Card(
                                      color: Theme.of(context)
                                          .dialogBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: index == lenDenIndex
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).cardColor),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Center(
                                          child: InkWell(
                                            child: Text(
                                              "Create New",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      lenDenIndex = index;
                                      if (this.mounted) {
                                        setState(
                                          () {},
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return SizedBox(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Card(
                                      color: Theme.of(context)
                                          .dialogBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: index == lenDenIndex
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).cardColor),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Center(
                                          child: InkWell(
                                            child: Text(
                                              crypto.decrypt(
                                                  LenDenData[index]["name"]),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      lenDenIndex = index;
                                      if (this.mounted) {
                                        setState(
                                          () {},
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      lenDenIndex == LenDenData.length
                          ? TextFormField(
                              controller: _lenDenRoom,
                              keyboardType: TextInputType.text,
                              maxLength: 150,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 18),
                              autocorrect: false,
                              validator: (value) {
                                RegExp validateText = RegExp(r'\b[\w]+\b');
                                if (!validateText.hasMatch(_purpose.text)) {
                                  return "Enter Valid Room Name";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.all(8.0),
                                hintText: "Enter Room Name",
                                labelText: "Room Name",
                                errorStyle: TextStyle(fontSize: 15),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 45,
                        width: 90,
                        child: OutlinedButton(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: themeProvider.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () async {
                              if (_formKeyLenDen.currentState!.validate()) {
                                if (lenDenIndex == LenDenData.length) {
                                  await createLenDenRoom(context);
                                  AddLenDen(
                                      context, amount, date, LenDenRoomID);
                                } else {
                                  AddLenDen(context, amount, date,
                                      LenDenData[lenDenIndex]["key"]);
                                }
                              }
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void showRoomDialog(String amount, String date) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKeyRoom,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
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
                          counterText: "",
                          contentPadding: EdgeInsets.all(8.0),
                          hintText: "Enter Purpose",
                          labelText: "Purpose",
                          errorStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.96,
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: roomData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: InkWell(
                                  child: Card(
                                    color:
                                        Theme.of(context).dialogBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: index == roomIndex
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).cardColor),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: InkWell(
                                          child: Text(
                                            crypto.decrypt(
                                                roomData[index]["Name"]),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    await getMembers(roomData[index]["Key"]);
                                    roomIndex = index;
                                    if (this.mounted) {
                                      setState(
                                        () {},
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
                        width: MediaQuery.of(context).size.width * 0.96,
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.roomExpenseCategory.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: InkWell(
                                  child: Card(
                                    color:
                                        Theme.of(context).dialogBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: index == roomCategoryIndex
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).cardColor),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(
                                        child: InkWell(
                                          child: Text(
                                            widget.roomExpenseCategory[index],
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
                                          roomCategoryIndex = index;
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
                        height: 15,
                      ),
                      isSplitMemberLoading
                          ? CircularProgressIndicator()
                          : SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: roomMembers.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0) {
                                    return InkWell(
                                      child: SizedBox(
                                        width: 85,
                                        child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Card(
                                                color: Theme.of(context)
                                                    .dialogBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: addExpenseTo
                                                              .isEmpty
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .cardColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
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
                                  } else if (crypto.decrypt(
                                          roomMembers[index - 1]['email']) ==
                                      widget.email) {
                                    return SizedBox();
                                  } else {
                                    return InkWell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Card(
                                          color: Theme.of(context)
                                              .dialogBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: findElement(
                                                        addExpenseTo,
                                                        crypto.decrypt(
                                                            roomMembers[index -
                                                                1]['email']))
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .cardColor),
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
                                                                  roomMembers[
                                                                          index -
                                                                              1]
                                                                      ['pic'])
                                                              .length ==
                                                          0
                                                      ? global.driveUrl +
                                                          "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                      : crypto.decrypt(
                                                          roomMembers[index - 1]
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
                                                      roomMembers[index - 1]
                                                          ['Name']),
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
                                        if (findElement(
                                            addExpenseTo,
                                            crypto.decrypt(
                                                roomMembers[index - 1]
                                                    ['email']))) {
                                          addExpenseTo.remove(crypto.decrypt(
                                              roomMembers[index - 1]['email']));
                                        } else {
                                          addExpenseTo.add(crypto.decrypt(
                                              roomMembers[index - 1]['email']));

                                          if (addExpenseTo.length ==
                                              roomData.length) {
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
                      SizedBox(
                        height: 45,
                        width: 90,
                        child: OutlinedButton(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: themeProvider.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () {
                              if (_formKeyRoom.currentState!.validate()) {
                                AddRoomExpense(context, amount, date);
                              }
                            }),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void pickDateRange() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final picked = await showDateRangePicker(
        context: context,
        initialDateRange: dateRange,
        confirmText: "Ok",
        helpText: "Select Date",
        saveText: "Save",
        firstDate: new DateTime(1999),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: themeProvider.isDarkTheme
                ? ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      surface: Theme.of(context).primaryColor,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.white,
                  )
                : ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      surface: Theme.of(context).primaryColor,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
            child: child!,
          );
        });
    if (picked != null) {
      if (this.mounted) {
        setState(() {
          dateRange = picked;
        });
      }
    }
  }

  void showAddDialog(String amount, String date, String receiver) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _purpose.text = receiver;

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
                    height: roomData.isNotEmpty ? 240 : 185,
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
                              "Add Expense To",
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: OutlinedButton(
                                onPressed: () {
                                  showPersonalExpenseDialog(amount, date);
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Text(
                                  "Personal Expense",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                            ),
                            roomData.isNotEmpty
                                ? SizedBox(
                                    height: 10,
                                  )
                                : SizedBox(),
                            roomData.isNotEmpty
                                ? SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        showRoomDialog(amount, date);
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
                                        "Room",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: themeProvider.isDarkTheme
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: OutlinedButton(
                                onPressed: () {
                                  showLenDenDialog(amount, date);
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Text(
                                  "Len-Den",
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

  Future<void> getFilterResult() async {
    if (this.mounted) {
      setState(() {
        filteredResult.clear();
      });
    }

    DateFormat dateFormat = DateFormat("MMM dd yyyy h:mm a");

    allTransactions.forEach((element) {
      if (allBanksIndex.isEmpty) {
        if ((dateRange.start.isAtSameMomentAs(dateFormat.parse(element.date)) ||
                dateRange.start.isBefore(dateFormat.parse(element.date))) &&
            (dateRange.end.isAtSameMomentAs(dateFormat.parse(element.date)) ||
                dateRange.end.isAfter(dateFormat.parse(element.date)))) {
          double amt = double.parse(element.amount);
          if (amt >= int.parse(_amountRangeValues[0].text) &&
              amt <= int.parse(_amountRangeValues[1].text)) {
            transactionTypeIndex.forEach((ttIndex) {
              String ttElement = transactionType[ttIndex];
              if (ttElement == element.type) {
                transactionModeIndex.forEach((tmIndex) {
                  String tmElement = transactionMode[tmIndex];
                  if (tmElement == element.mode) {
                    filteredResult.add(element);
                  }
                });
              }
            });

            if (transactionTypeIndex.isEmpty && transactionModeIndex.isEmpty) {
              filteredResult.add(element);
            } else if (transactionTypeIndex.isEmpty) {
              transactionModeIndex.forEach((tmIndex) {
                String tmElement = transactionMode[tmIndex];
                if (tmElement == element.mode) {
                  filteredResult.add(element);
                }
              });
            } else if (transactionModeIndex.isEmpty) {
              transactionTypeIndex.forEach((ttIndex) {
                String ttElement = transactionType[ttIndex];
                if (ttElement == element.type) {
                  filteredResult.add(element);
                }
              });
            }
          }
        }
      } else {
        allBanksIndex.forEach((abElement) {
          String bankName = allBanks[abElement];

          if (bankName == element.bank) {
            if ((dateRange.start
                        .isAtSameMomentAs(dateFormat.parse(element.date)) ||
                    dateRange.start.isBefore(dateFormat.parse(element.date))) &&
                (dateRange.end
                        .isAtSameMomentAs(dateFormat.parse(element.date)) ||
                    dateRange.end.isAfter(dateFormat.parse(element.date)))) {
              double amt = double.parse(element.amount);

              if (amt >= int.parse(_amountRangeValues[0].text) &&
                  amt <= int.parse(_amountRangeValues[1].text)) {
                transactionTypeIndex.forEach((ttIndex) {
                  String ttElement = transactionType[ttIndex];
                  if (ttElement == element.type) {
                    transactionModeIndex.forEach((tmIndex) {
                      String tmElement = transactionMode[tmIndex];
                      if (tmElement == element.mode) {
                        filteredResult.add(element);
                      }
                    });
                  }
                });

                if (transactionTypeIndex.isEmpty &&
                    transactionModeIndex.isEmpty) {
                  filteredResult.add(element);
                } else if (transactionTypeIndex.isEmpty) {
                  transactionModeIndex.forEach((tmIndex) {
                    String tmElement = transactionMode[tmIndex];
                    if (tmElement == element.mode) {
                      filteredResult.add(element);
                    }
                  });
                } else if (transactionModeIndex.isEmpty) {
                  transactionTypeIndex.forEach((ttIndex) {
                    String ttElement = transactionType[ttIndex];
                    if (ttElement == element.type) {
                      filteredResult.add(element);
                    }
                  });
                }
              }
            }
          }
        });
      }
    });

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
    if (!widget.isBankMessageLoadedOnce && !openedOnce) {
      openedOnce = true;
      if (this.mounted) {
        setState(() {});
      }
      Future.delayed(Duration.zero, () => showBankAlert(context));
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Transactions"),
        actions: [
          IconButton(
              onPressed: () {
                filterDialog = _scaffoldKey.currentState!.isEndDrawerOpen;
                filterDialog = !filterDialog;

                if (filterDialog) {
                  _scaffoldKey.currentState!.openEndDrawer();
                } else {
                  _scaffoldKey.currentState!.closeEndDrawer();
                }
              },
              icon: Icon(Icons.filter_alt_outlined))
        ],
      ),
      body: Scaffold(
        key: _scaffoldKey,
        endDrawer: Drawer(
          backgroundColor: themeProvider.isDarkTheme
              ? Theme.of(context).scaffoldBackgroundColor
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                SizedBox(
                  height: 10,
                ),
                Scrollbar(
                  radius: Radius.circular(0),
                  thickness: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bank",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 100,
                        width: 250,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: allBanks.length,
                            itemBuilder: ((context, index) {
                              return CheckboxListTile(
                                title: Text(allBanks[index]),
                                value: allBanksIndex.contains(index),
                                onChanged: (_) {
                                  if (allBanksIndex.contains(index)) {
                                    allBanksIndex.remove(index);
                                  } else {
                                    allBanksIndex.add(index);
                                  }

                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            })),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Type",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 100,
                        width: 250,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: transactionType.length,
                            itemBuilder: ((context, index) {
                              return CheckboxListTile(
                                title: Text(transactionType[index]),
                                value: transactionTypeIndex.contains(index),
                                onChanged: (_) {
                                  if (transactionTypeIndex.contains(index)) {
                                    transactionTypeIndex.remove(index);
                                  } else {
                                    transactionTypeIndex.add(index);
                                  }

                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            })),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Mode",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w600),
                      ),
                      Scrollbar(
                        radius: Radius.circular(0),
                        thickness: 0,
                        child: SizedBox(
                          width: 250,
                          height: 300,
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: transactionMode.length,
                              itemBuilder: ((context, index) {
                                return CheckboxListTile(
                                  title: Text(transactionMode[index]),
                                  value: transactionModeIndex.contains(index),
                                  onChanged: (_) {
                                    if (transactionModeIndex.contains(index)) {
                                      transactionModeIndex.remove(index);
                                    } else {
                                      transactionModeIndex.add(index);
                                    }

                                    if (this.mounted) {
                                      setState(() {});
                                    }
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                );
                              })),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Amount",
                        style: TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              controller: _amountRangeValues[0],
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.all(8.0),
                                prefixText: "₹ ",
                              ),
                              onChanged: (String s) {
                                if (this.mounted) {
                                  setState(() {
                                    _amountRangeValues[0].text = s;
                                    _amountRangeValues[0].selection =
                                        TextSelection.collapsed(
                                            offset: _amountRangeValues[0]
                                                .text
                                                .length);
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              controller: _amountRangeValues[1],
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              maxLines: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.all(8.0),
                                prefixText: "₹ ",
                              ),
                              onChanged: (String s) {
                                if (this.mounted) {
                                  setState(() {
                                    _amountRangeValues[1].text = s;
                                    _amountRangeValues[1].selection =
                                        TextSelection.collapsed(
                                            offset: _amountRangeValues[1]
                                                .text
                                                .length);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Date",
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                              onPressed: pickDateRange,
                              icon: Icon(Icons.date_range)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 35,
                            child: ElevatedButton(
                              onPressed: pickDateRange,
                              child: Text(
                                DateFormat('dd/MMM/yyyy')
                                    .format(dateRange.start),
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 35,
                            child: ElevatedButton(
                                onPressed: pickDateRange,
                                child: Text(
                                    DateFormat('dd/MMM/yyyy')
                                        .format(dateRange.end),
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white))),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    child: Text(
                      "Apply",
                      style: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () async {
                      showFilterResult = true;
                      _scaffoldKey.currentState!.closeEndDrawer();
                      await getFilterResult();
                      if (this.mounted) {
                        setState(() {});
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    child: Text(
                      "Clear Filter",
                      style: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      showFilterResult = false;
                      transactionModeIndex.clear();
                      transactionTypeIndex.clear();
                      _amountRangeValues[0].text = "0";
                      _amountRangeValues[1].text = "10000";
                      dateRange = DateTimeRange(
                          start: new DateTime(
                              DateTime.now().year, DateTime.now().month),
                          end: DateTime.now());
                      if (this.mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: permissionGranted
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "SMS Permission Required",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 140,
                            child: OutlinedButton(
                              child: Text(
                                "Open Setting",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16),
                              ),
                              onPressed: () {
                                openAppSettings();
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            width: 140,
                            child: OutlinedButton(
                              child: Text(
                                "Close",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16),
                              ),
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
                            ),
                          )
                        ],
                      )
                    ],
                  )),
                )
              : RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: getAllSms,
                  child: dataFetched
                      ? (allTransactions.isEmpty
                          ? ListView(
                              physics: AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      "No Transaction Found",
                                      style: TextStyle(
                                        fontSize: 22,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Scrollbar(
                                radius: Radius.circular(10.0),
                                thickness: 5.5,
                                child: showFilterResult
                                    ? filteredResult.isEmpty
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: Text(
                                                "No Transaction Found",
                                                style: TextStyle(
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ),
                                          )
                                        : ListView.separated(
                                            separatorBuilder:
                                                (context, index) => SizedBox(
                                                      height: 5,
                                                    ),
                                            shrinkWrap: true,
                                            itemCount: filteredResult.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return SizedBox(
                                                child: Card(
                                                  elevation: 1.0,
                                                  shadowColor: Theme.of(context)
                                                      .primaryColor,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: filteredResult[
                                                                        index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
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
                                                              filteredResult[
                                                                      index]
                                                                  .receiver,
                                                              style: TextStyle(
                                                                  fontSize: 24),
                                                            ),
                                                            filteredResult[index]
                                                                        .type ==
                                                                    "Credit"
                                                                ? SizedBox()
                                                                : IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      showAddDialog(
                                                                          filteredResult[index]
                                                                              .amount,
                                                                          filteredResult[index]
                                                                              .date,
                                                                          filteredResult[index]
                                                                              .receiver);
                                                                    },
                                                                    icon: Icon(
                                                                      Icons.add,
                                                                      color: filteredResult[index].type ==
                                                                              "Credit"
                                                                          ? Colors
                                                                              .greenAccent
                                                                          : Colors
                                                                              .redAccent,
                                                                    ))
                                                          ],
                                                        ),
                                                        filteredResult[index]
                                                                    .type ==
                                                                "Credit"
                                                            ? SizedBox(
                                                                height: 8.0,
                                                              )
                                                            : SizedBox(),
                                                        Row(
                                                          children: [
                                                            Container(
                                                                height: 30,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: Colors
                                                                            .transparent,
                                                                        border: Border
                                                                            .all(
                                                                          color: filteredResult[index].type == "Credit"
                                                                              ? Colors.greenAccent
                                                                              : Colors.redAccent,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(12))),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          4.0,
                                                                      horizontal:
                                                                          8.0),
                                                                  child: Text(
                                                                      filteredResult[
                                                                              index]
                                                                          .bank,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                      )),
                                                                )),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Container(
                                                                height: 30,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: Colors
                                                                            .transparent,
                                                                        border: Border
                                                                            .all(
                                                                          color: filteredResult[index].type == "Credit"
                                                                              ? Colors.greenAccent
                                                                              : Colors.redAccent,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(12))),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          4.0,
                                                                      horizontal:
                                                                          8.0),
                                                                  child: Text(
                                                                      filteredResult[
                                                                              index]
                                                                          .type,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                      )),
                                                                )),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            filteredResult[index]
                                                                        .mode ==
                                                                    "Unknown"
                                                                ? SizedBox()
                                                                : Container(
                                                                    height: 30,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.transparent,
                                                                        border: Border.all(
                                                                          color: filteredResult[index].type == "Credit"
                                                                              ? Colors.greenAccent
                                                                              : Colors.redAccent,
                                                                        ),
                                                                        borderRadius: BorderRadius.all(Radius.circular(12))),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          vertical:
                                                                              4.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      child: Text(
                                                                          filteredResult[index]
                                                                              .mode,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                13,
                                                                          )),
                                                                    )),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Text(
                                                          "Amount: ₹ " +
                                                              filteredResult[
                                                                      index]
                                                                  .amount,
                                                          style: TextStyle(
                                                              fontSize: 17),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          "Ref ID: " +
                                                              filteredResult[
                                                                      index]
                                                                  .transactionID,
                                                          style: TextStyle(
                                                              fontSize: 17),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                            "Date: " +
                                                                filteredResult[
                                                                        index]
                                                                    .date,
                                                            style: TextStyle(
                                                                fontSize: 17)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            })
                                    : ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            SizedBox(
                                              height: 5,
                                            ),
                                        shrinkWrap: true,
                                        itemCount: allTransactions.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            child: Card(
                                              elevation: 1.0,
                                              shadowColor: Theme.of(context)
                                                  .primaryColor,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color:
                                                        allTransactions[index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          allTransactions[index]
                                                              .receiver,
                                                          style: TextStyle(
                                                              fontSize: 24),
                                                        ),
                                                        allTransactions[index]
                                                                    .type ==
                                                                "Credit"
                                                            ? SizedBox()
                                                            : IconButton(
                                                                onPressed: () {
                                                                  showAddDialog(
                                                                      allTransactions[
                                                                              index]
                                                                          .amount,
                                                                      allTransactions[
                                                                              index]
                                                                          .date,
                                                                      allTransactions[
                                                                              index]
                                                                          .receiver);
                                                                },
                                                                icon: Icon(
                                                                  Icons.add,
                                                                  color: allTransactions[index]
                                                                              .type ==
                                                                          "Credit"
                                                                      ? Colors
                                                                          .greenAccent
                                                                      : Colors
                                                                          .redAccent,
                                                                ))
                                                      ],
                                                    ),
                                                    allTransactions[index]
                                                                .type ==
                                                            "Credit"
                                                        ? SizedBox(
                                                            height: 8.0,
                                                          )
                                                        : SizedBox(),
                                                    Row(
                                                      children: [
                                                        Container(
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
                                                                      color: allTransactions[index].type ==
                                                                              "Credit"
                                                                          ? Colors
                                                                              .greenAccent
                                                                          : Colors
                                                                              .redAccent,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(12))),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 4.0,
                                                                  horizontal:
                                                                      8.0),
                                                              child: Text(
                                                                  allTransactions[
                                                                          index]
                                                                      .bank,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                  )),
                                                            )),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        Container(
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
                                                                      color: allTransactions[index].type ==
                                                                              "Credit"
                                                                          ? Colors
                                                                              .greenAccent
                                                                          : Colors
                                                                              .redAccent,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(12))),
                                                            child: Padding(
                                                              padding: const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 4.0,
                                                                  horizontal:
                                                                      8.0),
                                                              child: Text(
                                                                  allTransactions[
                                                                          index]
                                                                      .type,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                  )),
                                                            )),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        allTransactions[index]
                                                                    .mode ==
                                                                "Unknown"
                                                            ? SizedBox()
                                                            : Container(
                                                                height: 30,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                        color: Colors
                                                                            .transparent,
                                                                        border: Border
                                                                            .all(
                                                                          color: allTransactions[index].type == "Credit"
                                                                              ? Colors.greenAccent
                                                                              : Colors.redAccent,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(12))),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          4.0,
                                                                      horizontal:
                                                                          8.0),
                                                                  child: Text(
                                                                      allTransactions[
                                                                              index]
                                                                          .mode,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                      )),
                                                                )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Text(
                                                      "Amount: ₹ " +
                                                          allTransactions[index]
                                                              .amount,
                                                      style: TextStyle(
                                                          fontSize: 17),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Ref ID: " +
                                                          allTransactions[index]
                                                              .transactionID,
                                                      style: TextStyle(
                                                          fontSize: 17),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                        "Date: " +
                                                            allTransactions[
                                                                    index]
                                                                .date,
                                                        style: TextStyle(
                                                            fontSize: 17)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                              ),
                            ))
                      : Shimmer.fromColors(
                          baseColor: Theme.of(context).cardColor,
                          highlightColor: Theme.of(context).primaryColor,
                          child: ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(
                                    height: 5,
                                  ),
                              shrinkWrap: true,
                              itemCount: 16,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.all(10.0),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: 300,
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
                                              Icon(Icons.add)
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 50,
                                                height: 30,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12))),
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Container(
                                                width: 50,
                                                height: 30,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12))),
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Container(
                                                width: 50,
                                                height: 30,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12))),
                                              )
                                            ],
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
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            width: 140,
                                            height: 15.0,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.white,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            width: 210,
                                            height: 15.0,
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
                                  ),
                                );
                              }),
                        )),
        ),
      ),
    );
  }
}
