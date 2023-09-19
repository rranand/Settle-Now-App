import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:shimmer/shimmer.dart';
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
  DateTime expenseDate = DateTime.now();

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

  Future _initialization() async {
    loaded = false;
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

    if (this.mounted) {
      setState(() {});
    }

    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'date': crypto.encrypt(widget.date),
      };

      final response = await createHTTPreq(
          'ptransaction', http.post, widget.token, jsonInputData);

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        TransList = jsonDecode(response.body)['data'];
      } else if (response.statusCode == 503) {
        if (this.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Maintenance()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        showToast(context, crypto.decrypt(TransData["Message"]), Icons.close);
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

  removeRoomTransaction(String id, int index) async {
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'id': crypto.encrypt(id)
      };

      final response = await createHTTPreq('transaction/personalExpense',
          http.delete, widget.token, jsonInputData);

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        TransList.removeAt(index);
      }
      showToast(context, crypto.decrypt(TransData["Message"]), Icons.check);
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
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
        'email': crypto.encrypt(widget.email),
        'purpose': crypto.encrypt(purpose),
        'amount': crypto.encrypt(amount),
        'flag': crypto.encrypt(flag),
        'id': crypto.encrypt(id)
      };

      final response = await createHTTPreq(
          'ptransaction', http.put, widget.token, jsonInputData);

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (flag == "1") {
          TransList.removeAt(index);
        } else {
          TransList[index]['Amount'] = crypto.encrypt(amount);
          TransList[index]['Purpose'] = crypto.encrypt(purpose);
          TransList[index]['isEdited'] = true;
          TransList[index]['lastModDate'] = crypto.encrypt(
              DateFormat(global.dateTimeFormat).format(DateTime.now()));
        }
      }
      showToast(context, crypto.decrypt(TransData["Message"]), Icons.check);
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Widget _buildUpdateDialog(BuildContext context, String id, String purpose,
      String amount, int index) {
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
                            maxLength: 1000,
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
                                    if (this.mounted) {
                                      buildShowDialog(context);
                                    }
                                    await updatePersonalTransaction(
                                        _updatePurpose.text,
                                        _updateAmount.text,
                                        "0",
                                        id,
                                        index);
                                    if (this.mounted) {
                                      Navigator.pop(context);
                                    }
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
      String id,
      String roomExpenseType,
      bool isEdited,
      String lastModDate) {
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5 - 20,
                    child: Text(
                      purpose,
                      style: TextStyle(fontSize: 26),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 6,
                    ),
                  ),
                  CurDate == widget.date
                      ? (room
                          ? IconButton(
                              onPressed: () async {
                                if (this.mounted) {
                                  buildShowDialog(context);
                                }
                                await removeRoomTransaction(id, index);
                                if (this.mounted) {
                                  Navigator.pop(context);
                                }
                                if (this.mounted) {
                                  Navigator.pop(context);
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
                                        Navigator.pop(context);
                                      }
                                      if (this.mounted) {
                                        Navigator.pop(context);
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
                    "Created: " + formatDateTime(date),
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
                    if (this.mounted) {
                      Navigator.pop(context);
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
        'email': crypto.encrypt(widget.email),
        'purpose': crypto.encrypt(_purpose.text),
        'amt': crypto.encrypt(_amt.text),
        'type': crypto.encrypt(categoryIndex.toString()),
        'investType': crypto.encrypt(investIndex.toString()),
        'date': crypto
            .encrypt(DateFormat("MMM dd yyyy h:mm a").format(expenseDate)),
      };

      final response = await createHTTPreq(
          'ptransaction', http.patch, widget.token, jsonInputData);

      Tdata = jsonDecode(response.body);
      if (this.mounted) {
        Navigator.pop(context);
      }
      if (this.mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200) {
        TransList.insert(0, Tdata['data']);
      }
      _refreshIndicatorKey.currentState?.show();

      if (response.statusCode == 422) {
        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      if (this.mounted) {
        Navigator.pop(context);
      }
      if (this.mounted) {
        await onException(context);
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
    getConnectivity();
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
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        itemCount: category.length + 1,
                        itemBuilder: (context, index) {
                          if (category.length == index) {
                            return InkWell(
                              onTap: () {
                                isRoomFilter = !isRoomFilter;
                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                              child: Card(
                                elevation: 1.0,
                                color: themeProvider.isDarkTheme
                                    ? Theme.of(context).scaffoldBackgroundColor
                                    : Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: isRoomFilter
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context).cardColor),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text("Room"),
                                  ),
                                ),
                              ),
                            );
                          }
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
                                  child: Text(category[index]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                                        if (filterResult[index]["room"]) {
                                          return InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) => _buildPopupDialog(
                                                    context,
                                                    index,
                                                    crypto.decrypt(
                                                        filterResult[index]
                                                            ["Purpose"]),
                                                    crypto.decrypt(
                                                        filterResult[index]
                                                            ["RoomName"]),
                                                    (crypto.decrypt(
                                                        filterResult[index]
                                                            ["Date"])),
                                                    "₹ " +
                                                        commaSeperator(
                                                            crypto.decrypt(
                                                                filterResult[index]
                                                                    ["Amount"])),
                                                    filterResult[index]["room"],
                                                    crypto.decrypt(filterResult[index]["id"]),
                                                    crypto.decrypt(filterResult[index]["Type"]),
                                                    filterResult[index]["isEdited"],
                                                    crypto.decrypt(filterResult[index]["lastModDate"])),
                                              );
                                            },
                                            child: SizedBox(
                                              height: 165,
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
                                                                    height: 10,
                                                                  ),
                                                                  Text(
                                                                    crypto.decrypt(
                                                                        filterResult[index]
                                                                            [
                                                                            "Purpose"]),
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
                                                                    height: 10,
                                                                  ),
                                                                  Opacity(
                                                                    opacity:
                                                                        0.8,
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
                                                                    opacity:
                                                                        0.8,
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
                                                                    opacity:
                                                                        0.8,
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
                                                                              "Amount"])),
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
                                                            ["Purpose"]),
                                                    crypto.decrypt(
                                                            filterResult[index]
                                                                ["type"]) +
                                                        (crypto.decrypt(filterResult[index]["invType"]) ==
                                                                "None"
                                                            ? ""
                                                            : (" (" +
                                                                crypto.decrypt(
                                                                    filterResult[index]
                                                                        ["invType"]) +
                                                                ")")),
                                                    (crypto.decrypt(filterResult[index]["Date"])),
                                                    "₹ " + commaSeperator(crypto.decrypt(filterResult[index]["Amount"])),
                                                    filterResult[index]["room"],
                                                    crypto.decrypt(filterResult[index]["id"]),
                                                    "",
                                                    filterResult[index]["isEdited"],
                                                    crypto.decrypt(filterResult[index]["lastModDate"])),
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
                                                                              "Purpose"]),
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
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child:
                                                                          Text(
                                                                        crypto.decrypt(filterResult[index]["type"]) +
                                                                            (crypto.decrypt(filterResult[index]["invType"]) == "None"
                                                                                ? ""
                                                                                : (" (" + crypto.decrypt(filterResult[index]["invType"]) + ")")),
                                                                        style:
                                                                            const TextStyle(
                                                                          fontSize:
                                                                              17,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    Opacity(
                                                                      opacity:
                                                                          0.8,
                                                                      child:
                                                                          Text(
                                                                        formatDateTime(crypto.decrypt(filterResult[index]
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
                                                                            "Amount"])),
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
                                    if (TransList[index]["room"]) {
                                      return InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => _buildPopupDialog(
                                                context,
                                                index,
                                                crypto.decrypt(TransList[index]
                                                    ["Purpose"]),
                                                crypto.decrypt(TransList[index]
                                                    ["RoomName"]),
                                                (crypto.decrypt(
                                                    TransList[index]["Date"])),
                                                "₹ " +
                                                    commaSeperator(crypto.decrypt(
                                                        TransList[index]
                                                            ["Amount"])),
                                                TransList[index]["room"],
                                                crypto.decrypt(
                                                    TransList[index]["id"]),
                                                crypto.decrypt(
                                                    TransList[index]["Type"]),
                                                TransList[index]["isEdited"],
                                                crypto.decrypt(
                                                    TransList[index]["lastModDate"])),
                                          );
                                        },
                                        child: SizedBox(
                                          height: 165,
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
                                                                maxLines: 5,
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
                                                                      TransList[
                                                                              index]
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
                                                                  crypto.decrypt(
                                                                          TransList[index]
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
                                                                  formatDateTime(
                                                                      crypto.decrypt(
                                                                          TransList[index]
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
                                                                              "Amount"])),
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
                                                    ["Purpose"]),
                                                crypto.decrypt(TransList[index]["type"]) +
                                                    (crypto.decrypt(TransList[index]
                                                                ["invType"]) ==
                                                            "None"
                                                        ? ""
                                                        : (" (" +
                                                            crypto.decrypt(TransList[index]
                                                                ["invType"]) +
                                                            ")")),
                                                (crypto.decrypt(
                                                    TransList[index]["Date"])),
                                                "₹ " +
                                                    commaSeperator(crypto.decrypt(TransList[index]["Amount"])),
                                                TransList[index]["room"],
                                                crypto.decrypt(TransList[index]["id"]),
                                                "",
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
                                                                maxLines: 5,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        23,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  crypto.decrypt(
                                                                          TransList[index]
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
                                                                    fontSize:
                                                                        17,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Opacity(
                                                                opacity: 0.8,
                                                                child: Text(
                                                                  formatDateTime(
                                                                      crypto.decrypt(
                                                                          TransList[index]
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
                                                                              "Amount"])),
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
        floatingActionButton: CurDate == widget.date
            ? FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () {
                  expenseDate = DateTime.now();
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.96,
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
                                                    color: (index ==
                                                            categoryIndex
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.96,
                                        height: 70,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: investmentCat.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return SizedBox(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                  child: Card(
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      side: BorderSide(
                                                          color: (index ==
                                                                  investIndex
                                                              ? Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                              : Theme.of(
                                                                      context)
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
                                                            investmentCat[
                                                                index],
                                                            style: TextStyle(
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
                                          DateFormat(global.dateTimeFormat_new)
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
