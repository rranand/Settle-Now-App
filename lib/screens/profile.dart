import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;

import 'package:pie_chart/pie_chart.dart';
import 'expenses.dart';

class Profile extends StatefulWidget {
  final String email;
  final String token;
  const Profile({ Key? key, required this.email, required this.token }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<dynamic> personalExpense = [];
  bool personalLoaded = false;
  bool roomLoaded = false;
  List<String> category = ["Fashion", "Investment", "Food", "Travelling", "Household", "Health", "Entertainment", "Miscellaneous"];
  final Shader linearGradient = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 243, 33, 112), Color.fromARGB(255, 255, 235, 7), Color.fromARGB(255,33, 150, 243), Color.fromARGB(255, 255, 0, 235)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Shader linearGradient_1 = LinearGradient(
    colors: <Color>[Color.fromARGB(255, 243, 236, 120), Color.fromARGB(255, 175, 66, 97), Color.fromARGB(255,241, 143, 67), Color.fromARGB(255, 139, 152, 98)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Shader linearGradient_2 = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 0, 219, 222), Color.fromARGB(255, 252, 0, 255)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  Map<String, double> dataMap = {};

  Future _initialisation() async {

    try {
      final response_1 = await http.post(
        Uri.parse(global.url + 'profile'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.email),
        })
      );

      if (response_1.statusCode == 200) {
        personalLoaded = true;
        personalExpense = jsonDecode(response_1.body)['data'];
        if (this.mounted) {
          setState(() {});
        }
      } else {
        _showToast(context, crypto.decrypt(jsonDecode(response_1.body)["Message"]));
      }
      
      updatePieChart("all");

    } on Exception catch(_) {
      _showToast(context, "No Internet Connection");
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  _showToast(BuildContext context, String show) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(show),
        action: SnackBarAction(label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  updatePieChart(String date) async {
    if (this.mounted) {
      setState(() {
        dataMap.clear();
      });
    }
    try {
      final response = await http.delete(
        Uri.parse(global.url + 'ptransaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.email),
          'date': crypto.encrypt(date),
        })
      );
      
      if (response.statusCode == 200) {
        var tempData =  jsonDecode(response.body)['data'];
        for(int i=0; i<category.length; i++) {
          dataMap[category[i]] = double.parse(double.parse(crypto.decrypt(tempData[category[i]])).toStringAsFixed(2));
        }
      } else {
        _showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]));
      }

    } on Exception catch(_) {
      _showToast(context, "No Internet Connection");
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            SizedBox(
              height: 10,
            ),
            dataMap.isEmpty?Center(child: CircularProgressIndicator(),):Padding(
              padding: const EdgeInsets.all(12.0),
              child: PieChart(
                dataMap: dataMap,
                chartRadius: MediaQuery.of(context).size.width / 2.5,
                animationDuration: Duration(milliseconds: 800),
                chartValuesOptions: ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: true,
                  decimalPlaces: 1,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Personal Expense",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 150,
              child: personalExpense.isEmpty?
                Center( 
                    child:personalLoaded?Text(
                      "No Personal Expense",
                      style: TextStyle(
                        fontSize: 24
                      ),
                  ):CircularProgressIndicator(),
                ):ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: personalExpense.length,
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      height: 150,
                      width: 150,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () =>
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => Expenses(email: widget.email, date: crypto.decrypt(personalExpense[index]['Date']), token: widget.token,)),
                            ),
                          onLongPress: () async {
                            updatePieChart(crypto.decrypt(personalExpense[index]['Date']));
                          },
                          child: Card(
                            elevation: 5.0,
                            shadowColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  crypto.decrypt(personalExpense[index]['Month']) + ",",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    foreground: Paint()..shader = linearGradient_1,
                                  ),
                                ),
                                Text(
                                  crypto.decrypt(personalExpense[index]['Year']),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    foreground: Paint()..shader = linearGradient_1,
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "₹ " + crypto.decrypt(personalExpense[index]['Total']),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    foreground: Paint()..shader = linearGradient_2,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
      )
    );
  }
}