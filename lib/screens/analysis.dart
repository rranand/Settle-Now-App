import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/ChartData.dart';
import 'package:settlenow/models/PersonalExpenseEach.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/RoomEach.dart';
import '../others/themes.dart';
import '../contents.dart' as global;

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
  List<RoomEach> RoomDataSearched = [];
  List<StackedLineSeries<ChartStackedLineData, String>> graphData = [];
  bool isDataLoading = false;
  List<int> tempSelectedRoom = [];

  List<String> personalExpGraph = [
    "Personal Expense By Year",
    "Personal Expense By Month-Year"
  ];
  int indexPersonalGraph = 0;
  List<RoomEach> allRooms = [];
  List<int> indexRoom = [];

  @override
  void dispose() {
    super.dispose();
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
        graphData.clear();
        allRooms.clear();
        indexRoom.clear();
      });
    }

    allRooms = [...widget.RoomDataO, ...widget.RoomDataC];
    for (int i = 0; i < widget.RoomDataO.length && indexRoom.length < 3; i++) {
      if (!widget.RoomDataO[i].done) {
        indexRoom.add(i);
      }
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
    } else {
      while (this.mounted && context.canPop()) {
        context.pop();
      }
      if (this.mounted) {
        context.go(AppRouteConstants.loginRouteName);
      }
      return;
    }
    prepareRoomGraph();
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email),
        'alreadyHave': crypto.encrypt("-1")
      };

      final response = await createHTTPreq(
          'profile', http.post, _token, jsonInputData, context);

      if (response.statusCode == 200) {
        List<dynamic> tempData = jsonDecode(response.body)['data'];
        tempData.forEach((element) {
          personalExpense.add(PersonalExpenseEach.fromJson(element));
        });

        personalExpense.sort((a, b) {
          if (a.Year != b.Year) {
            return int.parse(b.Year).compareTo(int.parse(a.Year));
          } else {
            return global.Month.indexOf(b.Month)
                .compareTo(global.Month.indexOf(a.Month));
          }
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

  Widget RoomListWidget(
    BuildContext context,
    List<RoomEach> data,
    Function fn,
  ) {
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
              int OGIndex = allRooms.indexOf(data[index]);
              return SizedBox(
                  height: 80,
                  child: Center(
                    child: Card(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: tempSelectedRoom.contains(OGIndex)
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade700),
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
                                    if (tempSelectedRoom.contains(OGIndex)) {
                                      tempSelectedRoom.remove(OGIndex);
                                    } else {
                                      tempSelectedRoom.add(OGIndex);
                                    }
                                    if (this.mounted) {
                                      setState(() {});
                                      _(() {});
                                      fn(() {});
                                    }
                                  },
                                  icon: Icon(!tempSelectedRoom.contains(OGIndex)
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

    for (int i = 0; i < allRooms.length; i++) {
      if (allRooms[i]
          .roomName
          .toLowerCase()
          .contains(_searchRoom.text.toLowerCase())) {
        RoomDataSearched.add(allRooms[i]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> prepareRoomGraph() async {
    if (this.mounted) {
      setState(() {
        graphData.clear();
        graphLoading = true;
      });
    }
    List<String> roomKeys = [];
    for (int i = 0; i < indexRoom.length; i++) {
      roomKeys.add(allRooms[indexRoom[i]].roomKey);
    }

    List<dynamic> roomData = await getRoomData(roomKeys);
    List<ChartStackedLineData> tempGraphData = [];

    for (int i = 0; i < widget.expenseCategory.length; i++) {
      List<double> categoryWiseAmount = [];
      for (int j = 0; j < roomData.length; j++) {
        categoryWiseAmount.add(double.parse(
            crypto.decrypt(roomData[j]["expense"][widget.expenseCategory[i]])));
      }
      tempGraphData.add(ChartStackedLineData.byRoom(
          widget.expenseCategory[i], categoryWiseAmount));
    }

    for (int i = 0; i < roomData.length; i++) {
      graphData.add(StackedLineSeries<ChartStackedLineData, String>(
        dataSource: tempGraphData,
        xValueMapper: (ChartStackedLineData graphData, int index) =>
            graphData.type,
        yValueMapper: (ChartStackedLineData graphData, int index) =>
            graphData.amount[i],
        color: global.colorsList[i],
        markerSettings: const MarkerSettings(isVisible: true),
        name: crypto.decrypt(roomData[i]["roomName"]),
      ));
    }

    if (this.mounted) {
      setState(() {
        graphLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initialisation();
  }

  Widget addRoomWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return StatefulBuilder(builder: (context, setStat) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                onPressed: () {
                                  if (this.mounted) {
                                    setState(() {
                                      tempSelectedRoom.clear();
                                    });
                                    setStat(() {
                                      tempSelectedRoom.clear();
                                    });
                                  }
                                },
                                icon: Icon(Icons.refresh_outlined)),
                            IconButton(
                                onPressed: () => context.pop(),
                                icon: Icon(Icons.cancel_outlined)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    (allRooms.isEmpty)
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height - 420,
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
                                  _searchRoom.selection =
                                      TextSelection.collapsed(
                                          offset: _searchRoom.text.length);
                                  SearchRoom();
                                  if (this.mounted) {
                                    setState(() {});
                                    setStat(() {});
                                  }
                                },
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              SingleChildScrollView(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 420,
                                  child: _searchRoom.text.isEmpty
                                      ? RoomListWidget(
                                          context,
                                          allRooms,
                                          setStat,
                                        )
                                      : (RoomDataSearched.isEmpty
                                          ? Center(
                                              child: Text(
                                                "No Room Found",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            )
                                          : RoomListWidget(
                                              context,
                                              RoomDataSearched,
                                              setStat,
                                            )),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    height: 45,
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
                                        if (tempSelectedRoom.length > 3) {
                                          showToast(
                                              context,
                                              "A maximum of 3 rooms can be compared.",
                                              Icons.warning);
                                        } else {
                                          indexRoom = [...tempSelectedRoom];
                                          if (this.mounted) {
                                            setState(() {});
                                            setStat(() {});
                                            context.pop();
                                          }
                                          await prepareRoomGraph();
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    height: 45,
                                    child: OutlinedButton(
                                      child: Text(
                                        "Cancel",
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
                                        side:
                                            BorderSide(color: Colors.redAccent),
                                      ),
                                      onPressed: () {
                                        context.pop();
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                ],
                              )
                            ],
                          )
                  ],
                ))),
      );
    });
  }

  Future<List<dynamic>> getRoomData(List<String> roomKeys) async {
    List<dynamic> RoomData = [];
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': crypto.encrypt(roomKeys.toString())
      };

      final response = await createHTTPreq(
          'transaction/analysis', http.post, _token, jsonInputData, context);

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

  Widget personalExpenseByYearGraph() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 210,
      child: Padding(
          padding: const EdgeInsets.all(6),
          child: isDataLoading
              ? Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : (yearwiseSpend.isNotEmpty
                  ? RotatedBox(
                      quarterTurns: 1,
                      child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            isVisible: true,
                          ),
                          primaryYAxis: NumericAxis(
                            labelFormat: "₹ {value}",
                            isVisible: true,
                          ),
                          tooltipBehavior: TooltipBehavior(
                              enable: true,
                              header: "",
                              format: "point.x : ₹ point.y"),
                          plotAreaBorderWidth: 0,
                          series: <CartesianSeries>[
                            LineSeries<dynamic, String>(
                                color: Theme.of(context).primaryColor,
                                dataSource: yearwiseSpend,
                                yValueMapper: (dynamic data, _) =>
                                    data["amount"],
                                xValueMapper: (dynamic data, _) =>
                                    data["text"].toString(),
                                dataLabelSettings:
                                    DataLabelSettings(isVisible: true),
                                dataLabelMapper: (datum, index) =>
                                    "Year : " +
                                    datum["text"].toString() +
                                    "\n₹ " +
                                    datum["amount"].toStringAsFixed(2),
                                markerSettings: MarkerSettings(isVisible: true))
                          ]),
                    )
                  : Center(
                      child: Text(
                        "No Personal Expense Found",
                        style: TextStyle(fontSize: 20),
                      ),
                    ))),
    );
  }

  Widget personalExpenseByMonthYearGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 65,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: years.length + 1,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                if (0 == index) {
                  return SizedBox(
                    width: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                          onTap: () {
                            yearIndex = index;
                            personalExpenseByYear.clear();
                            personalExpenseByYear.addAll(personalExpense);
                            if (this.mounted) {
                              setState(() {});
                            }
                          },
                          child: Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: yearIndex == index
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade700),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Text(
                                "All",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
                            personalExpense.forEach((element) {
                              if (element.Year == years[index - 1]) {
                                personalExpenseByYear.add(element);
                              }
                            });
                            if (this.mounted) {
                              setState(() {});
                            }
                          },
                          child: Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: yearIndex == index
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade700),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Text(
                                years[index - 1],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
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
          height: 5,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: isDataLoading
              ? Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : (personalExpenseByYear.isNotEmpty
                  ? RotatedBox(
                      quarterTurns: 1,
                      child: SfCartesianChart(
                          primaryXAxis: CategoryAxis(
                            isVisible: true,
                          ),
                          primaryYAxis: NumericAxis(
                            labelFormat: "₹ {value}",
                            isVisible: true,
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
                            LineSeries<PersonalExpenseEach, String>(
                                color: Theme.of(context).primaryColor,
                                dataSource: personalExpenseByYear,
                                yValueMapper: (PersonalExpenseEach data, _) =>
                                    data.Total,
                                xValueMapper: (PersonalExpenseEach data, _) =>
                                    data.Month + ",\n" + data.Year,
                                dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                ),
                                dataLabelMapper: (datum, index) =>
                                    "₹ " + datum.Total.toStringAsFixed(2),
                                markerSettings: MarkerSettings(isVisible: true))
                          ]),
                    )
                  : Center(
                      child: Text(
                        "No Personal Expense Found",
                        style: TextStyle(fontSize: 20),
                      ),
                    )),
        ),
      ],
    );
  }

  Widget showPersonalGraph() {
    if (indexPersonalGraph == 0) {
      return personalExpenseByYearGraph();
    } else {
      return personalExpenseByMonthYearGraph();
    }
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
                              SingleChildScrollView(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: 45,
                                  child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                            width: 8,
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemCount: personalExpGraph.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(
                                          height: 45,
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(13.0),
                                              ),
                                              side: BorderSide(
                                                  color: indexPersonalGraph ==
                                                          index
                                                      ? Theme.of(context)
                                                          .primaryColor
                                                      : Colors.grey.shade700),
                                            ),
                                            onPressed: () {
                                              if (this.mounted) {
                                                setState(() {
                                                  indexPersonalGraph = index;
                                                });
                                              }
                                            },
                                            child: Text(
                                              personalExpGraph[index],
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      themeProvider.isDarkTheme
                                                          ? Colors.white
                                                          : Colors.black),
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              showPersonalGraph()
                            ],
                          ))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SingleChildScrollView(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                        width: 8,
                                      ),
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: indexRoom.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(
                                      height: 40,
                                      child: Card(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Center(
                                            child: Text(
                                              allRooms[indexRoom[index]]
                                                  .roomName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height - 300,
                            width: MediaQuery.of(context).size.width,
                            child: indexRoom.isEmpty
                                ? Center(
                                    child: Text(
                                        allRooms.isEmpty
                                            ? "No Room Found"
                                            : "Choose Room To Compare",
                                        style: TextStyle(fontSize: 20)),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      graphLoading
                                          ? Center(
                                              child: CircularProgressIndicator
                                                  .adaptive(),
                                            )
                                          : (graphData.isNotEmpty
                                              ? SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      310,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6),
                                                      child: RotatedBox(
                                                        quarterTurns: 1,
                                                        child: SfCartesianChart(
                                                            enableAxisAnimation:
                                                                true,
                                                            legend: Legend(
                                                                isVisible: true,
                                                                isResponsive:
                                                                    true),
                                                            zoomPanBehavior:
                                                                ZoomPanBehavior(
                                                                    enablePanning:
                                                                        true),
                                                            primaryXAxis:
                                                                CategoryAxis(
                                                              majorGridLines:
                                                                  MajorGridLines(
                                                                      width: 0),
                                                              labelPlacement:
                                                                  LabelPlacement
                                                                      .onTicks,
                                                            ),
                                                            primaryYAxis:
                                                                NumericAxis(
                                                              isVisible: true,
                                                              axisLine:
                                                                  AxisLine(
                                                                      width: 0),
                                                              edgeLabelPlacement:
                                                                  EdgeLabelPlacement
                                                                      .shift,
                                                              labelFormat:
                                                                  '₹ {value}',
                                                              majorTickLines:
                                                                  MajorTickLines(
                                                                      size: 0),
                                                            ),
                                                            tooltipBehavior:
                                                                TooltipBehavior(
                                                                    enable:
                                                                        true),
                                                            plotAreaBorderWidth:
                                                                0,
                                                            series: graphData),
                                                      )),
                                                )
                                              : Center(
                                                  child: Center(
                                                      child: Text(
                                                  "Select Rooms To Analyse",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                )))),
                                    ],
                                  ),
                          ),
                        ],
                      )),
          ),
        ),
        floatingActionButton: isRoom
            ? FloatingActionButton(
                child: Icon(
                  Icons.filter_alt_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 3,
                        color: Theme.of(context).primaryColor.withOpacity(0.7)),
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  if (this.mounted) {
                    setState(() {
                      tempSelectedRoom = [...indexRoom];
                    });
                  }
                  showDialog(
                    context: context,
                    builder: (
                      BuildContext context,
                    ) =>
                        addRoomWidget(context),
                  );
                },
              )
            : null);
  }
}
