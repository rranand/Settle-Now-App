import 'dart:math';

import 'package:flutter/material.dart';
import 'package:settlenow/models/RoomEach.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

Widget samplePE(BuildContext context) => SizedBox(
      child: Card(
        elevation: 2.0,
        shadowColor: Theme.of(context).primaryColor,
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(95)),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.80,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Credit Card Bill",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                        style: const TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "Miscellaneous",
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          "Feb 03 2022 3:44 PM",
                          style: const TextStyle(
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
                width: MediaQuery.of(context).size.width * 0.30,
                child: Text(
                  "₹ 31,000",
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );

Widget sampleRoom(BuildContext context) {
  List<Widget> allImages = [];
  for (int i = 0; i < 4; i++) {
    if (i == 0) {
      allImages.add(Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              image: AssetImage('assets/Images/unknown.jpeg'),
              fit: BoxFit.cover),
        ),
      ));
    } else {
      allImages.add(Positioned(
          left: i * 20,
          child: Container(
            width: 28.0,
            height: 28.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  image: AssetImage('assets/Images/unknown.jpeg'),
                  fit: BoxFit.cover),
            ),
          )));
    }
  }
  return SizedBox(
    child: Card(
      elevation: 1.0,
      clipBehavior: Clip.antiAlias,
      shadowColor: Theme.of(context).primaryColor,
      color: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(95)),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Udaipur Trip",
                textScaleFactor: 1.0,
                maxLines: 1,
                style: TextStyle(fontSize: 22, overflow: TextOverflow.ellipsis),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    children: allImages,
                  )),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Members: 4",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Room Key: djsWnaQ",
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contribution: ₹ 4000",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        "Spent: ₹ 1000",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 13,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ])),
    ),
  );
}

Widget getSampleLD(BuildContext context) => Card(
      elevation: 1.0,
      color: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).cardColor.withAlpha(95)),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage('assets/Images/unknown.jpeg'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(
                      width: 6,
                    ),
                    Text(
                      "Rohit Anand",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
            Text.rich(TextSpan(children: [
              TextSpan(
                text: "You gave ",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: ("₹ 1,200"),
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              TextSpan(text: " for ", style: TextStyle(fontSize: 18)),
              TextSpan(
                text: "movie tickets",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: " on ",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              TextSpan(
                text: " Feb 03 2022 3:42 PM",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ])),
          ],
        ),
      ),
    );

Widget sampleRoomGraph(BuildContext context) {
  List<RoomEach> data = [];

  data.add(RoomEach(
      roomName: "January 2022",
      members: 2,
      roomKey: "",
      active: false,
      total: 18000,
      spend: 8000,
      date: "",
      roomLink: "",
      done: false));

  data.add(RoomEach(
      roomName: "February 2022",
      members: 2,
      roomKey: "",
      active: false,
      total: 24000,
      spend: 9000,
      date: "",
      roomLink: "",
      done: false));

  data.add(RoomEach(
      roomName: "March 2022",
      members: 2,
      roomKey: "",
      active: false,
      total: 20000,
      spend: 7000,
      date: "",
      roomLink: "",
      done: false));

  data.add(RoomEach(
      roomName: "April 2022",
      members: 2,
      roomKey: "",
      active: false,
      total: 26000,
      spend: 6000,
      date: "",
      roomLink: "",
      done: false));

  data.add(RoomEach(
      roomName: "May 2022",
      members: 2,
      roomKey: "",
      active: false,
      total: 28000,
      spend: 12222,
      date: "",
      roomLink: "",
      done: false));

  return SizedBox(
    height: 45 * data.length * 1.0,
    child: Padding(
        padding: const EdgeInsets.all(6),
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(isVisible: false),
            primaryYAxis: NumericAxis(isVisible: false),
            tooltipBehavior: TooltipBehavior(
                enable: true, header: "", format: "You spent ₹ point.y"),
            plotAreaBorderWidth: 0,
            series: <BarSeries<RoomEach, String>>[
              BarSeries<RoomEach, String>(
                  dataSource: data,
                  borderRadius: BorderRadius.circular(20),
                  xValueMapper: (RoomEach data, _) => data.roomName,
                  yValueMapper: (RoomEach data, _) => data.spend,
                  isVisibleInLegend: true,
                  width: 0.8,
                  pointColorMapper: (RoomEach data, _) =>
                      Color(Random().nextInt(0xffffffff)),
                  dataLabelMapper: (datum, index) =>
                      datum.roomName + "\n₹ " + datum.spend.toStringAsFixed(2),
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  xAxisName: "Category",
                  yAxisName: "Amount")
            ])),
  );
}

Widget samplePEGraph(BuildContext context) {
  List<dynamic> yearwiseSpend = [];
  yearwiseSpend.add({
    "text": "2022",
    "amount": 125000,
  });
  yearwiseSpend.add({
    "text": "2021",
    "amount": 100000,
  });
  yearwiseSpend.add({
    "text": "2020",
    "amount": 90000,
  });
  yearwiseSpend.add({
    "text": "2019",
    "amount": 146000,
  });
  return SizedBox(
    height: 250,
    child: Padding(
        padding: const EdgeInsets.all(6),
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              isVisible: true,
            ),
            primaryYAxis:
                NumericAxis(labelFormat: "₹ {value}", isVisible: false),
            tooltipBehavior: TooltipBehavior(
                enable: true, header: "", format: "point.x : ₹ point.y"),
            plotAreaBorderWidth: 0,
            series: <ChartSeries>[
              LineSeries<dynamic, String>(
                  color: Theme.of(context).primaryColor,
                  dataSource: yearwiseSpend,
                  yValueMapper: (dynamic data, _) => data["amount"],
                  xValueMapper: (dynamic data, _) => data["text"].toString(),
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                  dataLabelMapper: (datum, index) =>
                      "Year : " +
                      datum["text"].toString() +
                      "\n₹ " +
                      datum["amount"].toStringAsFixed(2),
                  markerSettings: MarkerSettings(isVisible: true))
            ])),
  );
}
