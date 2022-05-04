import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:settlenow/screens/lendPage.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

class LendCredit extends StatefulWidget {
  final String email;
  final String token;

  const LendCredit({ Key? key, required this.email, required this.token}) : super(key: key);

  @override
  State<LendCredit> createState() => _LendCreditState();
}

class _LendCreditState extends State<LendCredit> {
  List<dynamic> data = [];
  bool load = false;
  final TextEditingController _name = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  _showToast(BuildContext context, String show) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(show),
        action: SnackBarAction(label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Future createRoom(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(global.url + 'lend'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          "email": crypto.encrypt(widget.email),
          "name": crypto.encrypt(_name.text)
        })
      );
      
      if (response.statusCode == 200) {
        Navigator.pop(context);
        _refreshIndicatorKey.currentState?.show();
        _name.text = "";
      } else {
        _showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']));
      }
    } on Exception catch(_)  {
      _showToast(context, "No Internet Connection");
    }

    if (this.mounted) {
      setState(() {});
    }
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

  Future _initialization() async {
    try {
      if (this.mounted) {
        setState(() {
          load = false;
          data.clear();
        });
      }

      final response = await http.patch(
        Uri.parse(global.url + 'lend'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': widget.token
        },
        body: jsonEncode({
          "email": crypto.encrypt(widget.email)
        })
      );

      if (response.statusCode == 200) {
        data = jsonDecode(response.body)['data'];
      } else {
        _showToast(context, crypto.decrypt(jsonDecode(response.body)["Message"]));
      }
      
    } on Exception catch(_)  {
      Navigator.pop(context);
      _showToast(context, "No Internet Connection");
    }

    load = true;

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Len Den"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _initialization,
        child: Scrollbar(
          radius: Radius.circular(10.0),
          thickness: 5.5,
          child: load?(data.isEmpty?Center(child: Text("No Room Found", style: TextStyle(fontSize: 25),),):Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.95,
              child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(height: 10,), 
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LendPage(email: widget.email, token: widget.token, name: crypto.decrypt(data[index]["name"]),))),
                    child: SizedBox(
                      height: 90,
                      child: Card(
                        elevation: 1.0,
                        shadowColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              crypto.decrypt(data[index]["name"]), 
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            Text(
                              "₹ " + crypto.decrypt(data[index]["total"]),
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ]
                        ),
                      ),
                                      ),
                    ),
                  );
                }, 
              ),
            ),
          ))
          :Center(child: Text("Loading..."),),
        )
      ),
      floatingActionButton: FloatingActionButton(
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
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Create New Room",
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 10,),
                          TextField(
                            controller: _name,
                            keyboardType: TextInputType.text,
                            maxLength: 150,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 18),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(8.0),
                              hintText: "Enter Room Name",
                              labelText: "Name",
                              errorStyle: TextStyle(fontSize: 15),
                            ),
                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            height: 40,
                            width: MediaQuery.of(context).size.width*0.95,
                            child: ElevatedButton(
                              child: Text("Create", style: TextStyle(fontSize: 18),),
                              onPressed: () async {
                                buildShowDialog(context);
                                await createRoom(context);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(height: 15,)
                        ],
                      ),
                    ),
                  );
                }
              );
            }
          );
        },
      ),
    );
  }
}