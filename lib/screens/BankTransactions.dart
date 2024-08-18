import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/themes.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/others/crypto.dart';
import 'package:shimmer/shimmer.dart';

import '../functions/additionalFunction.dart';
import '../functions/filterBankSMS.dart';
import '../contents.dart' as global;

class BankTransactions extends StatefulWidget {
  const BankTransactions({
    Key? key,
  }) : super(key: key);

  @override
  State<BankTransactions> createState() => _BankTransactionsState();
}

class _BankTransactionsState extends State<BankTransactions> {
  String _email = "";
  String _token = "";
  List<dynamic> expenseCategory = [];
  List<List<dynamic>> subCategory = [];
  List<SmsMessage> _messages = [];
  bool permissionGranted = false;
  final SmsQuery _query = SmsQuery();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyBankTrans =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<ScaffoldState> _scaffoldKeyBankTrans = GlobalKey<ScaffoldState>();
  List<TransactionEach> allTransactions = [];
  int categoryIndex = 0;
  int subCategoryIndex = 0;
  int roomIndex = 0;
  int roomCategoryIndex = 0;
  int roomClosedCount = 0;
  List<String> activeMembersEmail = [];
  bool expenseSplitWithExistingMembers = false;
  List<TextEditingController> _amountRangeValues = [
    new TextEditingController(text: "0"),
    new TextEditingController(text: "100000")
  ];
  List<String> transactionType = ["Credit", "Debit"];
  List<String> bankNameFound = [];
  List<String> transactionMode = [];
  Set<int> allBanksIndex = Set();
  int lenDenIndex = 0;
  Set<int> transactionTypeIndex = Set();
  Set<int> transactionModeIndex = Set();
  List<dynamic> roomData = [];
  List<dynamic> LenDenData = [];
  bool showFilterResult = false;
  GlobalKey<FormState> _formKeyBankTrans = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeyRoomBankTrans = GlobalKey<FormState>();
  GlobalKey<FormState> _formKeyLenDenBankTrans = GlobalKey<FormState>();
  TextEditingController _purpose = TextEditingController();
  TextEditingController _lenDenRoom = TextEditingController();
  String LenDenRoomID = "";
  List<dynamic> roomMembers = [];
  List<String> addExpenseTo = [];
  bool isSplitMemberLoading = false;
  bool filterDialog = false;
  Set<int> filtercategoryIndex = Set();
  bool dataFetched = false;
  DateTimeRange dateRange = DateTimeRange(
      start: new DateTime(DateTime.now().year, DateTime.now().month),
      end: DateTime.now());

  List<TransactionEach> filteredResult = [];
  bool isClosedany = false;

  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;
  bool splitManually = false;
  bool noSplit = false;
  Map<String, Map<String, dynamic>> manualSplitMembers = {};
  Map<String, double> manualSplitAmount = {};

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

