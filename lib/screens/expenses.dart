import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/themes.dart';
import '../contents.dart' as global;

class Expenses extends StatefulWidget {
  final String email;
  final String date;
  final String token;
  final List<dynamic> expenseCategory;
  final List<dynamic> investmentCategory;

  const Expenses(
      {Key? key,
      required this.email,
      required this.date,
      required this.token,
      required this.expenseCategory,
      required this.investmentCategory})
      : super(key: key);

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> TransList = [];
  bool filterDialog = false;
  bool showFilterResult = false;
  List<dynamic> filterResult = [];
  List<String> Months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final TextEditingController _amt = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool loaded = false;
  String title = "Personal Expense";
  List<dynamic> category = [];
  List<dynamic> investmentCat = [];
  Set<int> filtercategoryIndex = Set();
  bool isRoomFilter = false;
  int categoryIndex = 0;
  int investIndex = 0;
  String CurDate = "";
  final _formKey = GlobalKey<FormState>();
  final _updateExpense = GlobalKey<FormState>();

  Future _initialization() async {
    category = widget.expenseCategory;
    investmentCat = widget.investmentCategory;

    var now = DateTime.now();
    CurDate = (now.month - 1).toString() + now.year.toString();

    String yr = "";
    String mn = "";

    for (int i = widget.date.length - 1; i >= 0; i--) {
      if (yr.length != 4) {
        yr = widget.date[i] + yr;
      } else {
        mn = widget.date[i] + mn;
      }
    }

    title = Months[int.parse(mn)] + ", " + yr;

    try {
      final response = await http.post(Uri.parse(global.url + 'ptransaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'date': crypto.encrypt(widget.date),
          }));

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        TransList = jsonDecode(response.body)['data'];
      } else {
        showToast(context, crypto.decrypt(TransData["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  removeRoomTransaction(String id) async {
    try {
      final response = await http.delete(
          Uri.parse(global.url + 'transaction/personalExpense'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'id': crypto.encrypt(id)
          }));

      var TransData = jsonDecode(response.body);
      showToast(context, crypto.decrypt(TransData["Message"]), Icons.check);
      await _initialization();
    } on Exception catch (_) {
      await onException(context);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  updatePersonalTransaction(
      String purpose, String amount, String flag, String id) async {
    try {
      final response = await http.put(Uri.parse(global.url + 'ptransaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'purpose': crypto.encrypt(purpose),
            'amount': crypto.encrypt(amount),
            'flag': crypto.encrypt(flag),
            'id': crypto.encrypt(id)
          }));

      var TransData = jsonDecode(response.body);
      showToast(context, crypto.decrypt(TransData["Message"]), Icons.check);
      await _initialization();
    } on Exception catch (_) {
      await onException(context);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Widget _buildUpdateDialog(
      BuildContext context, String id, String purpose, String amount) {
    TextEditingController _updatePurpose = TextEditingController();
    TextEditingController _updateAmount = TextEditingController();

    return StatefulBuilder(builder: (context, setState) {
      _updateAmount.text = amount.substring(2);
      _updatePurpose.text = purpose;

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
                            controller: _updateAmount,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateNumber =
                                  RegExp(r'\b[1-9]{1}[\d]*\b');
                              if (!validateNumber
                                  .hasMatch(_updateAmount.text)) {
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
                            controller: _updatePurpose,
                            keyboardType: TextInputType.text,
                            maxLength: 150,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            autocorrect: false,
                            validator: (value) {
                              RegExp validateText = RegExp(r'\b[\w]+\b');
                              if (!validateText.hasMatch(_updatePurpose.text)) {
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
                                    buildShowDialog(context);
                                    await updatePersonalTransaction(
                                        _updatePurpose.text,
                                        _updateAmount.text,
                                        "0",
                                        id);
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

  Widget _buildPopupDialog(
      BuildContext context,
      String purpose,
      String type,
      String date,
      String amount,
      bool room,
      String id,
      String roomExpenseType) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.96,
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
                    purpose,
                    style: TextStyle(fontSize: 26),
                  ),
                  CurDate == widget.date
                      ? (room
                          ? IconButton(
                              onPressed: () async {
                                buildShowDialog(context);
                                await removeRoomTransaction(id);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.delete))
                          : Row(
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      buildShowDialog(context);
                                      await updatePersonalTransaction(
                                          purpose, amount, "1", id);
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
                                                context, id, purpose, amount),
                                      );
                                    },
                                    icon: Icon(Icons.edit)),
                              ],
                            ))
                      : SizedBox()
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  room
                      ? Text(
                          type + " (Room)",
                          style: TextStyle(fontSize: 18),
                        )
                      : Text(
                          "Type: " + type,
                          style: TextStyle(fontSize: 18),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Amount: " + amount,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Date: " + formatDateTime(date),
                    style: TextStyle(fontSize: 18),
                  ),
                  roomExpenseType.isEmpty
                      ? SizedBox()
                      : (SizedBox(
                          height: 10,
                        )),
                  roomExpenseType.isEmpty
                      ? SizedBox()
                      : (Text(
                          "Category: " + roomExpenseType,
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
                    Navigator.pop(context);
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
            'amt': crypto.encrypt(_amt.text),
            'type': crypto.encrypt(categoryIndex.toString()),
            'investType': crypto.encrypt(investIndex.toString()),
          }));

      _amt.text = "";
      _purpose.text = "";
      Tdata = jsonDecode(response.body);
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

  getFilterResult() {
    if (this.mounted) {
      setState(() {
        filterResult.clear();
      });
    }

    if (filtercategoryIndex.isEmpty && !isRoomFilter) {
      showFilterResult = false;
    } else {
      TransList.forEach((element) {
        if (element['room']) {
          if (isRoomFilter) {
            filterResult.add(element);
          }
        } else {
          if (filtercategoryIndex
              .contains(category.indexOf(crypto.decrypt(element['type'])))) {
            filterResult.add(element);
          }
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
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                Text(
                  "Filter by Category",
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: 10,
                ),
                Scrollbar(
                  radius: Radius.circular(10.0),
                  thickness: 5.5,
                  child: SizedBox(
                    height: 570,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: category.length + 1,
                        itemBuilder: ((context, index) {
                          if (category.length == index) {
                            return CheckboxListTile(
                              title: Text("Room"),
                              value: isRoomFilter,
                              onChanged: (_) {
                                isRoomFilter = !isRoomFilter;
                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          } else {
                            return CheckboxListTile(
                              title: Text(category[index]),
                              value: filtercategoryIndex.contains(index),
                              onChanged: (_) {
                                if (filtercategoryIndex.contains(index)) {
                                  filtercategoryIndex.remove(index);
                                } else {
                                  filtercategoryIndex.add(index);
                                }

                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }
                        })),
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
                      isRoomFilter = false;
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
                                : Text("Loading..."),
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
                                      if (filterResult[index]["room"]) {
                                        return InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) => _buildPopupDialog(
                                                  context,
                                                  crypto.decrypt(filterResult[index]
                                                      ["Purpose"]),
                                                  crypto.decrypt(
                                                      filterResult[index]
                                                          ["RoomName"]),
                                                  (crypto.decrypt(
                                                      filterResult[index]
                                                          ["Date"])),
                                                  "₹ " +
                                                      commaSeperator(crypto.decrypt(
                                                          filterResult[index]
                                                              ["Amount"])),
                                                  filterResult[index]["room"],
                                                  crypto.decrypt(
                                                      filterResult[index]["id"]),
                                                  crypto.decrypt(filterResult[index]["Type"])),
                                            );
                                          },
                                          child: SizedBox(
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
                                                              0.90,
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  crypto.decrypt(
                                                                      filterResult[
                                                                              index]
                                                                          [
                                                                          "Purpose"]),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          23,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Opacity(
                                                                  opacity: 0.8,
                                                                  child: Text(
                                                                    crypto.decrypt(
                                                                        filterResult[index]
                                                                            [
                                                                            "Type"]),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Opacity(
                                                                  opacity: 0.8,
                                                                  child: Text(
                                                                    crypto.decrypt(filterResult[index]
                                                                            [
                                                                            "RoomName"]) +
                                                                        " (Room)",
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Opacity(
                                                                  opacity: 0.8,
                                                                  child: Text(
                                                                    formatDateTime(crypto.decrypt(
                                                                        filterResult[index]
                                                                            [
                                                                            "Date"])),
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
                                                                commaSeperator(crypto.decrypt(
                                                                    filterResult[
                                                                            index]
                                                                        [
                                                                        "Amount"])),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
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
                                                  crypto.decrypt(
                                                      filterResult[index]
                                                          ["Purpose"]),
                                                  crypto.decrypt(
                                                          filterResult[index]
                                                              ["type"]) +
                                                      (crypto.decrypt(filterResult[index]["invType"]) ==
                                                              "None"
                                                          ? ""
                                                          : (" (" +
                                                              crypto.decrypt(filterResult[index]
                                                                  ["invType"]) +
                                                              ")")),
                                                  (crypto.decrypt(
                                                      filterResult[index]["Date"])),
                                                  "₹ " + commaSeperator(crypto.decrypt(filterResult[index]["Amount"])),
                                                  filterResult[index]["room"],
                                                  crypto.decrypt(filterResult[index]["id"]),
                                                  ""),
                                            );
                                          },
                                          child: SizedBox(
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
                                                              0.90,
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  crypto.decrypt(
                                                                      filterResult[
                                                                              index]
                                                                          [
                                                                          "Purpose"]),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          23,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Opacity(
                                                                  opacity: 0.8,
                                                                  child: Text(
                                                                    crypto.decrypt(filterResult[index]
                                                                            [
                                                                            "type"]) +
                                                                        (crypto.decrypt(filterResult[index]["invType"]) ==
                                                                                "None"
                                                                            ? ""
                                                                            : (" (" +
                                                                                crypto.decrypt(filterResult[index]["invType"]) +
                                                                                ")")),
                                                                    style:
                                                                        const TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 15,
                                                                ),
                                                                Opacity(
                                                                  opacity: 0.8,
                                                                  child: Text(
                                                                    formatDateTime(crypto.decrypt(
                                                                        filterResult[index]
                                                                            [
                                                                            "Date"])),
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
                                                                commaSeperator(crypto.decrypt(
                                                                    filterResult[
                                                                            index]
                                                                        [
                                                                        "Amount"])),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
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
                                separatorBuilder: (context, index) => SizedBox(
                                      height: 5,
                                    ),
                                shrinkWrap: true,
                                itemCount: TransList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (TransList[index]["room"]) {
                                    return InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              _buildPopupDialog(
                                                  context,
                                                  crypto.decrypt(TransList[index]
                                                      ["Purpose"]),
                                                  crypto.decrypt(TransList[index]
                                                      ["RoomName"]),
                                                  (crypto.decrypt(TransList[index]
                                                      ["Date"])),
                                                  "₹ " +
                                                      commaSeperator(
                                                          crypto.decrypt(
                                                              TransList[index]
                                                                  ["Amount"])),
                                                  TransList[index]["room"],
                                                  crypto.decrypt(
                                                      TransList[index]["id"]),
                                                  crypto.decrypt(
                                                      TransList[index]["Type"])),
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
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              crypto.decrypt(
                                                                  TransList[
                                                                          index]
                                                                      [
                                                                      "Purpose"]),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  fontSize: 23,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Opacity(
                                                              opacity: 0.8,
                                                              child: Text(
                                                                crypto.decrypt(
                                                                    TransList[
                                                                            index]
                                                                        [
                                                                        "Type"]),
                                                                style:
                                                                    const TextStyle(
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
                                                                crypto.decrypt(TransList[
                                                                            index]
                                                                        [
                                                                        "RoomName"]) +
                                                                    " (Room)",
                                                                style:
                                                                    const TextStyle(
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
                                                                formatDateTime(crypto
                                                                    .decrypt(TransList[
                                                                            index]
                                                                        [
                                                                        "Date"])),
                                                                style:
                                                                    const TextStyle(
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.20,
                                                      child: Text(
                                                        "₹ " +
                                                            commaSeperator(crypto
                                                                .decrypt(TransList[
                                                                        index][
                                                                    "Amount"])),
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
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
                                              crypto.decrypt(
                                                  TransList[index]["Purpose"]),
                                              crypto.decrypt(TransList[index]["type"]) +
                                                  (crypto.decrypt(TransList[index]["invType"]) == "None"
                                                      ? ""
                                                      : (" (" +
                                                          crypto.decrypt(
                                                              TransList[index]
                                                                  ["invType"]) +
                                                          ")")),
                                              (crypto.decrypt(
                                                  TransList[index]["Date"])),
                                              "₹ " +
                                                  commaSeperator(crypto.decrypt(
                                                      TransList[index]["Amount"])),
                                              TransList[index]["room"],
                                              crypto.decrypt(TransList[index]["id"]),
                                              ""),
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
                                            padding: const EdgeInsets.all(10.0),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              crypto.decrypt(
                                                                  TransList[
                                                                          index]
                                                                      [
                                                                      "Purpose"]),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  fontSize: 23,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            Opacity(
                                                              opacity: 0.8,
                                                              child: Text(
                                                                crypto.decrypt(TransList[
                                                                            index]
                                                                        [
                                                                        "type"]) +
                                                                    (crypto.decrypt(TransList[index]["invType"]) ==
                                                                            "None"
                                                                        ? ""
                                                                        : (" (" +
                                                                            crypto.decrypt(TransList[index]["invType"]) +
                                                                            ")")),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 17,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 15,
                                                            ),
                                                            Opacity(
                                                              opacity: 0.8,
                                                              child: Text(
                                                                formatDateTime(crypto
                                                                    .decrypt(TransList[
                                                                            index]
                                                                        [
                                                                        "Date"])),
                                                                style:
                                                                    const TextStyle(
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
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.20,
                                                      child: Text(
                                                        "₹ " +
                                                            commaSeperator(crypto
                                                                .decrypt(TransList[
                                                                        index][
                                                                    "Amount"])),
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
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
      floatingActionButton: CurDate == widget.date
          ? FloatingActionButton(
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
                                      RegExp(r'\b[1-9]{1}[\d]*\b');
                                  if (!validateNumber.hasMatch(_amt.text)) {
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
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: InkWell(
                                          child: Card(
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: (index == categoryIndex
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .scaffoldBackgroundColor)),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Center(
                                                child: InkWell(
                                                  child: Text(
                                                    category[index],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                      width: MediaQuery.of(context).size.width *
                                          0.96,
                                      height: 70,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: investmentCat.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: InkWell(
                                                child: Card(
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: (index ==
                                                                investIndex
                                                            ? Theme.of(context)
                                                                .primaryColor
                                                            : Theme.of(context)
                                                                .scaffoldBackgroundColor)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12.0),
                                                    child: Center(
                                                      child: InkWell(
                                                        child: Text(
                                                          investmentCat[index],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      side: BorderSide(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
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
            )
          : null,
    );
  }
}
