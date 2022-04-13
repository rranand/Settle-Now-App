import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;
import '../others/themes.dart';

class Expenses extends StatefulWidget {
  final String email;
  final String date;
  final String token;
  const Expenses({ Key? key, required this.email, required this.date, required this.token}) : super(key: key);

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  List<dynamic> TransList = [];
  List<String> Months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final TextEditingController _amt = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  bool loaded = false;
  String title = "Personal Expense";
  List<String> category = ["Fashion", "Investment", "Food", "Traveling", "Household", "Health", "Entertainment", "Education", "Miscellaneous"];
  List<String> investmentCat = ["Mutual Fund", "Cryptography", "Fixed Deposit", "Stock"];
  int categoryIndex = 7;
  int investIndex = 0;
  String CurDate = "";
  final _formKey = GlobalKey<FormState>();

  Future _initialization() async {
    var now = DateTime.now();
    CurDate = (now.month-1).toString() + now.year.toString();
    
    String yr = "";
    String mn = "";

    for(int i=widget.date.length-1; i>=0; i--) {
      if (yr.length != 4) {
        yr = widget.date[i] + yr;
      } else {
        mn = widget.date[i] + mn;
      }
    }
    
    title = Months[int.parse(mn)] + ", " + yr;

    try {
      final response = await http.post(
        Uri.parse(global.url + 'ptransaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.email),
          'date': crypto.encrypt(widget.date),
        })
      );
      
      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        TransList =  jsonDecode(response.body)['data'];
      } else {
        _showToast(context, crypto.decrypt(TransData["Message"]));
      }
    } on Exception catch(_) {
      _showToast(context, "No Internet Connection");
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Widget _buildPopupDialog(BuildContext context, String purpose, String type, String date, String amount) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), 
      child: Container(
        width: MediaQuery.of(context).size.width*0.95,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                purpose,
                style: TextStyle(
                  fontSize: 30
                ),
              ),
              SizedBox(height: 25,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type: " + type, style: TextStyle(
                        fontSize: 20
                      ),),
                      SizedBox(height: 10,),
                      Text("Date: " + date, style: TextStyle(
                        fontSize: 20
                      ),),
                    ],
                  ),
                  Text(amount, style: TextStyle(
                    fontSize: 20
                  ),)
                ],
              ),
              SizedBox(height: 25,),
              SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width*0.95 - 25,
                child: ElevatedButton(
                  child: Text("Close", 
                    style: TextStyle(
                      color: Colors.white
                    ),
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
      final response = await http.patch(
        Uri.parse(global.url + 'ptransaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.email),
          'purpose': crypto.encrypt(_purpose.text),
          'amt':crypto.encrypt(_amt.text),
          'type':crypto.encrypt(categoryIndex.toString()),
          'investType':crypto.encrypt(investIndex.toString()),
        })
      );
      
      _amt.text = "";
      _purpose.text = "";
      Tdata = jsonDecode(response.body);
      Navigator.pop(context);
      Navigator.pop(context);

      _refreshIndicatorKey.currentState?.show();
      
      if (response.statusCode == 422) {
        _showToast(context, crypto.decrypt(Tdata["Message"]));
      }
    } on Exception catch(_) {
      Navigator.pop(context);
      _showToast(context, "No Internet Connection");
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
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

  buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _initialization,
        child: TransList.isEmpty? SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
              child:  
                (Center(
                  child: loaded?
                  Text("No Expense Found",
                    style: TextStyle(
                      fontSize: 25,
                    ))
                  :Text("Loading..."),
                  ))
          ):Scrollbar(
            radius: Radius.circular(10.0),
            thickness: 10.5,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: ListView.separated(
                    separatorBuilder: (context, index) => SizedBox(height: 0,),
                    shrinkWrap: true,
                    itemCount: TransList.length, 
                    itemBuilder: (BuildContext context, int index) {
                      final themeProvider = Provider.of<ThemeProvider>(context);
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => _buildPopupDialog(context, crypto.decrypt(TransList[index]["Purpose"]), crypto.decrypt(TransList[index]["type"]) + (crypto.decrypt(TransList[index]["invType"])=="None"?"":(" ("+crypto.decrypt(TransList[index]["invType"])+")")), crypto.decrypt(TransList[index]["Date"]), "₹ " + crypto.decrypt(TransList[index]["Amount"])),
                          );
                        },
                        child: SizedBox(
                          child: Card(
                            elevation: 5.0,
                            shadowColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.90,
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        crypto.decrypt(TransList[index]["Purpose"]), 
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          crypto.decrypt(TransList[index]["type"]) + (crypto.decrypt(TransList[index]["invType"])=="None"?"":(" ("+crypto.decrypt(TransList[index]["invType"])+")")),
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Opacity(
                                        opacity: 0.8,
                                        child: Text(
                                          crypto.decrypt(TransList[index]["Date"]),
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ]
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.20,
                                    child: Text(
                                      "₹ " + crypto.decrypt(TransList[index]["Amount"]),
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ]
                            ),
                          ),
                                          ),
                        ),
                      );
                    }
                      ),
            ),
          )
      ),
      floatingActionButton: CurDate==widget.date?FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
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
                              RegExp validateNumber = RegExp(r'\b[1-9]{1}[\d]*\b');
                              if (!validateNumber.hasMatch(_amt.text)) {
                                return "Enter Valid Amount";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
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
                              contentPadding: EdgeInsets.all(8.0),
                              hintText: "Enter Purpose",
                              labelText: "Purpose",
                              errorStyle: TextStyle(fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Category",
                                  style: TextStyle(
                                    fontSize: 18
                                  ),
                                ),
                                DropdownButton<String>(
                                  alignment: AlignmentDirectional.topStart,
                                  borderRadius: BorderRadius.circular(10.0),
                                  itemHeight: 70,
                                  elevation: 1,
                                  hint: Text(
                                    category[categoryIndex],
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  items: category.map((String value) {
                                    return DropdownMenuItem<String>(
                                      alignment: AlignmentDirectional.center,
                                      value: category.indexOf(value).toString(),
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (index) {
                                    setState(() {
                                      categoryIndex = int.parse(index!);
                                    });
                                  },
                                ),
                              ]
                            ),
                          ),
                          categoryIndex==1?
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Investment Type",
                                  style: TextStyle(
                                    fontSize: 18
                                  ),
                                ),
                                DropdownButton<String>(
                                  alignment: AlignmentDirectional.topStart,
                                  borderRadius: BorderRadius.circular(10.0),
                                  itemHeight: 70,
                                  elevation: 1,
                                  hint: Text(
                                    investmentCat[investIndex],
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  items: investmentCat.map((String value) {
                                    return DropdownMenuItem<String>(
                                      alignment: AlignmentDirectional.center,
                                      value: investmentCat.indexOf(value).toString(),
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (index) {
                                    setState(() {
                                      investIndex = int.parse(index!);
                                    });
                                  },
                                ),
                              ]
                            ),
                          ):SizedBox(),
                          SizedBox(
                            height: 40,
                            width: 100,
                            child: ElevatedButton(
                              child: const Text("Add", style: TextStyle(color: Colors.white),),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  AddExpense(context);
                                }
                              }
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  );
                }
              );
            },
          );
        },
      ): null,
    );
  }
}