  Future<void> getExpenseCategory() async {
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email),
      };

      final response =
          await createHTTPreq('profile', http.patch, _token, jsonInputData);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        expenseCategory.clear();
        subCategory.clear();
        Map<dynamic, dynamic> categoryMap = data['expenseCategory'];
        categoryMap.forEach((key, value) {
          expenseCategory.add(key);
          subCategory.add(value);
        });
      }
    } on Exception catch (err, stackTrace) {
      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["Expenses->getExpenseCategory"]);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getLenDenData() async {
    try {
      Map<String, String> jsonInputData = {"email": crypto.encrypt(_email)};
      final response =
          await createHTTPreq('lend', http.patch, _token, jsonInputData);

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
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["BankTransaction->getLenDenData"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getActiveRooms() async {
    try {
      Map<String, String> jsonInputData = {"email": crypto.encrypt(_email)};
      final response = await createHTTPreq(
          'room/fullActiveRoom', http.post, _token, jsonInputData);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        roomData = data['data'];
        if (roomData.isNotEmpty) {
          await getMembers(roomData[0]['Key']);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["BankTransaction->getActiveRooms"]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getMembers(String roomkey) async {
    if (this.mounted) {
      setState(() {
        addExpenseTo.clear();
        roomClosedCount = 0;
        activeMembersEmail.clear();
        isClosedany = false;
        isSplitMemberLoading = true;
        manualSplitMembers.clear();
      });
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': roomkey
      };
      final response = await createHTTPreq(
          'room/roomSplitMembers', http.post, _token, jsonInputData);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        roomMembers = data['data'];
        roomMembers.forEach((element) {
          if (element['done']) {
            expenseSplitWithExistingMembers = true;
            roomClosedCount++;
            isClosedany = true;
          } else if (crypto.decrypt(element['email']) != _email) {
            activeMembersEmail.add(crypto.decrypt(element['email']));
          }
          if (!element['done']) {
            manualSplitMembers[crypto.decrypt(element["email"])] = {
              "Name": crypto.decrypt(element["Name"]),
              "Email": crypto.decrypt(element["email"]),
              "Pic": crypto.decrypt(element["pic"]),
            };
          }
        });
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["BankTransaction->getMembers"]);
      }
    }

    isSplitMemberLoading = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> executeParallel() async {
    dataFetched = false;
    if (this.mounted) {
      setState(() {});
    }
    await Future.wait(
        [getExpenseCategory(), getAllSms(), getActiveRooms(), getLenDenData()]);

    dataFetched = true;
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getAllSms() async {
    if (this.mounted) {
      setState(() {});
    }

    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );
      _messages = messages;
      List<dynamic> temp = await filterSMS(_messages);
      allTransactions = temp[0];
      bankNameFound = temp[1];
      transactionMode = temp[2];
      allTransactions.sort((b, a) {
        DateTime tempDate_1 =
            new DateFormat("MMM dd yyyy h:mm a").parse(a.date);
        DateTime tempDate_2 =
            new DateFormat("MMM dd yyyy h:mm a").parse(b.date);
        return tempDate_1.compareTo(tempDate_2);
      });
    } else {
      await Permission.sms.request();
      permissionGranted = await Permission.sms.isDenied;

      if (!permissionGranted) {
        await getAllSms();
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  AddExpense(BuildContext context, String amount, String date) async {
    var Tdata = null;
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'purpose': crypto.encrypt(_purpose.text),
        'amt': crypto.encrypt(amount),
        'date': crypto.encrypt(date),
        'type': crypto.encrypt(expenseCategory[categoryIndex]),
        'subType': crypto.encrypt(subCategory[categoryIndex].length > 0
            ? subCategory[categoryIndex][subCategoryIndex]
            : "None"),
      };
      final response = await createHTTPreq(
          'ptransaction', http.patch, _token, jsonInputData);

      _purpose.text = "";
      Tdata = jsonDecode(response.body);

      for (int i = 0; i < 3 && context.canPop(); i++) {
        if (this.mounted) {
          context.pop();
        }
      }

      if (response.statusCode == 422) {
        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
      } else {
        showToast(context, "Expense Added Successfully", Icons.check);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["BankTransaction->AddExpense"]);
      }
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
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKeyBankTrans,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _purpose,
                        keyboardType: TextInputType.text,
                        maxLength: 1000,
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
                          itemCount: expenseCategory.length,
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
                                            expenseCategory[index],
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
                      subCategory[categoryIndex].length > 0
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.96,
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: subCategory[categoryIndex].length,
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
                                                color: index == subCategoryIndex
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
                                                  subCategory[categoryIndex]
                                                      [index],
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
                                                subCategoryIndex = index;
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
                              if (_formKeyBankTrans.currentState!.validate()) {
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
      if (this.mounted) {
        buildShowDialog(context);
      }

      Map<String, String> jsonInputData = {
        "email": crypto.encrypt(_email),
        "name": crypto.encrypt(_lenDenRoom.text)
      };

      final response =
          await createHTTPreq('lend', http.post, _token, jsonInputData);

      if (response.statusCode == 200) {
        LenDenRoomID = jsonDecode(response.body)["id"];
        _lenDenRoom.text = "";
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']),
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error",
            info: ["BankTransaction->createLenDenRoom"]);
      }
    }

    if (this.mounted) {
      context.pop();
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  AddExpenseManual(BuildContext context, String date) async {
    var Tdata = null;
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': roomData[roomIndex]["Key"],
        'purpose': crypto.encrypt(_purpose.text),
        'date': crypto.encrypt(date),
        'type': crypto.encrypt(expenseCategory[roomCategoryIndex]),
        'subType': crypto.encrypt(subCategory[roomCategoryIndex].length > 0
            ? subCategory[roomCategoryIndex][subCategoryIndex]
            : "None"),
        'split': crypto.encrypt(manualSplitAmount.toString())
      };

      final response =
          await createHTTPreq('manualSplit', http.post, _token, jsonInputData);

      _purpose.text = "";
      Tdata = jsonDecode(response.body);

      for (int i = 0; i < 3 && context.canPop(); i++) {
        if (this.mounted) {
          context.pop();
        }
      }

      if (splitManually && this.mounted) {
        context.pop();
      }

      if (response.statusCode == 422) {
        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
      } else {
        showToast(context, "Expense Added Successfully", Icons.check);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }

      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error",
            info: ["BankTransaction->AddExpenseManual"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  AddLenDen(BuildContext context, String amount, String date, String id) async {
    if (_formKeyLenDenBankTrans.currentState!.validate()) {
      var Tdata = null;
      if (this.mounted) {
        buildShowDialog(context);
      }

      try {
        Map<String, String> jsonInputData = {
          'email': crypto.encrypt(_email),
          'key': id,
          'purpose': crypto.encrypt(_purpose.text),
          'amount': crypto.encrypt(amount),
          "date": crypto.encrypt(date)
        };

        final response =
            await createHTTPreq('lend', http.delete, _token, jsonInputData);

        _purpose.text = "";
        Tdata = jsonDecode(response.body);
        for (int i = 0; i < 3 && context.canPop(); i++) {
          if (this.mounted) {
            context.pop();
          }
        }

        if (response.statusCode == 422) {
          showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
        } else {
          showToast(context, "Expense Added Successfully", Icons.check);
        }
      } on Exception catch (err, stackTrace) {
        if (this.mounted) {
          onException(context, err, stackTrace,
              reason: "Unknwon Error", info: ["BankTransaction->AddLenDen"]);
        }
      }
      LenDenRoomID = "";
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  AddRoomExpense(BuildContext context, String amount, String date) async {
    if (_formKeyRoomBankTrans.currentState!.validate()) {
      var Tdata = null;
      if (this.mounted) {
        buildShowDialog(context);
      }

      try {
        Map<String, String> jsonInputData = {
          'email': crypto.encrypt(_email),
          'roomKey': roomData[roomIndex]["Key"],
          'purpose': crypto.encrypt(_purpose.text),
          'amt': crypto.encrypt(amount),
          'type': crypto.encrypt(expenseCategory[roomCategoryIndex]),
          'subType': crypto.encrypt(subCategory[roomCategoryIndex].length > 0
              ? subCategory[roomCategoryIndex][subCategoryIndex]
              : "None"),
          "members": crypto.encrypt(((addExpenseTo.isEmpty &&
                  (isClosedany || expenseSplitWithExistingMembers))
              ? activeMembersEmail.toString()
              : addExpenseTo.toString())),
          "date": crypto.encrypt(date)
        };

        final response =
            await createHTTPreq('data', http.delete, _token, jsonInputData);

        _purpose.text = "";
        Tdata = jsonDecode(response.body);
        for (int i = 0; i < 3 && context.canPop(); i++) {
          if (this.mounted) {
            context.pop();
          }
        }

        if (response.statusCode == 422) {
          showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
        } else {
          showToast(context, "Expense Added Successfully", Icons.check);
        }
      } on Exception catch (err, stackTrace) {
        if (this.mounted) {
          context.pop();
        }

        if (this.mounted) {
          onException(context, err, stackTrace,
              reason: "Unknwon Error",
              info: ["BankTransaction->AddRoomExpense"]);
        }
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
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKeyLenDenBankTrans,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _purpose,
                        keyboardType: TextInputType.text,
                        maxLength: 1000,
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
                              maxLength: 1000,
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
                              if (_formKeyLenDenBankTrans.currentState!
                                  .validate()) {
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

  splitManuallyWidget(BuildContext context, String date, String amount) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    GlobalKey<FormState> _manualSplitKeyBankTrans = GlobalKey<FormState>();
    List<TextEditingController> amountController = [];
    for (int i = 0; i < manualSplitAmount.length; i++) {
      amountController.add(TextEditingController(text: "0"));
    }
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: SizedBox(
                    width: kIsWeb
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.95,
                    child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Total Amount: ₹ " + amount,
                              style: TextStyle(fontSize: 14),
                            ),
                            Form(
                              key: _manualSplitKeyBankTrans,
                              child: SizedBox(
                                height: min(75.0 * manualSplitAmount.length,
                                    MediaQuery.of(context).size.height * 0.8),
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: manualSplitAmount.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key = "";
                                    if (addExpenseTo.isEmpty) {
                                      if (index == activeMembersEmail.length) {
                                        key = _email;
                                      } else {
                                        key = activeMembersEmail[index];
                                      }
                                    } else {
                                      if (index == addExpenseTo.length) {
                                        key = _email;
                                      } else {
                                        key = addExpenseTo[index];
                                      }
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.all(11.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CachedNetworkImage(
                                                httpHeaders: {
                                                  'Access-Control-Allow-Origin':
                                                      '*'
                                                },
                                                imageUrl: addCorsinImage(
                                                    manualSplitMembers[key]![
                                                                    'Pic']
                                                                .length ==
                                                            0
                                                        ? global.driveUrl +
                                                            "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                        : manualSplitMembers[
                                                            key]!['Pic']),
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
                                                  width: 40.0,
                                                  height: 40.0,
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
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 6,
                                              ),
                                              InkWell(
                                                onTap: () => showToast(
                                                    context,
                                                    manualSplitMembers[key]![
                                                        'Name'],
                                                    Icons.person_outlined),
                                                child: SizedBox(
                                                  width: 130,
                                                  child: Text(
                                                    manualSplitMembers[key]![
                                                        'Name'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "₹",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              SizedBox(
                                                width: 50,
                                                child: TextFormField(
                                                  controller:
                                                      amountController[index],
                                                  keyboardType:
                                                      TextInputType.number,
                                                  maxLines: 1,
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                  autocorrect: false,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    counterText: "",
                                                    errorStyle: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  validator: (value) {
                                                    if (key == _email) {
                                                      if (amountController[
                                                                  index]
                                                              .text ==
                                                          "0") {
                                                        manualSplitAmount[
                                                            key] = double.parse(
                                                                amountController[
                                                                        index]
                                                                    .text) *
                                                            100 /
                                                            100;
                                                        return null;
                                                      }
                                                    }
                                                    RegExp validateText = RegExp(
                                                        r"^[1-9]\d*(\.\d+)?$");
                                                    if (!validateText.hasMatch(
                                                        amountController[index]
                                                            .text)) {
                                                      return "";
                                                    } else {
                                                      manualSplitAmount[
                                                          key] = double.parse(
                                                              amountController[
                                                                      index]
                                                                  .text) *
                                                          100 /
                                                          100;
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 43,
                                    width: 100,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: themeProvider.isDarkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        onPressed: () {
                                          if (this.mounted) {
                                            context.pop();
                                          }
                                        }),
                                  ),
                                  SizedBox(
                                    height: 43,
                                    width: 100,
                                    child: OutlinedButton(
                                        child: Text(
                                          "Add",
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
                                          if (_manualSplitKeyBankTrans
                                              .currentState!
                                              .validate()) {
                                            double tempAmount = 0;
                                            manualSplitAmount
                                                .forEach((key, value) {
                                              tempAmount += value;
                                            });
                                            tempAmount = double.parse(amount) -
                                                tempAmount;
                                            if (tempAmount.abs() >= 1) {
                                              showToast(
                                                  context,
                                                  "₹ " +
                                                      tempAmount.toString() +
                                                      " not splitted properly",
                                                  Icons.warning_outlined);
                                            } else {
                                              AddExpenseManual(context, date);
                                            }
                                          } else {
                                            showToast(context, "Invalid Amount",
                                                Icons.warning_outlined);
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ))));
          });
        });
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
              width: kIsWeb
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.9,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Form(
                  key: _formKeyRoomBankTrans,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _purpose,
                        keyboardType: TextInputType.text,
                        maxLength: 1000,
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
                          itemCount: expenseCategory.length,
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
                                            expenseCategory[index],
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
                                          subCategoryIndex = 0;
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
                      subCategory[roomCategoryIndex].length > 0
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.96,
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    subCategory[roomCategoryIndex].length,
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
                                                color: index == subCategoryIndex
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
                                                  subCategory[roomCategoryIndex]
                                                      [index],
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
                                                subCategoryIndex = index;
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
                      isSplitMemberLoading
                          ? CircularProgressIndicator.adaptive()
                          : (noSplit
                              ? SizedBox()
                              : SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: roomMembers.length + 1,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index == 0) {
                                        return InkWell(
                                          child: SizedBox(
                                            width: 85,
                                            child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Card(
                                                    color: Theme.of(context)
                                                        .dialogBackgroundColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: addExpenseTo
                                                                  .isEmpty
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Theme.of(
                                                                      context)
                                                                  .cardColor),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                    ),
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
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
                                      } else if (roomMembers[index - 1]
                                              ['done'] ||
                                          crypto.decrypt(roomMembers[index - 1]
                                                  ['email']) ==
                                              _email) {
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
                                                                roomMembers[
                                                                        index -
                                                                            1]
                                                                    ['email']))
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .cardColor),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    CachedNetworkImage(
                                                      httpHeaders: {
                                                        'Access-Control-Allow-Origin':
                                                            '*'
                                                      },
                                                      imageUrl: crypto
                                                                  .decrypt(roomMembers[
                                                                          index -
                                                                              1]
                                                                      ['pic'])
                                                                  .length ==
                                                              0
                                                          ? global.driveUrl +
                                                              "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                          : crypto.decrypt(
                                                              roomMembers[
                                                                      index - 1]
                                                                  ['pic']),
                                                      progressIndicatorBuilder: (context,
                                                              url,
                                                              downloadProgress) =>
                                                          CircularProgressIndicator(
                                                              value:
                                                                  downloadProgress
                                                                      .progress),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Container(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  'assets/Images/unknown.jpeg'),
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 50.0,
                                                        height: 50.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
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
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                              addExpenseTo.remove(
                                                  crypto.decrypt(
                                                      roomMembers[index - 1]
                                                          ['email']));
                                            } else {
                                              addExpenseTo.add(crypto.decrypt(
                                                  roomMembers[index - 1]
                                                      ['email']));

                                              if (addExpenseTo.length ==
                                                  roomMembers.length -
                                                      roomClosedCount -
                                                      1) {
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
                                )),
                      (addExpenseTo.isEmpty &&
                              !isClosedany &&
                              !splitManually &&
                              !noSplit)
                          ? SizedBox(
                              height: 7,
                            )
                          : SizedBox(),
                      (addExpenseTo.isEmpty &&
                              !isClosedany &&
                              !splitManually &&
                              !noSplit)
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "For New Members",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (this.mounted) {
                                        setState(() {
                                          expenseSplitWithExistingMembers =
                                              !expenseSplitWithExistingMembers;
                                        });
                                      }
                                    },
                                    child: Icon(
                                      expenseSplitWithExistingMembers
                                          ? Icons.toggle_off
                                          : Icons.toggle_on,
                                      size: 40,
                                      color: expenseSplitWithExistingMembers
                                          ? null
                                          : Theme.of(context).primaryColor,
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 7,
                      ),
                      splitManually
                          ? SizedBox()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "No Split",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (this.mounted) {
                                        setState(() {
                                          noSplit = !noSplit;
                                          if (noSplit) {
                                            splitManually = false;
                                          }
                                        });
                                      }
                                    },
                                    child: Icon(
                                      noSplit
                                          ? Icons.toggle_on
                                          : Icons.toggle_off,
                                      size: 40,
                                      color: noSplit
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                  )
                                ],
                              ),
                            ),
                      SizedBox(
                        height: 7,
                      ),
                      noSplit
                          ? SizedBox()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Split Manually",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (this.mounted) {
                                        setState(() {
                                          splitManually = !splitManually;
                                          if (splitManually) {
                                            noSplit = false;
                                          }
                                        });
                                      }
                                    },
                                    child: Icon(
                                      splitManually
                                          ? Icons.toggle_on
                                          : Icons.toggle_off,
                                      size: 40,
                                      color: splitManually
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                  )
                                ],
                              ),
                            ),
                      SizedBox(
                        height: 45,
                        width: 90,
                        child: OutlinedButton(
                            child: Text(
                              splitManually ? "Next" : "Add",
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
                              if (noSplit) {
                                if (_formKeyRoomBankTrans.currentState!
                                    .validate()) {
                                  manualSplitAmount.clear();
                                  manualSplitAmount[_email] =
                                      (double.parse(amount) * 100) / 100;
                                  AddExpenseManual(context, date);
                                }
                              } else if (splitManually) {
                                RegExp validateText = RegExp(r'\b[\w]+\b');
                                if (!validateText.hasMatch(_purpose.text)) {
                                  showToast(context, "Enter Valid Purpose",
                                      Icons.warning_outlined);
                                } else {
                                  manualSplitAmount.clear();
                                  if (addExpenseTo.isEmpty) {
                                    manualSplitMembers.forEach((k, v) {
                                      manualSplitAmount[k] = 0;
                                    });
                                  } else {
                                    addExpenseTo.forEach((element) {
                                      manualSplitAmount[element] = 0;
                                    });
                                  }

                                  manualSplitAmount[_email] = 0;
                                  splitManuallyWidget(context, date, amount);
                                }
                              } else {
                                if (_formKeyRoomBankTrans.currentState!
                                    .validate()) {
                                  AddRoomExpense(context, amount, date);
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
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.white,
                  )
                : ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
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
                    width: kIsWeb
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.9,
                    height: roomData.isNotEmpty
                        ? 245
                        : (expenseCategory.length == 0 ? 145 : 185),
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
                            expenseCategory.length == 0
                                ? SizedBox()
                                : SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width *
                                        0.85,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        if (this.mounted) {
                                          setState(() {
                                            categoryIndex = 0;
                                            subCategoryIndex = 0;
                                            roomCategoryIndex = 0;
                                          });
                                        }
                                        showPersonalExpenseDialog(amount, date);
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
                                        if (this.mounted) {
                                          setState(() {
                                            categoryIndex = 0;
                                            subCategoryIndex = 0;
                                            roomCategoryIndex = 0;
                                          });
                                        }
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
          String bankName = bankNameFound[abElement];

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

  initialisation() async {
    var tokenData = await getStringPref('token');

    if (tokenData != null) {
      Map<String, dynamic> jsonOutData = parseJWT(tokenData.toString());
      if (this.mounted) {
        setState(() {
          _email = jsonOutData["email"]!;
          _token = jsonOutData["token"]!;
        });
      }

      executeParallel();
    }
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
    initialisation();
  }

  @override
  Widget build(BuildContext context) {
    double drawerWidth = MediaQuery.of(context).size.width * 0.75;
    int crossAxisCountFilter = (drawerWidth / 110).round();
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Transactions"),
        actions: bankNameFound.isEmpty
            ? []
            : [
                IconButton(
                    onPressed: () {
                      filterDialog =
                          _scaffoldKeyBankTrans.currentState!.isEndDrawerOpen;
                      filterDialog = !filterDialog;

                      if (filterDialog) {
                        _scaffoldKeyBankTrans.currentState!.openEndDrawer();
                      } else {
                        _scaffoldKeyBankTrans.currentState!.closeEndDrawer();
                      }
                    },
                    icon: Icon(Icons.filter_alt_outlined))
              ],
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
      body: Scaffold(
        key: _scaffoldKeyBankTrans,
        endDrawer: bankNameFound.isEmpty
            ? null
            : Drawer(
                width: MediaQuery.of(context).size.width * 0.75,
                backgroundColor: themeProvider.isDarkTheme
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      scrollDirection: Axis.vertical,
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
                                height: 10,
                              ),
                              SizedBox(
                                height: 51.5 *
                                    (bankNameFound.length /
                                            crossAxisCountFilter)
                                        .round(),
                                child: MasonryGridView.count(
                                    crossAxisCount: crossAxisCountFilter,
                                    itemCount: bankNameFound.length,
                                    itemBuilder: ((context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (allBanksIndex.contains(index)) {
                                            allBanksIndex.remove(index);
                                          } else {
                                            allBanksIndex.add(index);
                                          }

                                          if (this.mounted) {
                                            setState(() {});
                                          }
                                        },
                                        child: Card(
                                            elevation: 1.0,
                                            color: themeProvider.isDarkTheme
                                                ? Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: allBanksIndex
                                                          .contains(index)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .cardColor),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child:
                                                    Text(bankNameFound[index]),
                                              ),
                                            )),
                                      );
                                    })),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Divider(),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                "Type",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 50,
                                child: MasonryGridView.count(
                                    crossAxisCount: 2,
                                    itemCount: transactionType.length,
                                    itemBuilder: ((context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (transactionTypeIndex
                                              .contains(index)) {
                                            transactionTypeIndex.remove(index);
                                          } else {
                                            transactionTypeIndex.add(index);
                                          }

                                          if (this.mounted) {
                                            setState(() {});
                                          }
                                        },
                                        child: SizedBox(
                                          width: 90,
                                          child: Card(
                                              elevation: 1.0,
                                              color: themeProvider.isDarkTheme
                                                  ? Theme.of(context)
                                                      .scaffoldBackgroundColor
                                                  : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: transactionTypeIndex
                                                            .contains(index)
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .cardColor),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Text(
                                                      transactionType[index]),
                                                ),
                                              )),
                                        ),
                                      );
                                    })),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Divider(),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                "Mode",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height: 51.5 *
                                    (transactionMode.length /
                                            crossAxisCountFilter)
                                        .round(),
                                child: MasonryGridView.count(
                                    crossAxisCount: crossAxisCountFilter,
                                    itemCount: transactionMode.length,
                                    itemBuilder: ((context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (transactionModeIndex
                                              .contains(index)) {
                                            transactionModeIndex.remove(index);
                                          } else {
                                            transactionModeIndex.add(index);
                                          }

                                          if (this.mounted) {
                                            setState(() {});
                                          }
                                        },
                                        child: Card(
                                            elevation: 1.0,
                                            color: themeProvider.isDarkTheme
                                                ? Theme.of(context)
                                                    .scaffoldBackgroundColor
                                                : Colors.white,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: transactionModeIndex
                                                          .contains(index)
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .cardColor),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Text(
                                                    transactionMode[index]),
                                              ),
                                            )),
                                      );
                                    })),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Divider(),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                "Amount",
                                style: TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
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
                                                    offset:
                                                        _amountRangeValues[0]
                                                            .text
                                                            .length);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
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
                                                    offset:
                                                        _amountRangeValues[1]
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
                                height: 3,
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Date",
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  IconButton(
                                      onPressed: pickDateRange,
                                      icon: Icon(Icons.date_range)),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: pickDateRange,
                                    child: Card(
                                      elevation: 1,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Theme.of(context).cardColor),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            DateFormat('dd MMM, yyyy')
                                                .format(dateRange.start),
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 35,
                                    child: Text("-",
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                  Card(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Theme.of(context).cardColor),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: InkWell(
                                          onTap: pickDateRange,
                                          child: Text(
                                              DateFormat('dd MMM, yyyy')
                                                  .format(dateRange.end),
                                              style: TextStyle(fontSize: 18)),
                                        ),
                                      ),
                                    ),
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
                              _scaffoldKeyBankTrans.currentState!
                                  .closeEndDrawer();
                              await getFilterResult();
                              if (this.mounted) {
                                setState(() {});
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
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
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () {
                              showFilterResult = false;
                              transactionModeIndex.clear();
                              transactionTypeIndex.clear();
                              _amountRangeValues[0].text = "0";
                              _amountRangeValues[1].text = "10000";
                              dateRange = DateTimeRange(
                                  start: new DateTime(DateTime.now().year,
                                      DateTime.now().month),
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
              ),
        body: PopScope(
          canPop: true,
          child: SizedBox(
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
                                  if (this.mounted) {
                                    context.pop();
                                  }
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
                    key: _refreshIndicatorKeyBankTrans,
                    onRefresh: executeParallel,
                    child: dataFetched
                        ? (allTransactions.isEmpty
                            ? ListView(
                                physics: AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.8,
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
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return SizedBox(
                                                  child: Card(
                                                    elevation: 1.0,
                                                    shadowColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: filteredResult[
                                                                          index]
                                                                      .type ==
                                                                  "Credit"
                                                              ? Colors
                                                                  .greenAccent
                                                              : Colors
                                                                  .redAccent),
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
                                                              InkWell(
                                                                onTap:
                                                                    () async {
                                                                  showToast(
                                                                      context,
                                                                      filteredResult[
                                                                              index]
                                                                          .receiver,
                                                                      Icons
                                                                          .done_outlined);
                                                                },
                                                                child: SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.7,
                                                                  child: Text(
                                                                    filteredResult[
                                                                            index]
                                                                        .receiver,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            24),
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                              filteredResult[index]
                                                                          .type ==
                                                                      "Credit"
                                                                  ? SizedBox()
                                                                  : IconButton(
                                                                      onPressed:
                                                                          () {
                                                                        showAddDialog(
                                                                            filteredResult[index].amount,
                                                                            filteredResult[index].date,
                                                                            filteredResult[index].receiver);
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        color: filteredResult[index].type ==
                                                                                "Credit"
                                                                            ? Colors.greenAccent
                                                                            : Colors.redAccent,
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
                                                                        filteredResult[index]
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
                                                                        filteredResult[index]
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
                                                                      height:
                                                                          30,
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
                                                                  fontSize:
                                                                      17)),
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
                                                      color: allTransactions[
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
                                                  padding: const EdgeInsets.all(
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
                                                          InkWell(
                                                            onTap: () async {
                                                              showToast(
                                                                  context,
                                                                  allTransactions[
                                                                          index]
                                                                      .receiver,
                                                                  Icons
                                                                      .done_outlined);
                                                            },
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                              child: Text(
                                                                allTransactions[
                                                                        index]
                                                                    .receiver,
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        24),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                          allTransactions[index]
                                                                      .type ==
                                                                  "Credit"
                                                              ? SizedBox()
                                                              : IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    showAddDialog(
                                                                        allTransactions[index]
                                                                            .amount,
                                                                        allTransactions[index]
                                                                            .date,
                                                                        allTransactions[index]
                                                                            .receiver);
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.add,
                                                                    color: allTransactions[index].type ==
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
                                                              alignment:
                                                                  Alignment
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
                                                                            ? Colors.greenAccent
                                                                            : Colors.redAccent,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(12))),
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
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: allTransactions[index].type ==
                                                                                "Credit"
                                                                            ? Colors.greenAccent
                                                                            : Colors.redAccent,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(12))),
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
                                                                        allTransactions[index]
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
                                                            allTransactions[
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
                                                            allTransactions[
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                  borderRadius:
                                                      BorderRadius.all(
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
      ),
    );
  }
}
