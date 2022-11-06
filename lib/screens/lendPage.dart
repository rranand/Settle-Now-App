import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/models/FriendEach.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

class LendPage extends StatefulWidget {
  final String email;
  final String token;
  final String name;
  const LendPage(
      {Key? key, required this.email, required this.token, required this.name})
      : super(key: key);

  @override
  State<LendPage> createState() => _LendPageState();
}

class _LendPageState extends State<LendPage> {
  List<dynamic> data = [];
  bool load = false;

  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  Future<void> addLoan(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.delete(Uri.parse(global.url + 'lend'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': widget.token
            },
            body: jsonEncode({
              "email": crypto.encrypt(widget.email),
              "name": crypto.encrypt(widget.name),
              "amount": crypto.encrypt(_amount.text),
              "purpose": crypto.encrypt(_purpose.text)
            }));

        if (response.statusCode == 200) {
          _purpose.text = "";
          _amount.text = "";
          Navigator.pop(context);
          _refreshIndicatorKey.currentState?.show();
        } else {
          showToast(
              context, crypto.decrypt(jsonDecode(response.body)["Message"]));
        }
      } on Exception catch (_) {
        Navigator.pop(context);
        showToast(context, "No Internet Connection");
      }
    }
  }

  Future _initialization() async {
    try {
      if (this.mounted) {
        setState(() {
          load = false;
          data.clear();
        });
      }

      final response = await http.put(Uri.parse(global.url + 'lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            "email": crypto.encrypt(widget.email),
            "name": crypto.encrypt(widget.name)
          }));

      if (response.statusCode == 200) {
        data = jsonDecode(response.body)['data'];
      } else {
        showToast(
            context, crypto.decrypt(jsonDecode(response.body)["Message"]));
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      showToast(context, "No Internet Connection");
    }

    load = true;

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  CloseRoom(BuildContext context) async {
    try {
      var CloseData = null;
      final response = await http.post(Uri.parse(global.url + 'lend/delete'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'name': crypto.encrypt(widget.name),
          }));

      CloseData = jsonDecode(response.body);
      showToast(context, crypto.decrypt(CloseData["Message"]));
    } on Exception catch (_) {
      Navigator.pop(context);
      showToast(context, "No Internet Connection");
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  closeRoomWidget(BuildContext context) {
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: SingleChildScrollView(
            child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Are You Sure?",
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "No",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                              onPressed: () async {
                                buildShowDialog(context);
                                await CloseRoom(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ))));
  }

  Widget friendListWidget(BuildContext context, List<FriendEach> data) {
    return StatefulBuilder(builder: (context, setState) {
      return ListView.separated(
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
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CachedNetworkImage(
                              imageUrl: data[index].isGoogle
                                  ? data[index].pic
                                  : (global.driveUrl +
                                      (data[index].pic.length == 0
                                          ? "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                          : data[index].pic)),
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) => Image(
                                  image:
                                      AssetImage('assets/Images/unknown.jpeg')),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 45.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Text(
                              data[index].name,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  if (data[index].status == "NJ") {
                                    //await sendLenDenJoinRequest(data[index].email);
                                    data[index].status = "S";
                                  } else {
                                    //await cancelLenDenJoinRequest(data[index].email);
                                    data[index].status = "NJ";
                                  }

                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                                icon: Icon(data[index].status == "NJ"
                                    ? Icons.person_add_alt
                                    : Icons.cancel_outlined))
                          ]),
                    ),
                  ),
                ));
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => closeRoomWidget(context),
                );
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _initialization,
          child: Scrollbar(
            radius: Radius.circular(10.0),
            thickness: 5.5,
            child: load
                ? (data.isEmpty
                    ? Center(
                        child: Text(
                          "No Loan Found",
                          style: TextStyle(fontSize: 25),
                        ),
                      )
                    : Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.95,
                          child: ListView.separated(
                            separatorBuilder: (context, index) => SizedBox(
                              height: 10,
                            ),
                            itemCount: data.length,
                            itemBuilder: (BuildContext context, int index) {
                              return SizedBox(
                                height: 85,
                                child: Card(
                                  elevation: 1.0,
                                  shadowColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              child: Text(
                                                crypto.decrypt(
                                                    data[index]["purpose"]),
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              onTap: () {
                                                showToast(
                                                    context,
                                                    crypto.decrypt(data[index]
                                                        ["purpose"]));
                                              },
                                            ),
                                          ),
                                          Text(
                                            "₹ " +
                                                crypto.decrypt(
                                                    data[index]["amount"]),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: (crypto.decrypt(data[
                                                                index]
                                                            ["amount"])[0] ==
                                                        "-"
                                                    ? Colors.red
                                                    : Colors.green)),
                                          ),
                                        ]),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ))
                : Center(
                    child: Text("Loading..."),
                  ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
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
                            "Add Credit/Debit",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _purpose,
                                  keyboardType: TextInputType.text,
                                  maxLength: 150,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 15),
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
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _amount,
                                  keyboardType: TextInputType.number,
                                  maxLength: 20,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 15),
                                  validator: (value) {
                                    RegExp validateNumber =
                                        RegExp(r'\b[1-9]{1}[\d]*\b');
                                    if (!validateNumber
                                        .hasMatch(_amount.text)) {
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
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 45,
                            width: MediaQuery.of(context).size.width * 0.95,
                            child: ElevatedButton(
                              child: Text(
                                "Add",
                                style: TextStyle(fontSize: 18),
                              ),
                              onPressed: () async {
                                buildShowDialog(context);
                                await addLoan(context);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          )
                        ],
                      ),
                    ),
                  );
                });
              });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
