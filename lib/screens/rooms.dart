import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/displayvideo/v1.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;
import '../others/themes.dart';
import 'package:share_plus/share_plus.dart';

class RoomExpense extends StatefulWidget {
  final String roomKey;
  final String email;
  final String roomName;
  final String token;
  final String roomLink;
  const RoomExpense({ Key? key , required this.roomKey, required this.email, required this.roomName, required this.token, required this.roomLink}) : super(key: key);

  @override
  _RoomExpenseState createState() => _RoomExpenseState();
}

class _RoomExpenseState extends State<RoomExpense> {
  List<dynamic> list = [];
  List<dynamic> TransList = [];
  final TextEditingController _amt = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  bool isClear = false;
  bool loaded = false;
  double heightExpense = 0;
  final _formKey = GlobalKey<FormState>();
  final Shader linearGradient = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 243, 236, 120), Color.fromARGB(255, 175, 66, 97), Color.fromARGB(255,241, 143, 67), Color.fromARGB(255, 139, 152, 98)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Shader linearGradient_2 = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 0, 219, 222), Color.fromARGB(255, 252, 0, 255)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Shader linearGradient_3 = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 243, 33, 112), Color.fromARGB(255,33, 150, 243), Color.fromARGB(255, 255, 0, 235)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  
  String expenseTitle = "All Expense";

  List<String> membersListName = [];
  List<String> membersListEmail = [];
  int membersListIndex = 0;
  int membersListIndexS = 0;
  int membersListIndexR = 1;
  bool defaultPage = true;
  bool payment = false;
  String paymentTotal = "";
  bool isLoadedDef = false;
  List<dynamic> paymentData = [];

  Future _initialisation() async {
    try {
      final response = await http.patch(
        Uri.parse(global.url + 'data'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          'roomKey': crypto.encrypt(widget.roomKey),
          'email': crypto.encrypt(widget.email),
        })
      );  

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        list.clear();
        list = data['data'];
        isClear = list[0]["done"];
        membersListName.clear();
        membersListEmail.clear();
        
        for(int i=1; i<list.length; i++) {
          membersListName.add(crypto.decrypt(list[i]["Name"]));
          membersListEmail.add(crypto.decrypt(list[i]["email"]));
        }
        
        if (this.mounted) {
          setState(() {});
        }
      } else {
        _showToast(context, crypto.decrypt(data["Message"]));
      }
    } on Exception catch(_) {
      _showToast(context, "No Internet Connection");
    }

    _extractExpenseData("all");
  }

  Future _extractExpenseData(String email) async {
    if (this.mounted) {
      setState(() {
        heightExpense = 0;
        loaded = false;
        TransList.clear();
      });
    }
    try {
      final response = await http.post(
        Uri.parse(global.url + 'transaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          'email': crypto.encrypt(email),
          'roomKey': crypto.encrypt(widget.roomKey),
        })
      );

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        if (TransData != null) {
          TransList =  jsonDecode(response.body)['data'];
        }
      } else {
        _showToast(context, crypto.decrypt(TransData["Message"]));
      }
      
    } on Exception catch(_) {
      _showToast(context, "No Internet Connection");
    }

    heightExpense = 30 + TransList.length*125+(TransList.length-1)*5;

    if (this.mounted) {
      setState(() {});
    }
  }

  AddExpense(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var Tdata = null;
      buildShowDialog(context);

      try {
        final response = await http.delete(
          Uri.parse(global.url + 'data'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'roomKey': crypto.encrypt(widget.roomKey),
            'purpose': crypto.encrypt(_purpose.text),
            'amt':crypto.encrypt(_amt.text),
          })
        );
        
        _amt.text = "";
        _purpose.text = "";
        Tdata = jsonDecode(response.body);
        Navigator.pop(context);
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
  }

  PayToMember(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      var Tdata = null;
      buildShowDialog(context);

      try {
        final response = await http.put(
          Uri.parse(global.url + 'data'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'emailS': crypto.encrypt(widget.email),
            'emailR': crypto.encrypt(membersListEmail[membersListIndex]),
            'roomKey': crypto.encrypt(widget.roomKey),
            'amt':crypto.encrypt(_amt.text),
          })
        );
        
        _amt.text = "";
        Tdata = jsonDecode(response.body);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);

        _refreshIndicatorKey.currentState?.show();
        
        _showToast(context, crypto.decrypt(Tdata["Message"]));
      } on Exception catch(_) {
        Navigator.pop(context);
        _showToast(context, "No Internet Connection");
      }
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  retrievePaymentData() async {
    try {
      if (membersListIndexS == membersListIndexR) {
        _showToast(context, "Same User");
      } else {
        paymentData.clear();
        if (this.mounted) {
          setState(() {
            isLoadedDef = true;
            payment = true;
          });
        }
        final response = await http.delete(
          Uri.parse(global.url + 'transaction'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'emailS': crypto.encrypt(membersListEmail[membersListIndexS]),
            'emailR': crypto.encrypt(membersListEmail[membersListIndexR]),
            'roomKey': crypto.encrypt(widget.roomKey),
          })
        );
        
        if (response.statusCode == 200) {
          paymentData = jsonDecode(response.body)["data"];
          paymentTotal = crypto.decrypt(jsonDecode(response.body)["total"]);
          payment = false;
          if (this.mounted) {
            setState(() {});
          }
        } else {
          _showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]));
        }
      }
    } on Exception catch(_) {
      Navigator.pop(context);
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

  CloseRoom(BuildContext context) async{
    buildShowDialog(context);
    try {
      var CloseData = null;
      final response = await http.delete(
        Uri.parse(global.url + 'room'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.email),
          'roomKey': crypto.encrypt(widget.roomKey),
        })
      );
      isClear = true;
      CloseData = jsonDecode(response.body);
      _showToast(context, crypto.decrypt(CloseData["Message"]));
      Navigator.pop(context);
      _refreshIndicatorKey.currentState?.show();
    } on Exception catch(_) {
      Navigator.pop(context);
      _showToast(context, "No Internet Connection");
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  closeRoomWidget(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), 
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Are You Sure?",
                  style: TextStyle(
                    fontSize: 25
                  ),
                ),
                SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No"),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () async{
                          buildShowDialog(context);
                          await CloseRoom(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text("Yes"),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        )
      )
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName),
        actions: [
          IconButton(
            onPressed: () {
              if (membersListName.length <= 1) {
                _showToast(context, "More Than One Member Required");
              } else {
                setState(() {
                  defaultPage = !defaultPage;
                });
              }
              
            }, 
            icon: Icon(Icons.transfer_within_a_station_rounded, color: themeProvider.darkTheme?Colors.white:Colors.black,))
        ],
      ),
      body: defaultPage?RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _initialisation,
        child: list.isEmpty? 
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text("Loading..."),
          ),
        )
        :Scrollbar(
          radius: Radius.circular(10.0),
          thickness: 10.5,
          child: ListView(
              children: [
                InkWell(
                  child: ListTile(
                    title: const Text("Room Key"),
                    trailing: Text(widget.roomKey),
                  ),
                  onTap: () async {
                    await Share.share("Join "+ widget.roomName + "\nRoom Key: " + widget.roomKey + "\n" + widget.roomLink);
                  },
                  onLongPress: () async {
                    Clipboard.setData(ClipboardData(text: widget.roomKey));
                    _showToast(context, "Join Key Copied");
                  },
                ),
                ListTile(
                  title: const Text("Total Expense"),
                  trailing: Text(crypto.decrypt(list[0]["TotalExpense"])),
                ),
                ListTile(
                  title: const Text("Average Expense"),
                  trailing: Text(crypto.decrypt(list[0]["AverageExpense"])),
                ),
                ListTile(
                  title: const Text("Members"),
                  trailing: Text(crypto.decrypt(list[0]["cnt"])),
                ),
                ListTile(
                  title: const Text("Created On"),
                  trailing: Text(crypto.decrypt(list[0]["date"])),
                ),
                !isClear?Padding(
                  padding: EdgeInsets.all(15.0),
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      child: const Text("Close Room", style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        if (!isClear) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => closeRoomWidget(context),
                          );
                        } else {
                          _showToast(context, "Room Already Closed By You");
                        }
                      },
                    ),
                  ),
                ):SizedBox(),
                const Divider(),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Member",
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
                        height: 190,
                        child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == 0) {
                            return SizedBox(
                              height: 190,
                              width: 180,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    if (this.mounted) {
                                      setState(() {
                                        expenseTitle = "All Expense";
                                      });
                                    }
                                    _extractExpenseData("all");
                                  },
                                  child: Card(
                                    elevation: 5.0,
                                    shadowColor: Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          "ALL",
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            foreground: Paint()..shader = linearGradient_3,
                                          ),
                                        ),
                                      )
                                    )
                                  )
                                )
                              )
                            );
                          } else {
                            return SizedBox(
                              height: 190,
                              width: 175,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    if (this.mounted) {
                                      expenseTitle = crypto.decrypt(list[index]['Name']) + "\'s Expense";
                                    }
                                    _extractExpenseData(crypto.decrypt(list[index]['email']));
                                  },
                                  child: Card(
                                    elevation: 5.0,
                                    shadowColor:  Theme.of(context).primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 8,
                                          ),
                                          InkWell(
                                            child: Text(
                                              crypto.decrypt(list[index]['Name']),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w500,
                                                foreground: Paint()..shader = linearGradient,
                                              ),
                                            ),
                                            onTap: () => _showToast(context, crypto.decrypt(list[index]['Name'])),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Text(
                                            "Total: ₹ " + crypto.decrypt(list[index]['Expense']),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              foreground: Paint()..shader = linearGradient_2,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          double.parse(double.parse(crypto.decrypt(list[index]["current"])).toStringAsFixed(2))>0?
                                          Text(
                                            "Gain: ₹ " + double.parse(crypto.decrypt(list[index]["current"])).toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.green,
                                            ),
                                          ):double.parse(double.parse(crypto.decrypt(list[index]["current"])).toStringAsFixed(2))<0?Text(
                                            "Loss: ₹ " + double.parse(crypto.decrypt(list[index]["current"])).toStringAsFixed(2),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red,
                                            ),
                                          ):SizedBox(),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: Text(
                                              (list[index]['own']?"👑 ":"") + (list[index]['done']?"🔒":""),
                                              style: TextStyle(
                                                fontSize: 20
                                              ),
                                            )
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        expenseTitle,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TransList.isEmpty? (
                        Center(
                          child: loaded? Text(
                            "No Expense Found",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                          :CircularProgressIndicator()
                        )
                      )
                      :SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: heightExpense,
                          child: ExpenseData(TransList: TransList,RoomKey: widget.roomKey, Email: widget.email, Token: widget.token, refreshIndicatorKey: _refreshIndicatorKey,),
                        ),
                    ],
                  ),
                )
              ],
            ),
        ),
      ):Scrollbar(
          radius: Radius.circular(10.0),
          thickness: 10.5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "From"
                            ),
                            DropdownButton<String>(
                              alignment: AlignmentDirectional.topStart,
                              borderRadius: BorderRadius.circular(10.0),
                              itemHeight: 60,
                              elevation: 1,
                              hint: Text(
                                membersListName[membersListIndexS],
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              items: membersListName.map((String value) {
                                return DropdownMenuItem<String>(
                                  alignment: AlignmentDirectional.center,
                                  value: membersListName.indexOf(value).toString(),
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (index) {
                                setState(() {
                                  membersListIndexS = int.parse(index!);
                                });
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "To"
                            ),
                            DropdownButton<String>(
                              alignment: AlignmentDirectional.topStart,
                              borderRadius: BorderRadius.circular(10.0),
                              itemHeight: 60,
                              elevation: 1,
                              hint: Text(
                                membersListName[membersListIndexR],
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              items: membersListName.map((String value) {
                                return DropdownMenuItem<String>(
                                  alignment: AlignmentDirectional.center,
                                  value: membersListName.indexOf(value).toString(),
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (index) {
                                setState(() {
                                  membersListIndexR = int.parse(index!);
                                });
                              },
                            ),
                          ],
                        ),
                        ElevatedButton(
                          child: const Text("Search", style: TextStyle(color: Colors.white),),
                          onPressed: () {
                            retrievePaymentData();
                          },
                        ),
                      ],
                    ),
                  ),
                  isLoadedDef?
                  paymentData.isEmpty?
                  (payment? 
                    Center(
                      child: Text("Loading..."),
                    ):Center(
                      child: Text("No Results Found!!!", style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                      ),),
                    )
                  ):
                  Column(
                    children: [
                      Text(
                        "Total Amount Paid: ₹ " + paymentTotal,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => SizedBox(height: 5,),
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: paymentData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              height: 70,
                              child: Card(
                                elevation: 5.0,
                                shadowColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.90,
                                          child: Opacity(
                                            opacity: 0.8,
                                            child: Text(
                                              crypto.decrypt(paymentData[index]["Date"]),
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.20,
                                          child: Text(
                                            "₹ " + crypto.decrypt(paymentData[index]["Amount"]),
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                              )
                            );
                          }
                        ),
                      ),
                    ]
                  ):SizedBox()
                ],
              ),
            ),
          )
      ),
      floatingActionButton: !isClear?FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: SizedBox(
                  height: 120,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Icon(Icons.money, color: Theme.of(context).primaryColor,),
                          title: const Text("Pay to Member"),
                          onTap: () {
                            if (membersListName.length <= 1) {
                              _showToast(context, "More Than One Member Required");
                            } else {
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
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 12.0),
                                                      child: Text("Select Member",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                          ),
                                                      ),
                                                    ),
                                                    DropdownButton<String>(
                                                      alignment: AlignmentDirectional.topEnd,
                                                      borderRadius: BorderRadius.circular(10.0),
                                                      itemHeight: 60,
                                                      elevation: 1,
                                                      hint: Text(
                                                        membersListName[membersListIndex],
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      items: membersListName.map((String value) {
                                                        return DropdownMenuItem<String>(
                                                          alignment: AlignmentDirectional.center,
                                                          value: membersListName.indexOf(value).toString(),
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                      onChanged: (index) {
                                                        setState(() {
                                                          membersListIndex = int.parse(index!);
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                              SizedBox(
                                                height: 40,
                                                width: 100,
                                                child: ElevatedButton(
                                                  child: const Text("Add", style: TextStyle(color: Colors.white),),
                                                  onPressed: () {
                                                    PayToMember(context);
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
                                }
                              );
                            }
                          }
                        ),
                        ListTile(
                          leading: Icon(Icons.add, color: Theme.of(context).primaryColor,),
                          title: const Text("Add Expense"),
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
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
                                        SizedBox(
                                          height: 40,
                                          width: 100,
                                          child: ElevatedButton(
                                            child: const Text("Add", style: TextStyle(color: Colors.white),),
                                            onPressed: () {
                                              AddExpense(context);
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
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.edit, color: Colors.white,),
      ):null
    );
  }
}

class ExpenseData extends StatefulWidget {
  final List<dynamic> TransList;
  final String RoomKey;
  final String Email;
  final String Token;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey;
  ExpenseData({ Key? key, required this.TransList, required this.RoomKey, required this.Email, required this.Token, required this.refreshIndicatorKey }) : super(key: key);

  @override
  State<ExpenseData> createState() => _ExpenseDataState();
}

class _ExpenseDataState extends State<ExpenseData> {
  final TextEditingController _purpose = TextEditingController(); 
  final TextEditingController _amount = TextEditingController();
  final _updateExpense = GlobalKey<FormState>();

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

  _updateTransaction(BuildContext context, String purpose, String id, String amount, String flag) async {
    try {
      final response = await http.patch(
        Uri.parse(global.url + 'transaction'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.Token
        },
        body: jsonEncode({
          'email': crypto.encrypt(widget.Email),
          'roomKey': crypto.encrypt(widget.RoomKey),
          'purpose': crypto.encrypt(purpose),
          'amount': crypto.encrypt(amount),
          'id': crypto.encrypt(id),
          'flag': crypto.encrypt(flag)
        })
      );

      var updateMessage = jsonDecode(response.body);
      _showToast(context, crypto.decrypt(updateMessage["Message"]));
      widget.refreshIndicatorKey.currentState?.show();
    } on Exception catch(_) {
      _showToast(context, "No Internet Connection");
    }
  }

  Widget _buildUpdateDialog(BuildContext context,String id, String purpose, String amount) {
    return StatefulBuilder(
      builder: (context, setState) {
        _purpose.text = purpose;
        _amount.text = amount;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), 
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
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 18),
                        autocorrect: false,
                        validator: (value) {
                          RegExp validateNumber = RegExp(r'\b[1-9]{1}[\d]*\b');
                          if (!validateNumber.hasMatch(_amount.text)) {
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
                      SizedBox(height: 10,),
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
                      SizedBox(height: 15,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width*0.3,
                            child: ElevatedButton(
                              child: const Text("Delete", style: TextStyle(color: Colors.white),),
                              onPressed: () async {
                                buildShowDialog(context);
                                await _updateTransaction(context, _purpose.text, id, _amount.text, "1");
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width*0.3,
                            child: ElevatedButton(
                              child: const Text("Update", style: TextStyle(color: Colors.white),),
                              onPressed: () async {
                                if (_updateExpense.currentState!.validate()) {
                                  buildShowDialog(context);
                                  await _updateTransaction(context, _purpose.text, id, _amount.text, "0");
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              }
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              )
            ),
          )
        );
      }
    );
  }

  Widget _buildPopupDialog(BuildContext context, String name, String date, String email, String id, String purpose, String amount) {
    return StatefulBuilder(
      builder: (context, setState) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _purpose.text,
                        style: TextStyle(
                          fontSize: 30
                        ),
                      ),
                      widget.Email==email?IconButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => _buildUpdateDialog(context, id, purpose, amount),
                          );
                        },
                        icon: Icon(Icons.edit)
                      ):SizedBox()
                    ],
                  ),
                  SizedBox(height: 25,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(
                            fontSize: 20
                          ),),
                          SizedBox(height: 10,),
                          Text("Date: " + date, style: TextStyle(
                            fontSize: 20
                          ),),
                        ],
                      ),
                      Text("₹ " + _amount.text, style: TextStyle(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 5,),
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: widget.TransList.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              _purpose.text = crypto.decrypt(widget.TransList[index]["Purpose"]);
              _amount.text = crypto.decrypt(widget.TransList[index]["Amount"]);
              showDialog(
                context: context,
                builder: (BuildContext context) => _buildPopupDialog(context, crypto.decrypt(widget.TransList[index]["Name"]), crypto.decrypt(widget.TransList[index]["Date"]), crypto.decrypt(widget.TransList[index]["Email"]), crypto.decrypt(widget.TransList[index]["id"]), crypto.decrypt(widget.TransList[index]["Purpose"]), crypto.decrypt(widget.TransList[index]["Amount"])),
              );
            },
            child: SizedBox(
              height: 125,
              child: Card(
                elevation: 5.0,
                shadowColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
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
                            Text(
                              crypto.decrypt(widget.TransList[index]["Purpose"]), 
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Opacity(
                              opacity: 0.8,
                              child: Text(
                                crypto.decrypt(widget.TransList[index]["Name"]),
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Opacity(
                              opacity: 0.8,
                              child: Text(
                                crypto.decrypt(widget.TransList[index]["Date"]),
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
                            "₹ " + crypto.decrypt(widget.TransList[index]["Amount"]),
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              )
            ),
          );
        }
      ),
    );
  }
}