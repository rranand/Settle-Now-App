import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/internetConnectivity.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:shimmer/shimmer.dart';
import '../contents.dart' as global;

class Expenses extends StatefulWidget {
  final String date;

  const Expenses({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  String dateFromUrl = "";
  String _email = "";
  String _token = "";
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> TransList = [];
  bool filterDialog = false;
  bool showFilterResult = false;
  List<dynamic> filterResult = [];
  TextEditingController _amt = TextEditingController();
  TextEditingController _purpose = TextEditingController();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool loaded = false;
  String title = "Personal Expense";
  Set<int> filtercategoryIndex = Set();
  int categoryIndex = 0;
  int subCategoryIndex = 0;
  String Curdate = "";
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<FormState> _updateExpense = GlobalKey<FormState>();
  DateTime expensedate = DateTime.now();
  List<dynamic> expenseCategory = [];
  List<List<dynamic>> subCategory = [];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getExpenseCategory() async {
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email),
      };

      final response = await createHTTPreq(
          'profile', http.patch, _token, jsonInputData, context);

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

  Future _initialization() async {
    loaded = false;

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

    getExpenseCategory();
    var now = DateTime.now();
    Curdate = (now.month - 1).toString() + now.year.toString();

    String yr = "";
    String mn = "";

    for (int i = widget.date.length - 1; i >= 0; i--) {
      if (yr.length != 4) {
        yr = widget.date[i] + yr;
      } else {
        mn = widget.date[i] + mn;
      }
    }
    var isPossibleDate = DateTime(int.parse(yr), int.parse(mn) + 1);
    if (isPossibleDate.month != int.parse(mn) + 1 ||
        isPossibleDate.year != int.parse(yr)) {
      context.go(AppRouteConstants.errorPageRouteName);
      return;
    }
    dateFromUrl =
        (isPossibleDate.month - 1).toString() + isPossibleDate.year.toString();
    title = global.Month[int.parse(mn)] + ", " + yr;

    if (this.mounted) {
      setState(() {});
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'date': crypto.encrypt(dateFromUrl),
      };

      final response = await createHTTPreq(
          'ptransaction', http.post, _token, jsonInputData, context);

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        TransList = jsonDecode(response.body)['data'];
      } else if (response.statusCode == 503) {
        while (context.canPop()) {
          if (this.mounted) {
            context.pop();
          }
        }
        context.push(AppRouteConstants.maintainRouteName);
      } else {
        showToast(
            context,
            TransData["Message"]
                ? crypto.decrypt(TransData["Message"])
                : "Some Unknown Error Occurred",
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Expenses->_initialization"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  removeRoomTransaction(String id, int index, bool isRoom) async {
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'id': crypto.encrypt(id),
        'isRoom': crypto.encrypt(isRoom ? "1" : "0")
      };

      final response = await createHTTPreq('transaction/personalExpense',
          http.delete, _token, jsonInputData, context);

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        TransList.removeAt(index);
      }
      showToast(context, crypto.decrypt(TransData["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Expenses->removeRoomTransaction"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  updatePersonalTransaction(
      String purpose, String amount, String flag, String id, int index) async {
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'purpose': crypto.encrypt(purpose),
        'amount': crypto.encrypt(amount),
        'flag': crypto.encrypt(flag),
        'id': crypto.encrypt(id)
      };

      final response = await createHTTPreq(
          'ptransaction', http.put, _token, jsonInputData, context);

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (flag == "1") {
          TransList.removeAt(index);
        } else {
          TransList[index]['amount'] = crypto.encrypt(amount);
          TransList[index]['purpose'] = crypto.encrypt(purpose);
          TransList[index]['isEdited'] = true;
          TransList[index]['lastModDate'] = crypto.encrypt(
              DateFormat(global.dateTimeFormat).format(DateTime.now()));
        }
      }
      showToast(context, crypto.decrypt(TransData["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error",
            info: ["Expenses->updatePersonalTransaction"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Widget _buildUpdateDialog(BuildContext context, String id, String purpose,
      String amount, int index) {
    TextEditingController _updatepurpose = TextEditingController();
    TextEditingController _updateamount = TextEditingController();

    return StatefulBuilder(builder: (context, setState) {
      _updateamount.text = amount.substring(2);
      _updatepurpose.text = purpose;

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
                      key: _updateExpense,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _updateamount,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateNumber =
                                  RegExp(r'^\d+(\.\d{1,2})?$');
                              if (!validateNumber
                                  .hasMatch(_updateamount.text)) {
                                return "Enter Valid amount";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.all(8.0),
                              hintText: "Enter amount",
                              labelText: "amount",
                              errorStyle: TextStyle(fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _updatepurpose,
                            keyboardType: TextInputType.text,
                            maxLength: 1000,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateText = RegExp(r'\b[\w]+\b');
                              if (!validateText.hasMatch(_updatepurpose.text)) {
                                return "Enter Valid purpose";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              counterText: "",
                              contentPadding: EdgeInsets.all(8.0),
                              hintText: "Enter purpose",
                              labelText: "purpose",
                              errorStyle: TextStyle(fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: OutlinedButton(
                                child: Text(
                                  "Update",
                                  style: TextStyle(
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
                                    if (this.mounted) {
                                      buildShowDialog(context);
                                    }
                                    await updatePersonalTransaction(
                                        _updatepurpose.text,
                                        _updateamount.text,
                                        "0",
                                        id,
                                        index);
                                    for (int i = 0;
                                        i < 3 && context.canPop();
                                        i++) {
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                    }
                                  }
                                }),
                          ),
                        ],
                      ),
                    ))),
          ));
    });
  }

  Widget _buildPopupDialog(
      BuildContext context,
      int index,
      String purpose,
      String type,
      String date,
      String amount,
      bool room,
      bool quickSplit,
      String id,
      String roomExpensetype,
      String subroomExpensetype,
      bool isEdited,
      String lastModDate) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: kIsWeb
            ? max(MediaQuery.of(context).size.width * 0.5,
                min(400, MediaQuery.of(context).size.width * 0.96))
            : MediaQuery.of(context).size.width * 0.96,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: (kIsWeb
                            ? max(
                                MediaQuery.of(context).size.width * 0.5,
                                min(400,
                                    MediaQuery.of(context).size.width * 0.96))
                            : MediaQuery.of(context).size.width * 0.96) -
                        200,
                    child: Text(
                      purpose,
                      style: TextStyle(fontSize: 26),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 6,
                    ),
                  ),
                  Curdate == dateFromUrl
                      ? ((quickSplit || room)
                          ? IconButton(
                              onPressed: () async {
                                if (this.mounted) {
                                  buildShowDialog(context);
                                }
                                await removeRoomTransaction(id, index, room);
                                if (this.mounted) {
                                  context.pop();
                                }
                                if (this.mounted) {
                                  context.pop();
                                }
                              },
                              icon: Icon(Icons.delete))
                          : Row(
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      if (this.mounted) {
                                        buildShowDialog(context);
                                      }
                                      await updatePersonalTransaction(
                                          purpose, amount, "1", id, index);
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                    },
                                    icon: Icon(Icons.delete)),
                                IconButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            _buildUpdateDialog(context, id,
                                                purpose, amount, index),
                                      );
                                    },
                                    icon: Icon(Icons.edit)),
                              ],
                            ))
                      : SizedBox()
                ],
              ),
              isEdited
                  ? SizedBox(
                      height: 6,
                    )
                  : SizedBox(
                      height: 25,
                    ),
              isEdited
                  ? Container(
                      width: 55,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: themeProvider.isDarkTheme
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text("Edited",
                            style:
                                TextStyle(fontSize: 13, color: Colors.white)),
                      ))
                  : SizedBox(),
              isEdited
                  ? SizedBox(
                      height: 6,
                    )
                  : SizedBox(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  room
                      ? Text(
                          "Type: " + type + " (Room)",
                          style: TextStyle(fontSize: 18),
                        )
                      : type.length == 0
                          ? SizedBox()
                          : Text(
                              "Type: " + type,
                              style: TextStyle(fontSize: 18),
                            ),
                  room || type.length > 0
                      ? SizedBox(
                          height: 10,
                        )
                      : SizedBox(),
                  Text(
                    "Amount: " + amount,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Spent On: " + formatDateTime(date),
                    style: TextStyle(fontSize: 18),
                  ),
                  isEdited
                      ? SizedBox(
                          height: 10,
                        )
                      : SizedBox(),
                  isEdited
                      ? Text("Modified: " + formatDateTime(lastModDate),
                          style: TextStyle(fontSize: 18))
                      : SizedBox(),
                  roomExpensetype.isEmpty
                      ? SizedBox()
                      : (SizedBox(
                          height: 10,
                        )),
                  roomExpensetype.isEmpty
                      ? SizedBox()
                      : (Text(
                          "Category: " +
                              roomExpensetype +
                              (subroomExpensetype.length > 0
                                  ? ' (${subroomExpensetype})'
                                  : ""),
                          style: TextStyle(fontSize: 18),
                        )),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width * 0.95 - 25,
                child: OutlinedButton(
                  child: Text(
                    "Close",
                    style: TextStyle(
                        color: themeProvider.isDarkTheme
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.0),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    if (this.mounted) {
                      context.pop();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AddExpense(BuildContext context) async {
    var Tdata = null;
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'purpose': crypto.encrypt(_purpose.text),
        'amt': crypto.encrypt(_amt.text),
        'type': crypto.encrypt(expenseCategory[categoryIndex]),
        'subType': crypto.encrypt(
            (subCategoryIndex != -1 && subCategory[categoryIndex].length > 0
                ? subCategory[categoryIndex][subCategoryIndex]
                : "None")),
        'date': crypto
            .encrypt(DateFormat("MMM dd yyyy h:mm a").format(expensedate)),
      };

      final response = await createHTTPreq(
          'ptransaction', http.patch, _token, jsonInputData, context);

      Tdata = jsonDecode(response.body);
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        context.pop();
      }

      if (response.statusCode == 200) {
        TransList.insert(0, Tdata['data']);
      }
      _refreshIndicatorKey.currentState?.show();

      if (response.statusCode == 422) {
        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Expenses->AddExpense"]);
      }
    }

    _amt.text = "";
    _purpose.text = "";

    if (this.mounted) {
      setState(() {});
    }
  }

  getFilterResult() {
    if (this.mounted) {
      setState(() {
        filterResult.clear();
      });
    }

    if (filtercategoryIndex.isEmpty) {
      showFilterResult = false;
    } else {
      TransList.forEach((element) {
        if (filtercategoryIndex.contains(
            expenseCategory.indexOf(crypto.decrypt(element['type'])))) {
          filterResult.add(element);
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
    dateFromUrl = widget.date;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final internetConnProvider =
        Provider.of<InternetconnectivityProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: expenseCategory.length == 0
              ? []
              : [
                  IconButton(
                      onPressed: () {
                        filterDialog =
                            _scaffoldKey.currentState!.isEndDrawerOpen;
                        filterDialog = !filterDialog;

                        if (filterDialog) {
                          _scaffoldKey.currentState!.openEndDrawer();
                        } else {
                          _scaffoldKey.currentState!.closeEndDrawer();
                        }
                      },
                      icon: Icon(showFilterResult
                          ? Icons.filter_alt_off
                          : Icons.filter_alt_outlined))
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
                  Text(
                    "Filter by Category",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height:  53 *
                        (expenseCategory.length / 2 +
                            expenseCategory.length % 2),
                    child: MasonryGridView.count(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      itemCount: expenseCategory.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            if (filtercategoryIndex.contains(index)) {
                              filtercategoryIndex.remove(index);
                            } else {
                              filtercategoryIndex.add(index);
                            }
                  
                            if (this.mounted) {
                              setState(() {});
                            }
                          },
                          child: Card(
                            color: themeProvider.isDarkTheme
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: filtercategoryIndex.contains(index)
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).cardColor),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(expenseCategory[index]),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
                      onPressed: () {
                        showFilterResult = true;
                        getFilterResult();
                        _scaffoldKey.currentState!.closeEndDrawer();
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
                        filtercategoryIndex.clear();
                        showFilterResult = false;
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
          body: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _initialization,
              child: TransList.isEmpty
                  ? ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: (Center(
                              child: loaded
                                  ? Text("No Expense Found",
                                      style: TextStyle(
                                        fontSize: 23,
                                      ))
                                  : Shimmer.fromColors(
                                      baseColor: Theme.of(context).cardColor,
                                      highlightColor:
                                          Theme.of(context).primaryColor,
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
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
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
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            width: 240,
                                                            height: 20.0,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20))),
                                                          ),
                                                          SizedBox(
                                                            height: 12,
                                                          ),
                                                          Container(
                                                            width: 150,
                                                            height: 15.0,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20))),
                                                          ),
                                                          SizedBox(
                                                            height: 12,
                                                          ),
                                                          Container(
                                                            width: 280,
                                                            height: 15.0,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20))),
                                                          ),
                                                        ],
                                                      ),
                                                      Container(
                                                        width: 70,
                                                        height: 35.0,
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
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          })),
                            )))
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.all(10.0),
                      child: showFilterResult
                          ? (filterResult.isEmpty
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text("No Expense Found",
                                        style: TextStyle(
                                          fontSize: 23,
                                        )),
                                  ),
                                )
                              : Scrollbar(
                                  radius: Radius.circular(10.0),
                                  thickness: 5.5,
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            height: 5,
                                          ),
                                      shrinkWrap: true,
                                      itemCount: filterResult.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (filterResult[index]['quickSplit']) {
                                          return InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) => _buildPopupDialog(
                                                    context,
                                                    index,
                                                    crypto.decrypt(
                                                        filterResult[index]
                                                            ["purpose"]),
                                                    "Quick Split",
                                                    (crypto.decrypt(
                                                        filterResult[index]
                                                            ["date"])),
                                                    "₹ " +
                                                        commaSeperator(crypto.decrypt(
                                                            filterResult[index]
                                                                ["amount"])),
                                                    filterResult[index]["room"],
                                                    filterResult[index]
                                                        ["quickSplit"],
                                                    crypto.decrypt(
                                                        filterResult[index]
                                                            ["id"]),
                                                    crypto.decrypt(filterResult[index]["type"]),
                                                    crypto.decrypt(filterResult[index]["subType"]),
                                                    filterResult[index]["isEdited"],
                                                    crypto.decrypt(filterResult[index]["lastModDate"])),
                                              );
                                            },
                                            child: SizedBox(
                                              height: 135,
                                              child: Card(
                                                elevation: 2.0,
                                                shadowColor: Theme.of(context)
                                                    .primaryColor,
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withAlpha(95)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.80,
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    crypto.decrypt(
                                                                        filterResult[index]
                                                                            [
                                                                            "purpose"]),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 5,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            23,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Opacity(
                                                                    opacity:
                                                                        0.8,
                                                                    child: Text(
                                                                      crypto.decrypt(filterResult[index]
                                                                              [
                                                                              "type"]) +
                                                                          (crypto.decrypt(filterResult[index]["subType"]).length > 0
                                                                              ? ' (${crypto.decrypt(filterResult[index]["subType"])})'
                                                                              : ""),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Opacity(
                                                                    opacity:
                                                                        0.8,
                                                                    child: Text(
                                                                      "Quick Spilt",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Opacity(
                                                                    opacity:
                                                                        0.8,
                                                                    child: Text(
                                                                      formatDateTime(crypto.decrypt(
                                                                          filterResult[index]
                                                                              [
                                                                              "date"])),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              filterResult[
                                                                          index]
                                                                      [
                                                                      "isEdited"]
                                                                  ? MainAxisAlignment
                                                                      .start
                                                                  : MainAxisAlignment
                                                                      .center,
                                                          children: [
                                                            filterResult[index]
                                                                    ["isEdited"]
                                                                ? SizedBox(
                                                                    height: 8,
                                                                  )
                                                                : SizedBox(),
                                                            filterResult[index]
                                                                    ["isEdited"]
                                                                ? Container(
                                                                    width: 55,
                                                                    height: 30,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.transparent,
                                                                        border: Border.all(
                                                                          color: themeProvider.isDarkTheme
                                                                              ? Theme.of(context).primaryColor
                                                                              : Colors.white,
                                                                        ),
                                                                        borderRadius: BorderRadius.all(Radius.circular(12))),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                      child: Text(
                                                                          "Edited",
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.white)),
                                                                    ))
                                                                : SizedBox(),
                                                            filterResult[index]
                                                                    ["isEdited"]
                                                                ? SizedBox(
                                                                    height: 30,
                                                                  )
                                                                : SizedBox(),
                                                            Expanded(
                                                              flex: 0,
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.2,
                                                                child: Text(
                                                                  "₹ " +
                                                                      commaSeperator(crypto.decrypt(
                                                                          filterResult[index]
                                                                              [
                                                                              "amount"])),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ]),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (filterResult[index]
                                            ["room"]) {
                                          return InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) => _buildPopupDialog(
                                                    context,
                                                    index,
                                                    crypto.decrypt(filterResult[index]
                                                        ["purpose"]),
                                                    crypto.decrypt(
                                                        filterResult[index]
                                                            ["roomName"]),
                                                    (crypto.decrypt(
                                                        filterResult[index]
                                                            ["date"])),
                                                    "₹ " +
                                                        commaSeperator(crypto.decrypt(
                                                            filterResult[index]
                                                                ["amount"])),
                                                    filterResult[index]["room"],
                                                    filterResult[index]
                                                        ["quickSplit"],
                                                    crypto.decrypt(filterResult[index]["id"]),
                                                    crypto.decrypt(filterResult[index]["type"]),
                                                    crypto.decrypt(filterResult[index]["subType"]),
                                                    filterResult[index]["isEdited"],
                                                    crypto.decrypt(filterResult[index]["lastModDate"])),
                                              );
                                            },
                                            child: SizedBox(
                                              height: 135,
                                              child: Card(
                                                elevation: 2.0,
                                                shadowColor: Theme.of(context)
                                                    .primaryColor,
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withAlpha(95)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          flex: 1,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.80,
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text(
                                                                    crypto.decrypt(
                                                                        filterResult[index]
                                                                            [
                                                                            "purpose"]),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 5,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            23,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Opacity(
                                                                    opacity:
                                                                        0.8,
                                                                    child: Text(
                                                                      crypto.decrypt(filterResult[index]
                                                                              [
                                                                              "type"]) +
                                                                          (crypto.decrypt(filterResult[index]["subType"]).length > 0
                                                                              ? ' (${crypto.decrypt(filterResult[index]["subType"])})'
                                                                              : ""),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Opacity(
                                                                    opacity:
                                                                        0.8,
                                                                    child: Text(
                                                                      crypto.decrypt(filterResult[index]
                                                                              [
                                                                              "roomName"]) +
                                                                          " (Room)",
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Opacity(
                                                                    opacity:
                                                                        0.8,
                                                                    child: Text(
                                                                      formatDateTime(crypto.decrypt(
                                                                          filterResult[index]
                                                                              [
                                                                              "date"])),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                        Column(
                                                          mainAxisAlignment:
                                                              filterResult[
                                                                          index]
                                                                      [
                                                                      "isEdited"]
                                                                  ? MainAxisAlignment
                                                                      .start
                                                                  : MainAxisAlignment
                                                                      .center,
                                                          children: [
                                                            filterResult[index]
                                                                    ["isEdited"]
                                                                ? SizedBox(
                                                                    height: 8,
                                                                  )
                                                                : SizedBox(),
                                                            filterResult[index]
                                                                    ["isEdited"]
                                                                ? Container(
                                                                    width: 55,
                                                                    height: 30,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.transparent,
                                                                        border: Border.all(
                                                                          color: themeProvider.isDarkTheme
                                                                              ? Theme.of(context).primaryColor
                                                                              : Colors.white,
                                                                        ),
                                                                        borderRadius: BorderRadius.all(Radius.circular(12))),
                                                                    child: Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                      child: Text(
                                                                          "Edited",
                                                                          style: TextStyle(
                                                                              fontSize: 13,
                                                                              color: Colors.white)),
                                                                    ))
                                                                : SizedBox(),
                                                            filterResult[index]
                                                                    ["isEdited"]
                                                                ? SizedBox(
                                                                    height: 30,
                                                                  )
                                                                : SizedBox(),
                                                            Expanded(
                                                              flex: 0,
                                                              child: SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.2,
                                                                child: Text(
                                                                  "₹ " +
                                                                      commaSeperator(crypto.decrypt(
                                                                          filterResult[index]
                                                                              [
                                                                              "amount"])),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ]),
                                                ),
                                              ),
                                            ),
                                          );
                                        } else {
                                          return InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) => _buildPopupDialog(
                                                    context,
                                                    index,
                                                    crypto.decrypt(
                                                        filterResult[index]
                                                            ["purpose"]),
                                                    "",
                                                    (crypto.decrypt(
                                                        filterResult[index]
                                                            ["date"])),
                                                    "₹ " +
                                                        commaSeperator(crypto.decrypt(
                                                            filterResult[index]
                                                                ["amount"])),
                                                    filterResult[index]["room"],
                                                    filterResult[index]
                                                        ["quickSplit"],
                                                    crypto.decrypt(
                                                        filterResult[index]
                                                            ["id"]),
                                                    crypto.decrypt(filterResult[index]["type"]),
                                                    crypto.decrypt(filterResult[index]["subType"]),
                                                    filterResult[index]["isEdited"],
                                                    crypto.decrypt(filterResult[index]["lastModDate"])),
                                              );
                                            },
                                            child: SizedBox(
                                              child: Card(
                                                elevation: 1.0,
                                                shadowColor: Theme.of(context)
                                                    .primaryColor,
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor
                                                          .withAlpha(95)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Center(
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.80,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Text(
                                                                      crypto.decrypt(
                                                                          filterResult[index]
                                                                              [
                                                                              "purpose"]),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          5,
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              23,
                                                                          fontWeight:
                                                                              FontWeight.w500),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child:
                                                                          Text(
                                                                        crypto.decrypt(filterResult[index]["type"]) +
                                                                            (crypto.decrypt(filterResult[index]["subType"]).length > 0
                                                                                ? ' (${crypto.decrypt(filterResult[index]["subType"])})'
                                                                                : ""),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child:
                                                                          Text(
                                                                        formatDateTime(crypto.decrypt(filterResult[index]
                                                                            [
                                                                            "date"])),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                          Column(
                                                            mainAxisAlignment: filterResult[
                                                                        index]
                                                                    ["isEdited"]
                                                                ? MainAxisAlignment
                                                                    .start
                                                                : MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              filterResult[
                                                                          index]
                                                                      [
                                                                      "isEdited"]
                                                                  ? SizedBox(
                                                                      height: 8,
                                                                    )
                                                                  : SizedBox(),
                                                              filterResult[index]
                                                                      [
                                                                      "isEdited"]
                                                                  ? Container(
                                                                      width: 55,
                                                                      height:
                                                                          30,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      decoration: BoxDecoration(
                                                                          color: Colors.transparent,
                                                                          border: Border.all(
                                                                            color: themeProvider.isDarkTheme
                                                                                ? Theme.of(context).primaryColor
                                                                                : Colors.white,
                                                                          ),
                                                                          borderRadius: BorderRadius.all(Radius.circular(12))),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                        child: Text(
                                                                            "Edited",
                                                                            style:
                                                                                TextStyle(fontSize: 13, color: Colors.white)),
                                                                      ))
                                                                  : SizedBox(),
                                                              filterResult[
                                                                          index]
                                                                      [
                                                                      "isEdited"]
                                                                  ? SizedBox(
                                                                      height:
                                                                          20,
                                                                    )
                                                                  : SizedBox(),
                                                              Expanded(
                                                                flex: 0,
                                                                child: SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.2,
                                                                  child: Text(
                                                                    "₹ " +
                                                                        commaSeperator(crypto.decrypt(filterResult[index]
                                                                            [
                                                                            "amount"])),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ))
                          : Scrollbar(
                              radius: Radius.circular(10.0),
                              thickness: 5.5,
                              child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        height: 5,
                                      ),
                                  shrinkWrap: true,
                                  itemCount: TransList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (TransList[index]["quickSplit"]) {
                                      return InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => _buildPopupDialog(
                                                context,
                                                index,
                                                crypto.decrypt(TransList[index]
                                                    ["purpose"]),
                                                "Quick Split",
                                                (crypto.decrypt(
                                                    TransList[index]["date"])),
                                                "₹ " +
                                                    commaSeperator(
                                                        crypto.decrypt(
                                                            TransList[index]
                                                                ["amount"])),
                                                TransList[index]["room"],
                                                TransList[index]["quickSplit"],
                                                crypto.decrypt(
                                                    TransList[index]["id"]),
                                                crypto.decrypt(
                                                    TransList[index]["type"]),
                                                crypto.decrypt(TransList[index]
                                                    ["subType"]),
                                                TransList[index]["isEdited"],
                                                crypto.decrypt(TransList[index]["lastModDate"])),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 135,
                                          child: Card(
                                            elevation: 1.0,
                                            shadowColor:
                                                Theme.of(context).primaryColor,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withAlpha(95)),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.80,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                crypto.decrypt(
                                                                    TransList[
                                                                            index]
                                                                        [
                                                                        "purpose"]),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 5,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        23,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "type"]) +
                                                                      (crypto.decrypt(TransList[index]["subType"]).length >
                                                                              0
                                                                          ? ' (${crypto.decrypt(TransList[index]["subType"])})'
                                                                          : ""),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  "Quick Split",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  formatDateTime(
                                                                      crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "date"])),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          TransList[index]
                                                                  ["isEdited"]
                                                              ? MainAxisAlignment
                                                                  .start
                                                              : MainAxisAlignment
                                                                  .center,
                                                      children: [
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? SizedBox(
                                                                height: 8,
                                                              )
                                                            : SizedBox(),
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? Container(
                                                                width: 55,
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
                                                                          color: themeProvider.isDarkTheme
                                                                              ? Theme.of(context).primaryColor
                                                                              : Colors.white,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(12))),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                  child: Text(
                                                                      "Edited",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white)),
                                                                ))
                                                            : SizedBox(),
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? SizedBox(
                                                                height: 30,
                                                              )
                                                            : SizedBox(),
                                                        Expanded(
                                                          flex: 0,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                            child: Text(
                                                              "₹ " +
                                                                  commaSeperator(
                                                                      crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "amount"])),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else if (TransList[index]["room"]) {
                                      return InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => _buildPopupDialog(
                                                context,
                                                index,
                                                crypto.decrypt(TransList[index]
                                                    ["purpose"]),
                                                crypto.decrypt(TransList[index]
                                                    ["roomName"]),
                                                (crypto.decrypt(
                                                    TransList[index]["date"])),
                                                "₹ " +
                                                    commaSeperator(
                                                        crypto.decrypt(
                                                            TransList[index]
                                                                ["amount"])),
                                                TransList[index]["room"],
                                                TransList[index]["quickSplit"],
                                                crypto.decrypt(
                                                    TransList[index]["id"]),
                                                crypto.decrypt(
                                                    TransList[index]["type"]),
                                                crypto.decrypt(TransList[index]["subType"]),
                                                TransList[index]["isEdited"],
                                                crypto.decrypt(TransList[index]["lastModDate"])),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 135,
                                          child: Card(
                                            elevation: 1.0,
                                            shadowColor:
                                                Theme.of(context).primaryColor,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withAlpha(95)),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.80,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                crypto.decrypt(
                                                                    TransList[
                                                                            index]
                                                                        [
                                                                        "purpose"]),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 5,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        23,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "type"]) +
                                                                      (crypto.decrypt(TransList[index]["subType"]).length >
                                                                              0
                                                                          ? ' (${crypto.decrypt(TransList[index]["subType"])})'
                                                                          : ""),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "roomName"]) +
                                                                      " (Room)",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  formatDateTime(
                                                                      crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "date"])),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          TransList[index]
                                                                  ["isEdited"]
                                                              ? MainAxisAlignment
                                                                  .start
                                                              : MainAxisAlignment
                                                                  .center,
                                                      children: [
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? SizedBox(
                                                                height: 8,
                                                              )
                                                            : SizedBox(),
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? Container(
                                                                width: 55,
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
                                                                          color: themeProvider.isDarkTheme
                                                                              ? Theme.of(context).primaryColor
                                                                              : Colors.white,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(12))),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                  child: Text(
                                                                      "Edited",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white)),
                                                                ))
                                                            : SizedBox(),
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? SizedBox(
                                                                height: 30,
                                                              )
                                                            : SizedBox(),
                                                        Expanded(
                                                          flex: 0,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                            child: Text(
                                                              "₹ " +
                                                                  commaSeperator(
                                                                      crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "amount"])),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => _buildPopupDialog(
                                                context,
                                                index,
                                                crypto.decrypt(TransList[index]
                                                    ["purpose"]),
                                                "",
                                                (crypto.decrypt(
                                                    TransList[index]["date"])),
                                                "₹ " +
                                                    commaSeperator(
                                                        crypto.decrypt(
                                                            TransList[index]
                                                                ["amount"])),
                                                TransList[index]["room"],
                                                TransList[index]["quickSplit"],
                                                crypto.decrypt(
                                                    TransList[index]["id"]),
                                                crypto.decrypt(
                                                    TransList[index]["type"]),
                                                crypto.decrypt(TransList[index]
                                                    ["subType"]),
                                                TransList[index]["isEdited"],
                                                crypto.decrypt(TransList[index]["lastModDate"])),
                                          );
                                        },
                                        child: SizedBox(
                                          child: Card(
                                            elevation: 2.0,
                                            shadowColor:
                                                Theme.of(context).primaryColor,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withAlpha(95)),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(10.0),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.80,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text(
                                                                crypto.decrypt(
                                                                    TransList[
                                                                            index]
                                                                        [
                                                                        "purpose"]),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 5,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        23,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "type"]) +
                                                                      (crypto.decrypt(TransList[index]["subType"]).length >
                                                                              0
                                                                          ? ' (${crypto.decrypt(TransList[index]["subType"])})'
                                                                          : ""),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  formatDateTime(
                                                                      crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "date"])),
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                            ]),
                                                      ),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          TransList[index]
                                                                  ["isEdited"]
                                                              ? MainAxisAlignment
                                                                  .start
                                                              : MainAxisAlignment
                                                                  .center,
                                                      children: [
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? SizedBox(
                                                                height: 8,
                                                              )
                                                            : SizedBox(),
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? Container(
                                                                width: 55,
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
                                                                          color: themeProvider.isDarkTheme
                                                                              ? Theme.of(context).primaryColor
                                                                              : Colors.white,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(12))),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                  child: Text(
                                                                      "Edited",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              13,
                                                                          color:
                                                                              Colors.white)),
                                                                ))
                                                            : SizedBox(),
                                                        TransList[index]
                                                                ["isEdited"]
                                                            ? SizedBox(
                                                                height: 20,
                                                              )
                                                            : SizedBox(),
                                                        Expanded(
                                                          flex: 0,
                                                          child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                            child: Text(
                                                              "₹ " +
                                                                  commaSeperator(
                                                                      crypto.decrypt(
                                                                          TransList[index]
                                                                              [
                                                                              "amount"])),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                    )),
        ),
        floatingActionButton: Curdate == dateFromUrl
            ? (expenseCategory.length == 0
                ? null
                : FloatingActionButton(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      expensedate = DateTime.now();
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: Form(
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
                                        RegExp validateNumber =
                                            RegExp(r'^\d+(\.\d{1,2})?$');
                                        if (!validateNumber
                                            .hasMatch(_amt.text)) {
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
                                    TextFormField(
                                      controller: _purpose,
                                      keyboardType: TextInputType.text,
                                      maxLength: 1000,
                                      maxLines: 1,
                                      style: const TextStyle(fontSize: 18),
                                      autocorrect: false,
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
                                    expenseCategory.length == 0
                                        ? SizedBox()
                                        : SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.96,
                                            height: 70,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: expenseCategory.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: InkWell(
                                                      child: Card(
                                                        color: Theme.of(context)
                                                            .dialogBackgroundColor,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color: (index ==
                                                                      categoryIndex
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : Theme.of(
                                                                          context)
                                                                      .cardColor)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          child: Center(
                                                            child: InkWell(
                                                              child: Text(
                                                                expenseCategory[
                                                                    index],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                                              categoryIndex =
                                                                  index;
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
                                    (subCategory.length > categoryIndex &&
                                            subCategory[categoryIndex].length >
                                                0)
                                        ? SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.96,
                                            height: 70,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  subCategory[categoryIndex]
                                                      .length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: InkWell(
                                                      child: Card(
                                                        color: Theme.of(context)
                                                            .dialogBackgroundColor,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color: (index ==
                                                                      subCategoryIndex
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                  : Theme.of(
                                                                          context)
                                                                      .cardColor)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          child: Center(
                                                            child: InkWell(
                                                              child: Text(
                                                                subCategory[
                                                                        categoryIndex]
                                                                    [index],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                                              subCategoryIndex =
                                                                  index;
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
                                      height: 7,
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat(
                                                      global.dateTimeFormat_new)
                                                  .format(expensedate),
                                              style: TextStyle(fontSize: 18),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                DateTime? dateTime =
                                                    await showOmniDateTimePicker(
                                                  context: context,
                                                  is24HourMode: false,
                                                  isShowSeconds: false,
                                                  initialDate: expensedate,
                                                  firstDate: DateTime(2018),
                                                  lastDate: DateTime.now(),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                );

                                                if (dateTime != null) {
                                                  if (this.mounted) {
                                                    setState(() {
                                                      expensedate = dateTime;
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              AddExpense(context);
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      );
                    },
                  ))
            : null,
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
