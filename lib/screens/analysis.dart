import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/ChartData.dart';
import 'package:settlenow/models/PersonalExpenseEach.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../contents.dart' as global;

import '../models/RoomEach.dart';
import '../others/themes.dart';

class Analysis extends StatefulWidget {
  final List<RoomEach> RoomDataO;
  final List<RoomEach> RoomDataC;
  final List<dynamic> expenseCategory;
  final List<List<dynamic>> subCategory;
  const Analysis(
      {Key? key,
      required this.RoomDataO,
      required this.RoomDataC,
      required this.expenseCategory,
      required this.subCategory})
      : super(key: key);

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  String _email = "";
  String _token = "";
  List<PersonalExpenseEach> personalExpense = [];
  List<PersonalExpenseEach> personalExpenseByYear = [];
  double totalPersonalExpense = 0;
  List<dynamic> yearwiseSpend = [];
  final TextEditingController _searchRoom = TextEditingController();
  List<String> years = [];
  int yearIndex = 0;
  bool isLiveRoom = true;
  bool graphLoading = false;
  bool isRoom = true;
  Set<RoomEach> compareBetween = {};
  List<RoomEach> RoomDataSearched = [];
  List<BarSeries<ChartData, String>> graphData = [];
  bool isDataLoading = false;

  late StreamSubscription<List<ConnectivityResult>> subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

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

