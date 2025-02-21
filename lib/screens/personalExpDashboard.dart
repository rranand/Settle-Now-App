import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/PersonalExpenseEach.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:shimmer/shimmer.dart';
import '../contents.dart' as global;

class PersonalExpenseDashBoard extends StatefulWidget {
  final List<dynamic> expenseCategory;
  final List<List<dynamic>> subCategory;

  const PersonalExpenseDashBoard(
      {Key? key, required this.expenseCategory, required this.subCategory})
      : super(key: key);

  @override
  _PersonalExpenseDashBoardState createState() =>
      _PersonalExpenseDashBoardState();
}

class _PersonalExpenseDashBoardState extends State<PersonalExpenseDashBoard> {
  String _email = "";
  String _token = "";
  List<PersonalExpenseEach> personalExpense = [];
  bool roomLoaded = false;
  double totalPersonalExpense = 0;
  bool showfilterResult = false;
  bool openDrawer = false;
  bool hasMore = true;
  Set<int> monthIndex = Set();
  Set<int> yearIndex = Set();
  List<dynamic> category = [];
  final scrollController = ScrollController();
  bool fetchingData = false;
  bool isLoadingData = false;
  bool loadFirstTime = true;
  String curPersonalExpDate =
      (DateTime.now().month - 1).toString() + DateTime.now().year.toString();

  List<String> Year = [];
  Map<String, double> yearwiseSpend = {};
  List<PersonalExpenseEach> filterResult = [];

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<ScaffoldState> _scaffoldKeyPersonalExp = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchPersonalExp(int alreadyHave) async {
    if (this.mounted) {
      setState(() {
        isLoadingData = true;
      });
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'alreadyHave': crypto.encrypt(alreadyHave.toString())
      };

      final response_1 = await createHTTPreq(
          'profile', http.post, _token, jsonInputData, context);

      if (response_1.statusCode == 200) {
        hasMore = jsonDecode(response_1.body)['hasMore'];
        List<dynamic> tempData = jsonDecode(response_1.body)['data'];
        tempData.forEach((element) {
          personalExpense.add(PersonalExpenseEach.fromJson(element));
        });

        if (personalExpense.length == 0 ||
            personalExpense[0].Date != curPersonalExpDate) {
          personalExpense.insert(
              0,
              PersonalExpenseEach(
                  Date: curPersonalExpDate,
                  Total: 0,
                  Month: global.Month[DateTime.now().month - 1],
                  Year: DateTime.now().year.toString()));
        }
        if (this.mounted) {
          setState(() {});
        }
      } else if (response_1.statusCode == 503) {
        while (context.canPop()) {
          if (this.mounted) {
            context.pop();
          }
        }
        context.push(AppRouteConstants.maintainRouteName);
      } else {
        showToast(
            context,
            crypto.decrypt(jsonDecode(response_1.body)["Message"]),
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(err, stackTrace,
            reason: "Unknwon Error", info: ["Summary->fetchPersonalExp"]);
      }
    }
    if (this.mounted) {
      setState(() {
        fetchingData = false;
        isLoadingData = false;
      });
    }
  }

