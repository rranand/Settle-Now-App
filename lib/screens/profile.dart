import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/models/PersonalExpenseEach.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/themes.dart';
import 'package:settlenow/screens/maintain.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../contents.dart' as global;

import '../models/ChartData.dart';
import 'expenses.dart';

class Entry {
  final String title;
  final List<Entry> children;
  Entry(this.title, [this.children = const <Entry>[]]);
}

class Profile extends StatefulWidget {
  final String email;
  final String token;
  final double closeRoomSpend;
  final double openRoomSpend;
  final List<dynamic> expenseCategory;
  final List<dynamic> investmentCategory;

  const Profile(
      {Key? key,
      required this.email,
      required this.token,
      required this.closeRoomSpend,
      required this.openRoomSpend,
      required this.expenseCategory,
      required this.investmentCategory})
      : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<PersonalExpenseEach> personalExpense = [];
  bool personalLoaded = false;
  bool roomLoaded = false;
  double totalPersonalExpense = 0;
  Entry ExpenseData = Entry("Total: ₹ 0");
  bool showfilterResult = false;
  Set<int> monthIndex = Set();
  Set<int> yearIndex = Set();
  List<dynamic> category = [];
  List<String> Month = [
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

  List<String> Year = [];
  List<ChartData> dataMap = [];
  Map<String, double> yearwiseSpend = {};
  List<PersonalExpenseEach> filterResult = [];

  Widget buildExpenseTile(Entry root) {
    if (root.children.isEmpty) {
      return ListTile(
        title: Text(
          root.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      );
    } else {
      return ExpansionTile(
        title: Text(
          root.title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        children: root.children.map(buildExpenseTile).toList(),
      );
    }
  }

  Future _initialisation() async {
    personalLoaded = false;
    category = widget.expenseCategory;

    if (this.mounted) {
      setState(() {});
    }

    try {
      final response_1 = await http.post(Uri.parse(global.url + 'profile'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
          }));

      if (response_1.statusCode == 200) {
        personalLoaded = true;
        List<dynamic> tempData = jsonDecode(response_1.body)['data'];
        tempData.forEach((element) {
          personalExpense.add(PersonalExpenseEach.fromJson(element));
        });

        for (int i = 0; i < personalExpense.length; i++) {
          totalPersonalExpense += personalExpense[i].Total;
          String year = personalExpense[i].Year;
          yearwiseSpend[year] =
              ((yearwiseSpend[year] == null ? 0 : yearwiseSpend[year])! +
                  personalExpense[i].Total);
        }

        Year = yearwiseSpend.keys.toList();
        List<Entry> yearWiseExpenseEntry = [];
        yearwiseSpend.forEach((key, value) {
          yearWiseExpenseEntry.add(
              Entry(key + ": ₹ " + commaSeperator(value.toStringAsFixed(2))));
        });

        ExpenseData = Entry(
            'Total Expense: ₹ ' +
                commaSeperator((widget.closeRoomSpend +
                        widget.openRoomSpend +
                        totalPersonalExpense)
                    .toStringAsFixed(2)),
            <Entry>[
              Entry(
                  'Room: ₹ ' +
                      commaSeperator(
                          (widget.closeRoomSpend + widget.openRoomSpend)
                              .toStringAsFixed(2)),
                  <Entry>[
                    Entry('Open Room: ₹ ' +
                        commaSeperator(
                            widget.openRoomSpend.toStringAsFixed(2))),
                    Entry('Close Room: ₹ ' +
                        commaSeperator(
                            widget.closeRoomSpend.toStringAsFixed(2)))
                  ]),
              Entry(
                  'Personal Expense : ₹ ' +
                      commaSeperator((totalPersonalExpense).toStringAsFixed(2)),
                  yearWiseExpenseEntry)
            ]);
        if (this.mounted) {
          setState(() {});
        }
      } else if (jsonDecode(response_1.body)['maintenance'] != null &&
          jsonDecode(response_1.body)['maintenance']) {
        if (this.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Maintenance()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        showToast(
            context,
            crypto.decrypt(jsonDecode(response_1.body)["Message"]),
            Icons.close);
      }

      updatePieChart("all");
    } on Exception catch (_) {
      if (this.mounted) {
        await onException(context);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  updatePieChart(String date) async {
    if (this.mounted) {
      setState(() {
        dataMap.clear();
      });
    }
    try {
      final response = await http.delete(Uri.parse(global.url + 'ptransaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'date': crypto.encrypt(date),
          }));

      if (response.statusCode == 200) {
        var tempData = jsonDecode(response.body)['data'];

        for (int i = 0; i < category.length; i++) {
          dataMap.add(ChartData.byType(category[i],
              double.parse(crypto.decrypt(tempData[category[i]]))));
        }
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]),
            Icons.close);
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
          if (monthIndex.contains(Month.indexOf(element.Month))) {
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

  @override
  void initState() {
    super.initState();
    _initialisation();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            buildExpenseTile(ExpenseData),
            SizedBox(
              height: 10,
            ),
            dataMap.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3.3,
                    ),
                  )
                : SizedBox(
                    height: 50 * category.length * 1.0,
                    child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(isVisible: false),
                            primaryYAxis:
                                NumericAxis(minimum: 0, isVisible: false),
                            tooltipBehavior: TooltipBehavior(
                                enable: true,
                                header: "",
                                format: "point.x : ₹ point.y"),
                            plotAreaBorderWidth: 0,
                            series: <BarSeries<ChartData, String>>[
                              BarSeries<ChartData, String>(
                                  dataSource: dataMap,
                                  borderRadius: BorderRadius.circular(20),
                                  xValueMapper: (ChartData data, _) =>
                                      data.type,
                                  yValueMapper: (ChartData data, _) =>
                                      data.amount,
                                  isVisibleInLegend: true,
                                  width: 0.8,
                                  pointColorMapper: (ChartData data, _) =>
                                      global.colorsList[_],
                                  dataLabelMapper: (datum, index) =>
                                      datum.type +
                                      "\n₹ " +
                                      datum.amount.toStringAsFixed(2),
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true),
                                  xAxisName: "Category",
                                  yAxisName: "Amount")
                            ])),
                  ),
            SizedBox(
              height: 10,
            ),
            ExpansionTile(
              title: Text(
                "Personal Expense",
                style: TextStyle(
                  color:
                      themeProvider.isDarkTheme ? Colors.white : Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(
                Icons.filter_alt_outlined,
                color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
              ),
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 65,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: Month.length,
                      shrinkWrap: true,
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
                                shadowColor: Theme.of(context).primaryColor,
                                color: monthIndex.contains(index)
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context).cardColor),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: InkWell(
                                    child: Text(
                                      Month[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: monthIndex.contains(index)
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .color,
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
                  width: MediaQuery.of(context).size.width,
                  height: 65,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: Year.length,
                      shrinkWrap: true,
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
                                shadowColor: Theme.of(context).primaryColor,
                                color: yearIndex.contains(index)
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context).cardColor),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: InkWell(
                                    child: Text(
                                      Year[index],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: yearIndex.contains(index)
                                            ? Colors.white
                                            : Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .color,
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
                Row(
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
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
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
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
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
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: personalExpense.isEmpty
                  ? Center(
                      child: personalLoaded
                          ? Text(
                              "No Personal Expense Found",
                              style: TextStyle(fontSize: 20),
                            )
                          : Shimmer.fromColors(
                              baseColor: Theme.of(context).cardColor,
                              highlightColor: Theme.of(context).primaryColor,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: 5,
                                itemBuilder: (BuildContext context, int index) {
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
                                              width: 170,
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
                                                          Radius.circular(20))),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              width: 170,
                                              height: 25,
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
                                },
                              ),
                            ),
                    )
                  : (showfilterResult
                      ? (filterResult.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
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
                                        onTap: () {
                                          if (this.mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Expenses(
                                                        email: widget.email,
                                                        date:
                                                            filterResult[index]
                                                                .Date,
                                                        token: widget.token,
                                                        expenseCategory: widget
                                                            .expenseCategory,
                                                        investmentCategory: widget
                                                            .investmentCategory,
                                                      )),
                                            );
                                          }
                                        },
                                        onLongPress: () async {
                                          updatePieChart(
                                              filterResult[index].Date);
                                        },
                                        child: Card(
                                          elevation: 1.0,
                                          shadowColor:
                                              Theme.of(context).primaryColor,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Theme.of(context)
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
                                                filterResult[index].Month + ",",
                                                linearGradient_1,
                                              ),
                                              textWidget(
                                                filterResult[index].Year,
                                                linearGradient_1,
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: textWidget(
                                                    "₹ " +
                                                        commaSeperator(
                                                            filterResult[index]
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
                                "No Personal Expense Found",
                                style: TextStyle(fontSize: 20),
                              ),
                            ))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: personalExpense.length,
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
                                    onTap: () {
                                      if (this.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Expenses(
                                                    email: widget.email,
                                                    date: personalExpense[index]
                                                        .Date,
                                                    token: widget.token,
                                                    expenseCategory:
                                                        widget.expenseCategory,
                                                    investmentCategory: widget
                                                        .investmentCategory,
                                                  )),
                                        );
                                      }
                                    },
                                    onLongPress: () async {
                                      updatePieChart(
                                          personalExpense[index].Date);
                                    },
                                    child: Card(
                                      elevation: 1.0,
                                      shadowColor:
                                          Theme.of(context).primaryColor,
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            color: Theme.of(context).cardColor),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          textWidget(
                                            personalExpense[index].Month + ",",
                                            linearGradient_1,
                                          ),
                                          textWidget(
                                            personalExpense[index].Year,
                                            linearGradient_1,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: textWidget(
                                                "₹ " +
                                                    commaSeperator(
                                                        personalExpense[index]
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
                        )),
            ),
          ],
        ),
      ),
    ));
  }
}
