import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';

import '../functions/additionalFunction.dart';
import '../functions/filterBankSMS.dart';
import '../contents.dart' as global;
import '../models/RoomEach.dart';

class BankTransactions extends StatefulWidget {
  final String email;
  final String token;
  final bool isBankMessageLoadedOnce;
  final List<dynamic> expenseCategory;
  final List<dynamic> investmentCategory;
  final List<RoomEach> RoomData;

  const BankTransactions({
    Key? key,
    required this.email,
    required this.token,
    required this.isBankMessageLoadedOnce,
    required this.expenseCategory,
    required this.investmentCategory,
    required this.RoomData,
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
  List<TransactionEach> sbiTransactions = [];
  int categoryIndex = 0;
  int investIndex = 0;
  int roomIndex = 0;
  int roomCategoryIndex = 0;
  List<dynamic> category = [];
  List<dynamic> investmentCat = [];
  final _formKey = GlobalKey<FormState>();
  final _formKeyRoom = GlobalKey<FormState>();
  final TextEditingController _purpose = TextEditingController();
  List<String> addExpenseTo = [];

  Future<void> getAllSms() async {
    category = widget.expenseCategory;
    investmentCat = widget.investmentCategory;
    pref = await SharedPreferences.getInstance();

    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );
      _messages = messages;
    } else {
      await Permission.sms.request();
      permissionGranted = await Permission.sms.isDenied;
    }

    if (permission.isGranted) {
      sbiTransactions = await filterSBISMS(_messages);
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
                                pref.setBool("isBankMessageLoadedOnce", true);
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
                                              color: (index == categoryIndex
                                                  ? Colors.white
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color),
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
                                                    color: (index == investIndex
                                                        ? Colors.white
                                                        : Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .color),
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
              'roomKey': crypto.encrypt(widget.RoomData[roomIndex].roomKey),
              'purpose': crypto.encrypt(_purpose.text),
              'amt': crypto.encrypt(amount),
              'type': crypto.encrypt(category[roomCategoryIndex]),
              "members": crypto.encrypt(addExpenseTo.toString())
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
                          itemCount: widget.RoomData.length,
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
                                            widget.RoomData[index].roomName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: (index == roomIndex
                                                  ? Colors.white
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color),
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
                                          roomIndex = index;
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
                                            category[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: (index == roomCategoryIndex
                                                  ? Colors.white
                                                  : Theme.of(context)
                                                      .textTheme
                                                      .bodySmall!
                                                      .color),
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

  void showAddDialog(String amount, String date) {
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
                    height: 185,
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
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: OutlinedButton(
                                onPressed: () {
                                  showRoomDialog(amount, date);
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
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
                          ]),
                    ),
                  ),
                ));
          });
        });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBankMessageLoadedOnce) {
      Future.delayed(Duration.zero, () => showBankAlert(context));
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Transactions"),
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
                child: sbiTransactions.isEmpty
                    ? ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                "No SMS Found",
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
                          child: ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(
                                    height: 5,
                                  ),
                              shrinkWrap: true,
                              itemCount: sbiTransactions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  child: Card(
                                    elevation: 1.0,
                                    shadowColor: Theme.of(context).primaryColor,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: sbiTransactions[index].type ==
                                                  "Credit"
                                              ? Colors.greenAccent
                                              : Colors.redAccent),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                sbiTransactions[index].receiver,
                                                style: TextStyle(fontSize: 24),
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    showAddDialog(
                                                        sbiTransactions[index]
                                                            .amount,
                                                        sbiTransactions[index]
                                                            .date);
                                                  },
                                                  icon: Icon(
                                                    Icons.add,
                                                    color:
                                                        sbiTransactions[index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent,
                                                  ))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                  width: 55,
                                                  height: 30,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      border: Border.all(
                                                        color: sbiTransactions[
                                                                        index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                        sbiTransactions[index]
                                                            .bank,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        )),
                                                  )),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Container(
                                                  width: 55,
                                                  height: 30,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      border: Border.all(
                                                        color: sbiTransactions[
                                                                        index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                        sbiTransactions[index]
                                                            .type,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        )),
                                                  )),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              sbiTransactions[index].mode ==
                                                      "Unknown"
                                                  ? SizedBox()
                                                  : Container(
                                                      width: 55,
                                                      height: 30,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          border: Border.all(
                                                            color: sbiTransactions[
                                                                            index]
                                                                        .type ==
                                                                    "Credit"
                                                                ? Colors
                                                                    .greenAccent
                                                                : Colors
                                                                    .redAccent,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Text(
                                                            sbiTransactions[
                                                                    index]
                                                                .mode,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            )),
                                                      )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            "Amount: ₹ " +
                                                sbiTransactions[index].amount,
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Ref ID: " +
                                                sbiTransactions[index]
                                                    .transactionID,
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                              "Date: " +
                                                  sbiTransactions[index].date,
                                              style: TextStyle(fontSize: 17)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
              ),
      ),
    );
  }
}