  Future<void> _initialisation() async {
    isLoadingData = true;
    personalExpense.clear();
    category = widget.expenseCategory;

    if (_email.length == 0 && _token.length == 0) {
      var tokenData = await getStringPref('token');

      if (tokenData != null) {
        Map<String, dynamic> jsonOutData = parseJWT(tokenData.toString());
        if (this.mounted) {
          setState(() {
            _email = jsonOutData["email"]!;
            _token = jsonOutData["token"]!;
          });
        }
        Map<String, dynamic> jsonInputData = {
          'email': crypto.encrypt(_email),
          "url": crypto.encrypt(AppRouteConstants.personalExpenseDashboard),
          "creationDate": crypto.encrypt(DateTime.now().toString())
        };
        pushAnalytics(context, jsonInputData, _token);
      } else {
        while (this.mounted && context.canPop()) {
          context.pop();
        }
        if (this.mounted) {
          context.go(AppRouteConstants.loginRouteName);
        }
        return;
      }
    }
    if (this.mounted) {
      setState(() {});
    }

    await fetchPersonalExp(0);
    isLoadingData = false;
    loadFirstTime = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  getFilterResult() {
    if (this.mounted) {
      filterResult.clear();
      setState(() {});
    }

    if (monthIndex.isEmpty && yearIndex.isEmpty) {
      showfilterResult = false;
    } else {
      if (monthIndex.isNotEmpty) {
        personalExpense.forEach((element) {
          if (monthIndex.contains(global.Month.indexOf(element.Month))) {
            filterResult.add(element);
          }
        });
      }

      if (yearIndex.isNotEmpty) {
        if (filterResult.isEmpty) {
          personalExpense.forEach((element) {
            if (yearIndex.contains(Year.indexOf(element.Year))) {
              filterResult.add(element);
            }
          });
        } else {
          filterResult.removeWhere(
              (element) => !yearIndex.contains(Year.indexOf(element.Year)));
        }
      }

      filterResult.sort((b, a) {
        DateTime tempDate_1 = new DateFormat("MMM-yyyy")
            .parse(a.Month.substring(0, 3) + "-" + a.Year);
        DateTime tempDate_2 = new DateFormat("MMM-yyyy")
            .parse(b.Month.substring(0, 3) + "-" + b.Year);
        return tempDate_1.compareTo(tempDate_2);
      });
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  fillYear() {
    DateTime dt = new DateTime.now();
    for (int i = dt.year; i >= 2022; i--) {
      Year.add(i.toString());
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    fillYear();
    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  void _scrollListener() async {
    if (!loadFirstTime) {
      if (hasMore) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          fetchingData = true;
          if (!isLoadingData) {
            await fetchPersonalExp(personalExpense.length);
          }
        }
      }

      if (this.mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    double drawerWidth = MediaQuery.of(context).size.width * 0.75;
    int crossAxisCountFilter = (drawerWidth / 110).round();
    return Scaffold(
        key: _scaffoldKeyPersonalExp,
        endDrawer: openDrawer
            ? Drawer(
                width: MediaQuery.of(context).size.width * 0.75,
                backgroundColor: themeProvider.isDarkTheme
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Colors.white,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: ListView(shrinkWrap: true, children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Month",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: themeProvider.isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: (global.Month.length / crossAxisCountFilter)
                                    .ceil() *
                                65,
                            child: MasonryGridView.count(
                                crossAxisCount: crossAxisCountFilter,
                                itemCount: global.Month.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 65,
                                    width: 110,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          if (monthIndex.contains(index)) {
                                            monthIndex.remove(index);
                                          } else {
                                            monthIndex.add(index);
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
                                                color:
                                                    monthIndex.contains(index)
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Colors.grey.shade700),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Center(
                                            child: InkWell(
                                              child: Text(
                                                global.Month[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      themeProvider.isDarkTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Year",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: themeProvider.isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height:
                                (Year.length / crossAxisCountFilter).ceil() *
                                    70,
                            child: MasonryGridView.count(
                                crossAxisCount: crossAxisCountFilter,
                                itemCount: Year.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 65,
                                    width: 100,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          if (yearIndex.contains(index)) {
                                            yearIndex.remove(index);
                                          } else {
                                            yearIndex.add(index);
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
                                                color: yearIndex.contains(index)
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Colors.grey.shade700),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Center(
                                            child: InkWell(
                                              child: Text(
                                                Year[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      themeProvider.isDarkTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 45,
                                  width: 90,
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
                                      showfilterResult = true;
                                      getFilterResult();
                                      if (this.mounted) {
                                        setState(() {});
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
                                    onPressed: () {
                                      monthIndex.clear();
                                      yearIndex.clear();
                                      showfilterResult = false;
                                      if (this.mounted) {
                                        setState(() {});
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
                              ],
                            ),
                          ),
                        ]))))
            : null,
        body: RefreshIndicator(
          color: Theme.of(context).primaryColor,
          key: _refreshIndicatorKey,
          onRefresh: _initialisation,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 50,
                child: personalExpense.isEmpty
                    ? Center(
                        child: !isLoadingData
                            ? ListView(
                                physics: AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        200,
                                    child: Center(
                                      child: Text(
                                        "No Personal Expense Found",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Shimmer.fromColors(
                                baseColor: Theme.of(context).cardColor,
                                highlightColor: Theme.of(context).primaryColor,
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        (MediaQuery.of(context).size.width /
                                                250)
                                            .round(),
                                    childAspectRatio: 1.5,
                                  ),
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: 16,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: 150,
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
                                                width: 100,
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
                                                height: 10,
                                              ),
                                              Container(
                                                width: 150,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color: Colors.white,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      )
                    : (showfilterResult
                        ? (filterResult.isNotEmpty
                            ? GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      (MediaQuery.of(context).size.width / 250)
                                          .round(),
                                  childAspectRatio: 1.5,
                                ),
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: filterResult.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return ConstrainedBox(
                                    constraints: new BoxConstraints(
                                      minWidth: 150.0,
                                    ),
                                    child: SizedBox(
                                      height: 150,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () async {
                                            if (this.mounted) {
                                              final totalExp =
                                                  await context.push(
                                                AppRouteConstants
                                                        .personalExpenseRouteName +
                                                    "/" +
                                                    filterResult[index].Date,
                                              ) as double;
                                              setState(() {
                                                filterResult[index].Total =
                                                    totalExp;
                                              });
                                            }
                                          },
                                          child: Card(
                                            elevation: 1.0,
                                            shadowColor:
                                                Theme.of(context).primaryColor,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: curPersonalExpDate ==
                                                          filterResult[index]
                                                              .Date
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Theme.of(context)
                                                          .cardColor),
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                textWidget(
                                                  filterResult[index].Month +
                                                      ",",
                                                  linearGradient_1,
                                                ),
                                                textWidget(
                                                  filterResult[index].Year,
                                                  linearGradient_1,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: textWidget(
                                                      "₹ " +
                                                          commaSeperator(
                                                              filterResult[
                                                                      index]
                                                                  .Total
                                                                  .toStringAsFixed(
                                                                      2)),
                                                      linearGradient_2),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  "No Data Found",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ))
                        : Column(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 210,
                                child: GridView.builder(
                                  controller: scrollController,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        (MediaQuery.of(context).size.width /
                                                250)
                                            .round(),
                                    childAspectRatio: 1.5,
                                  ),
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: personalExpense.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ConstrainedBox(
                                      constraints: new BoxConstraints(
                                        minWidth: 150.0,
                                      ),
                                      child: SizedBox(
                                        height: 150,
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: InkWell(
                                            onTap: () async {
                                              if (this.mounted) {
                                                final totalExp =
                                                    await context.push(
                                                  AppRouteConstants
                                                          .personalExpenseRouteName +
                                                      "/" +
                                                      personalExpense[index]
                                                          .Date,
                                                ) as double;
                                                setState(() {
                                                  personalExpense[index].Total =
                                                      totalExp;
                                                });
                                              }
                                            },
                                            child: Card(
                                              elevation: 1.0,
                                              shadowColor: Theme.of(context)
                                                  .primaryColor,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: curPersonalExpDate ==
                                                            personalExpense[
                                                                    index]
                                                                .Date
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .cardColor),
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  textWidget(
                                                    personalExpense[index]
                                                            .Month +
                                                        ",",
                                                    linearGradient_1,
                                                  ),
                                                  textWidget(
                                                    personalExpense[index].Year,
                                                    linearGradient_1,
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: textWidget(
                                                        "₹ " +
                                                            commaSeperator(
                                                                personalExpense[
                                                                        index]
                                                                    .Total
                                                                    .toStringAsFixed(
                                                                        2)),
                                                        linearGradient_4),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              fetchingData
                                  ? CupertinoActivityIndicator(
                                      color: Theme.of(context).primaryColor,
                                    )
                                  : SizedBox()
                            ],
                          )),
              ),
            ),
          ),
        ),
        floatingActionButton: personalExpense.isEmpty
            ? null
            : FloatingActionButton(
                heroTag: UniqueKey(),
                child: Icon(
                  showfilterResult ? Icons.filter_alt_off : Icons.filter_alt,
                  color: Theme.of(context).primaryColor,
                ),
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 3,
                        color: Theme.of(context).primaryColor.withOpacity(0.7)),
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  openDrawer =
                      _scaffoldKeyPersonalExp.currentState!.isEndDrawerOpen;
                  openDrawer = !openDrawer;

                  if (openDrawer) {
                    _scaffoldKeyPersonalExp.currentState!.openEndDrawer();
                  } else {
                    _scaffoldKeyPersonalExp.currentState!.closeEndDrawer();
                  }
                },
              ));
  }
}
