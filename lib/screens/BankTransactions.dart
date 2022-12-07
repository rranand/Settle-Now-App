import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions/filterBankSMS.dart';

class BankTransactions extends StatefulWidget {
  final String email;
  final String token;

  const BankTransactions({Key? key, required this.email, required this.token})
      : super(key: key);

  @override
  State<BankTransactions> createState() => _BankTransactionsState();
}

class _BankTransactionsState extends State<BankTransactions> {
  late SharedPreferences prefs;
  List<SmsMessage> _messages = [];
  bool permissionGranted = false;
  final SmsQuery _query = SmsQuery();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<TransactionEach> sbiTransactions = [];
  bool isBankMessageLoadedOnce = false;

  Future<void> getAllSms() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.getBool("isBankMessageLoadedOnce") != null) {
      isBankMessageLoadedOnce = prefs.getBool("isBankMessageLoadedOnce")!;
    } else {
      prefs.setBool("isBankMessageLoadedOnce", isBankMessageLoadedOnce);
    }

    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
      );
      _messages = messages;
    } else {
      await Permission.sms.request();
      permissionGranted = await Permission.sms.isDenied;
    }

    if (permission.isGranted) {
      sbiTransactions = await filterSBISMS(_messages);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
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
                            "Bank Supported",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close))
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "State Bank of India",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Divider(),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                          "* Currently this feature in beta phase, may be transaction will not list properly.")
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
  }

  @override
  Widget build(BuildContext context) {
    if (!isBankMessageLoadedOnce) {
      Future.delayed(Duration.zero, () => showAlert(context));
      isBankMessageLoadedOnce = true;
      if (this.mounted) {
        setState(() {});
      }
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Bank Transactions"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: permissionGranted
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "SMS Permission Required",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 140,
                          child: OutlinedButton(
                            child: Text(
                              "Open Setting",
                              style: TextStyle(
                                  color: themeProvider.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16),
                            ),
                            onPressed: () {
                              openAppSettings();
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: 140,
                          child: OutlinedButton(
                            child: Text(
                              "Close",
                              style: TextStyle(
                                  color: themeProvider.isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )),
              )
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: getAllSms,
                child: sbiTransactions.isEmpty
                    ? ListView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                "No SMS Found",
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Scrollbar(
                          radius: Radius.circular(10.0),
                          thickness: 5.5,
                          child: ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(
                                    height: 5,
                                  ),
                              shrinkWrap: true,
                              itemCount: sbiTransactions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  child: Card(
                                    elevation: 1.0,
                                    shadowColor: Theme.of(context).primaryColor,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: sbiTransactions[index].type ==
                                                  "Credit"
                                              ? Colors.greenAccent
                                              : Colors.redAccent),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                sbiTransactions[index].receiver,
                                                style: TextStyle(fontSize: 24),
                                              ),
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.add,
                                                    color:
                                                        sbiTransactions[index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent,
                                                  ))
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                  width: 55,
                                                  height: 30,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      border: Border.all(
                                                        color: sbiTransactions[
                                                                        index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                        sbiTransactions[index]
                                                            .bank,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        )),
                                                  )),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Container(
                                                  width: 55,
                                                  height: 30,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      border: Border.all(
                                                        color: sbiTransactions[
                                                                        index]
                                                                    .type ==
                                                                "Credit"
                                                            ? Colors.greenAccent
                                                            : Colors.redAccent,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                        sbiTransactions[index]
                                                            .type,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        )),
                                                  )),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              sbiTransactions[index].mode ==
                                                      "Unknown"
                                                  ? SizedBox()
                                                  : Container(
                                                      width: 55,
                                                      height: 30,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          border: Border.all(
                                                            color: sbiTransactions[
                                                                            index]
                                                                        .type ==
                                                                    "Credit"
                                                                ? Colors
                                                                    .greenAccent
                                                                : Colors
                                                                    .redAccent,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Text(
                                                            sbiTransactions[
                                                                    index]
                                                                .mode,
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                            )),
                                                      )),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            "Amount: ₹ " +
                                                sbiTransactions[index].amount,
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Ref ID: " +
                                                sbiTransactions[index]
                                                    .transactionID,
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                              "Date: " +
                                                  sbiTransactions[index].date,
                                              style: TextStyle(fontSize: 17)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
              ),
      ),
    );
  }
}