  Future _initialisation() async {
    if (this.mounted) {
      setState(() {
        isDataLoading = true;
        years.clear();
        yearwiseSpend.clear();
        personalExpense.clear();
        totalPersonalExpense = 0;
        yearIndex = 0;
        personalExpenseByYear.clear();
        isLiveRoom = true;
        compareBetween.clear();
        graphData.clear();
      });
    }

    var tokenData = await getStringPref('token');

    if (tokenData != null) {
      Map<String, dynamic> jsonOutData = parseJWT(tokenData.toString());
      if (this.mounted) {
        setState(() {
          _email = jsonOutData["email"]!;
          _token = jsonOutData["token"]!;
        });
      }
    }

    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email),
        'alreadyHave': crypto.encrypt("-1")
      };

      final response =
          await createHTTPreq('profile', http.post, _token, jsonInputData);

      if (response.statusCode == 200) {
        List<dynamic> tempData = jsonDecode(response.body)['data'];
        tempData.forEach((element) {
          personalExpense.add(PersonalExpenseEach.fromJson(element));
        });

        Map<String, double> tempMap = {};
        personalExpenseByYear.addAll(personalExpense);

        for (int i = 0; i < personalExpense.length; i++) {
          totalPersonalExpense += personalExpense[i].Total;
          String year = personalExpense[i].Year;

          tempMap[year] = ((tempMap[year] == null ? 0 : tempMap[year])! +
              personalExpense[i].Total);
        }

        tempMap.forEach((key, value) {
          years.add(key);
          yearwiseSpend.add({
            "text": key,
            "amount": value,
          });
        });
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Analysis->_initialisation"]);
      }
    }

    isDataLoading = false;
    if (this.mounted) {
      setState(() {});
    }
  }

  Widget RoomListWidget(BuildContext context, List<RoomEach> data) {
    return StatefulBuilder(builder: (context, _) {
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
                        side: BorderSide(
                            color: compareBetween.contains(data[index])
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).cardColor),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data[index].roomName,
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              IconButton(
                                  onPressed: () async {
                                    if (compareBetween.contains(data[index])) {
                                      compareBetween.remove(data[index]);
                                    } else {
                                      compareBetween.add(data[index]);
                                    }
                                    if (this.mounted) {
                                      setState(() {});
                                      _(() {});
                                    }
                                  },
                                  icon: Icon(
                                      !compareBetween.contains(data[index])
                                          ? Icons.add
                                          : Icons.cancel_outlined))
                            ]),
                      ),
                    ),
                  ));
            }),
      );
    });
  }

  SearchRoom() {
    if (this.mounted) {
      setState(() {
        RoomDataSearched.clear();
      });
    }

    for (int i = 0; i < widget.RoomDataO.length; i++) {
      if (widget.RoomDataO[i].roomName
          .toLowerCase()
          .contains(_searchRoom.text.toLowerCase())) {
        RoomDataSearched.add(widget.RoomDataO[i]);
      }
    }

    for (int i = 0; i < widget.RoomDataC.length; i++) {
      if (widget.RoomDataC[i].roomName
          .toLowerCase()
          .contains(_searchRoom.text.toLowerCase())) {
        RoomDataSearched.add(widget.RoomDataC[i]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getConnectivity();
    _initialisation();
  }

  Widget addRoomWidget(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
          width: kIsWeb
              ? max(MediaQuery.of(context).size.width * 0.5,
                  min(400, MediaQuery.of(context).size.width))
              : MediaQuery.of(context).size.width,
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Room",
                        style: TextStyle(fontSize: 22),
                      ),
                      IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.cancel_outlined))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  (widget.RoomDataC.isEmpty && widget.RoomDataO.isEmpty)
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height - 310,
                          child: Center(
                            child: Text(
                              "No Room Found",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            TextField(
                              controller: _searchRoom,
                              keyboardType: TextInputType.text,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 15),
                              autocorrect: false,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(8.0),
                                labelText: "Enter Room Name",
                                counterText: "",
                                errorStyle: const TextStyle(fontSize: 15),
                              ),
                              onChanged: (String s) {
                                _searchRoom.text = s;
                                _searchRoom.selection = TextSelection.collapsed(
                                    offset: _searchRoom.text.length);
                                SearchRoom();
                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            SingleChildScrollView(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 310,
                                child: _searchRoom.text.isEmpty
                                    ? RoomListWidget(context,
                                        widget.RoomDataO + widget.RoomDataC)
                                    : (RoomDataSearched.isEmpty
                                        ? Center(
                                            child: Text(
                                              "No Room Found",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          )
                                        : RoomListWidget(
                                            context, RoomDataSearched)),
                              ),
                            ),
                          ],
                        )
                ],
              ))),
    );
  }

  Future<List<dynamic>> getRoomData(List<String> roomKeys) async {
    List<dynamic> RoomData = [];
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': crypto.encrypt(roomKeys.toString())
      };

      final response = await createHTTPreq(
          'transaction/analysis', http.post, _token, jsonInputData);

      if (response.statusCode == 200) {
        RoomData = jsonDecode(response.body)['data'];
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Analysis->getRoomData"]);
      }
    }
    return RoomData;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(context).size.width - 250) * 0.5,
              vertical: 16),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(24))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (this.mounted) {
                    setState(() {
                      isRoom = true;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 8.0),
                  child: Text(
                    "Room",
                    style: TextStyle(
                        fontSize: 18,
                        color: isRoom ? Theme.of(context).primaryColor : null,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Text(
                "|",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w100),
              ),
              InkWell(
                onTap: () {
                  if (this.mounted) {
                    setState(() {
                      isRoom = false;
                    });
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 8.0),
                  child: Text(
                    "Personal Expense",
                    style: TextStyle(
                        fontSize: 18,
                        color: isRoom ? null : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          )),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: !isRoom
                  ? (yearwiseSpend.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height - 200,
                          child: Center(
                            child: Text("No Personal Expense Found",
                                style: TextStyle(fontSize: 20)),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Personal Expense By Year",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              height: 400,
                              child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: isDataLoading
                                      ? Center(
                                          child: CircularProgressIndicator
                                              .adaptive(),
                                        )
                                      : (yearwiseSpend.isNotEmpty
                                          ? SfCartesianChart(
                                              primaryXAxis: CategoryAxis(
                                                isVisible: true,
                                              ),
                                              primaryYAxis: NumericAxis(
                                                  labelFormat: "₹ {value}",
                                                  isVisible: false),
                                              tooltipBehavior: TooltipBehavior(
                                                  enable: true,
                                                  header: "",
                                                  format:
                                                      "point.x : ₹ point.y"),
                                              plotAreaBorderWidth: 0,
                                              series: <CartesianSeries>[
                                                  LineSeries<dynamic, String>(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      dataSource: yearwiseSpend,
                                                      yValueMapper:
                                                          (dynamic data, _) =>
                                                              data["amount"],
                                                      xValueMapper:
                                                          (dynamic data, _) =>
                                                              data["text"]
                                                                  .toString(),
                                                      dataLabelSettings:
                                                          DataLabelSettings(
                                                              isVisible: true),
                                                      dataLabelMapper: (datum,
                                                              index) =>
                                                          "Year : " +
                                                          datum["text"]
                                                              .toString() +
                                                          "\n₹ " +
                                                          datum["amount"]
                                                              .toStringAsFixed(
                                                                  2),
                                                      markerSettings:
                                                          MarkerSettings(
                                                              isVisible: true))
                                                ])
                                          : Center(
                                              child: Text(
                                                "No Personal Expense Found",
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ))),
                            ),
                            Divider(),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Personal Expense By Month-Year",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 65,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: years.length + 1,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (0 == index) {
                                      return SizedBox(
                                        width: 100,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                              onTap: () {
                                                yearIndex = index;
                                                personalExpenseByYear.clear();
                                                personalExpenseByYear
                                                    .addAll(personalExpense);
                                                if (this.mounted) {
                                                  setState(() {});
                                                }
                                              },
                                              child: Card(
                                                elevation: 2.0,
                                                shadowColor: Theme.of(context)
                                                    .primaryColor,
                                                color: yearIndex == index
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: yearIndex == index
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .cardColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "All",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: yearIndex == index
                                                          ? Colors.white
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .color,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                        ),
                                      );
                                    } else {
                                      return SizedBox(
                                        width: 100,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                              onTap: () {
                                                yearIndex = index;
                                                personalExpenseByYear.clear();
                                                personalExpense
                                                    .forEach((element) {
                                                  if (element.Year ==
                                                      years[index - 1]) {
                                                    personalExpenseByYear
                                                        .add(element);
                                                  }
                                                });
                                                if (this.mounted) {
                                                  setState(() {});
                                                }
                                              },
                                              child: Card(
                                                elevation: 2.0,
                                                shadowColor: Theme.of(context)
                                                    .primaryColor,
                                                color: yearIndex == index
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: yearIndex == index
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .cardColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    years[index - 1],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: yearIndex == index
                                                          ? Colors.white
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .color,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                            SizedBox(
                              height: 300,
                              child: isDataLoading
                                  ? Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    )
                                  : (personalExpenseByYear.isNotEmpty
                                      ? SfCartesianChart(
                                          primaryXAxis: CategoryAxis(
                                            initialVisibleMinimum: 0,
                                            initialVisibleMaximum: 5,
                                            isVisible: true,
                                          ),
                                          primaryYAxis: NumericAxis(
                                            labelFormat: "₹ {value}",
                                            isVisible: false,
                                          ),
                                          tooltipBehavior: TooltipBehavior(
                                              enable: true,
                                              header: "",
                                              format: "point.x : point.y"),
                                          zoomPanBehavior: ZoomPanBehavior(
                                            enablePanning: true,
                                          ),
                                          plotAreaBorderWidth: 0,
                                          series: <CartesianSeries>[
                                              LineSeries<PersonalExpenseEach,
                                                      String>(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  dataSource:
                                                      personalExpenseByYear,
                                                  yValueMapper:
                                                      (PersonalExpenseEach data,
                                                              _) =>
                                                          data.Total,
                                                  xValueMapper:
                                                      (PersonalExpenseEach data,
                                                              _) =>
                                                          data.Month +
                                                          ",\n" +
                                                          data.Year,
                                                  dataLabelSettings:
                                                      DataLabelSettings(
                                                    isVisible: true,
                                                  ),
                                                  dataLabelMapper: (datum,
                                                          index) =>
                                                      "₹ " +
                                                      datum.Total.toStringAsFixed(
                                                          2),
                                                  markerSettings:
                                                      MarkerSettings(
                                                          isVisible: true))
                                            ])
                                      : Center(
                                          child: Text(
                                            "No Personal Expense Found",
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        )),
                            ),
                          ],
                        ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Active Room Comparison",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        widget.RoomDataO.isEmpty
                            ? SizedBox(
                                height: 200,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text("No Active Room Found",
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                ))
                            : SizedBox(
                                height: 45 * widget.RoomDataO.length * 1.0,
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
                                            format: "You spent ₹ point.y"),
                                        plotAreaBorderWidth: 0,
                                        series: <BarSeries<RoomEach, String>>[
                                          BarSeries<RoomEach, String>(
                                            dataSource: widget.RoomDataO,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            xValueMapper: (RoomEach data, _) =>
                                                data.roomName,
                                            yValueMapper: (RoomEach data, _) =>
                                                data.spend,
                                            isVisibleInLegend: true,
                                            width: 0.8,
                                            pointColorMapper:
                                                (RoomEach data, _) =>
                                                    global.colorsList[_],
                                            dataLabelMapper: (datum, index) =>
                                                datum.roomName +
                                                "\n₹ " +
                                                datum.spend.toStringAsFixed(2),
                                            dataLabelSettings:
                                                DataLabelSettings(
                                                    isVisible: true),
                                          )
                                        ])),
                              ),
                        Divider(),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Room Comparison",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        widget.RoomDataC.isEmpty && widget.RoomDataO.isEmpty
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 100,
                                  ),
                                  Center(
                                    child: Text("No Room Found",
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  compareBetween.isNotEmpty
                                      ? SizedBox(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 50,
                                          child: ListView.separated(
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                        width: 5,
                                                      ),
                                              scrollDirection: Axis.horizontal,
                                              shrinkWrap: true,
                                              itemCount: compareBetween.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                RoomEach tempRoom =
                                                    compareBetween
                                                        .elementAt(index);
                                                return Card(
                                                  elevation: 1.0,
                                                  shadowColor: Theme.of(context)
                                                      .primaryColor,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor,
                                                  shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.6)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () async {
                                                          compareBetween
                                                              .remove(tempRoom);
                                                          if (this.mounted) {
                                                            setState(() {});
                                                          }
                                                        },
                                                        child: Text(
                                                          tempRoom.roomName,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 17,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        )
                                      : SizedBox(),
                                  compareBetween.isEmpty
                                      ? SizedBox()
                                      : SizedBox(
                                          height: 15,
                                        ),
                                  SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width,
                                    child: OutlinedButton(
                                      child: Text(
                                        "Select Room",
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
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              addRoomWidget(context),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 45,
                                    width: MediaQuery.of(context).size.width,
                                    child: OutlinedButton(
                                      child: Text(
                                        "Analyse",
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
                                      onPressed: () async {
                                        graphData.clear();
                                        graphLoading = true;
                                        if (this.mounted) {
                                          setState(() {});
                                        }
                                        List<String> roomKeys = [];
                                        for (int i = 0;
                                            i < compareBetween.length;
                                            i++) {
                                          RoomEach tempObj =
                                              compareBetween.elementAt(i);
                                          roomKeys.add(tempObj.roomKey);
                                        }
                                        List<dynamic> roomData =
                                            await getRoomData(roomKeys);
                                        List<List<ChartData>> tempGraphData =
                                            [];

                                        for (int i = 0;
                                            i < roomData.length;
                                            i++) {
                                          List<ChartData> temp = [];
                                          for (int j = 0;
                                              j < widget.expenseCategory.length;
                                              j++) {
                                            temp.add(ChartData.byRoom(
                                                crypto.decrypt(
                                                    roomData[i]["roomName"]),
                                                widget.expenseCategory[j],
                                                double.parse(crypto.decrypt(
                                                    roomData[i]["expense"][
                                                        widget.expenseCategory[
                                                            j]]))));
                                          }
                                          tempGraphData.add(temp);
                                        }

                                        for (int i = 0;
                                            i < tempGraphData.length;
                                            i++) {
                                          graphData.add(BarSeries<ChartData, String>(
                                              dataSource: tempGraphData[i],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              width: 0.8,
                                              xValueMapper:
                                                  (ChartData data, _) =>
                                                      data.type,
                                              yValueMapper:
                                                  (ChartData data, _) =>
                                                      data.amount,
                                              isVisibleInLegend: true,
                                              pointColorMapper:
                                                  (ChartData data, _) =>
                                                      global.colorsList[_],
                                              dataLabelMapper: (datum, index) =>
                                                  datum.name +
                                                  " (" +
                                                  datum.type +
                                                  ")" +
                                                  "\n₹ " +
                                                  datum.amount
                                                      .toStringAsFixed(2),
                                              dataLabelSettings:
                                                  DataLabelSettings(
                                                      isVisible: true),
                                              xAxisName: "Category",
                                              yAxisName: "Amount"));
                                        }

                                        graphLoading = false;
                                        if (this.mounted) {
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  graphLoading
                                      ? SizedBox(
                                          height: 200,
                                          child: Center(
                                            child: CircularProgressIndicator
                                                .adaptive(),
                                          ),
                                        )
                                      : (graphData.isNotEmpty
                                          ? SizedBox(
                                              height: 50 *
                                                  graphData.length *
                                                  widget
                                                      .expenseCategory.length *
                                                  1.0,
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                  child: SfCartesianChart(
                                                      primaryXAxis:
                                                          CategoryAxis(
                                                              isVisible: false),
                                                      primaryYAxis: NumericAxis(
                                                          isVisible: false),
                                                      tooltipBehavior:
                                                          TooltipBehavior(
                                                              enable: true,
                                                              header: "",
                                                              format:
                                                                  "point.x : ₹ point.y"),
                                                      plotAreaBorderWidth: 0,
                                                      series: <BarSeries<ChartData, String>>[
                                                        ...graphData
                                                      ])),
                                            )
                                          : SizedBox(
                                              height: 200,
                                              child: Center(
                                                  child: Text(
                                                "Select Rooms To Analyse",
                                                style: TextStyle(fontSize: 18),
                                              )))),
                                ],
                              ),
                      ],
                    )),
        ),
      ),
    );
  }
}
