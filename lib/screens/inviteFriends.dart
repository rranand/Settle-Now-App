import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/themes.dart';
import 'package:http/http.dart' as http;
import 'package:settlenow/routes/route_constant.dart';
import 'package:sqflite/sqflite.dart';
import 'package:settlenow/others/crypto.dart';

class InviteFriends extends StatefulWidget {
  final bool firstTime;
  const InviteFriends({Key? key, required this.firstTime}) : super(key: key);

  @override
  State<InviteFriends> createState() => _InviteFriendsState();
}

class _InviteFriendsState extends State<InviteFriends> {
  bool contactPermissionGranted = false;
  String _email = "";
  String _token = "";

  initialization() async {
    setBoolPrefs('isInvitePremissionPoppedProvided', true);
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
  }

  pushToDB(List<dynamic> allContacts, List<FriendEach> allContactsData) async {
    String path = await getDBFilePath('contact_data.db');

    Database database = await openDatabase(path, version: 1);

    await database.transaction((txn) async {
      for (int i = 0; i < allContactsData.length; i++) {
        try {
          await txn.rawInsert(
              'INSERT INTO ContactHasAccountOnSN(phoneNo, name, email) VALUES(?, ?, ?)',
              [
                allContactsData[i].phoneNo,
                allContactsData[i].name,
                allContactsData[i].email
              ]);
        } on Exception catch (err, stackTrace) {
          if (this.mounted) {
            onException(context, err, stackTrace,
                reason: "Unknwon Error",
                info: ["InviteFriends->pushToDB->allContactsData"]);
          }
        }
      }
      for (int i = 0; i < allContacts.length; i++) {
        try {
          await txn.rawInsert(
              'INSERT INTO ContactHasNoAccountOnSN(phoneNo) VALUES(?)',
              [allContacts[i]]);
        } on Exception catch (err, stackTrace) {
          if (this.mounted) {
            onException(context, err, stackTrace,
                reason: "Unknwon Error",
                info: ["InviteFriends->pushToDB->allContacts"]);
          }
        }
      }
    });

    await database.close();
  }

  getContacts() async {
    buildShowDialog(context);
    try {
      List<Contact> contacts = await FlutterContacts.getContacts();
      List<String> allContacts = [];
      for (int i = 0; i < contacts.length; i++) {
        List<Phone> phoneList = contacts[i].phones;
        for (int j = 0; j < phoneList.length; j++) {
          allContacts.add(fixPhoneNumber(phoneList[j].number));
        }
      }
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'contacts': crypto.encrypt(allContacts.toString())
      };

      final response = await createHTTPreq(
          'profile/localContact', http.post, _token, jsonInputData, context);

      var resData = jsonDecode(response.body)['data'];

      if (response.statusCode == 200) {
        List<FriendEach> allContactsData = [];
        for (int i = 0; i < resData.length; i++) {
          allContacts
              .removeWhere((element) => element == resData[i]['phoneNo']);
          allContactsData.add(FriendEach.forLocal(resData[i]));
        }

        pushToDB(Set.from(allContacts).toList(), allContactsData);
        showToast(context, "Contacts Imported Successfully", Icons.done);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["InviteFriends->getContacts"]);
      }
    }

    if (this.mounted) {
      context.pop(contactPermissionGranted);
    }
    if (this.mounted) {
      context.pop(contactPermissionGranted);
    }
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  Future<void> getContactPermission() async {
    bool permissionGranted = await Permission.contacts.isGranted;

    var permission = await Permission.contacts.status;

    var flags = await Future.wait([
      Permission.contacts.isDenied,
      Permission.contacts.isPermanentlyDenied
    ]);

    permissionGranted = flags[0] || flags[1];
    permissionGranted = !permissionGranted;

    if (!permission.isGranted) {
      permission = await Permission.contacts.request();
      flags = await Future.wait([
        Permission.contacts.isDenied,
        Permission.contacts.isPermanentlyDenied
      ]);

      permissionGranted = flags[0] || flags[1];
      permissionGranted = !permissionGranted;
    }

    if (permissionGranted) {
      contactPermissionGranted = true;
      await getContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: !widget.firstTime,
          title: Text(
            "Import Contacts",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      body: PopScope(
        canPop: false,
        onPopInvoked: ((didPop) {
          if (didPop) {
            return;
          }
          context.pop(contactPermissionGranted);
        }),
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Use your contacts to find friends on Settle Now. So that, you can invite them in rooms easily. We don't store your contacts.",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 29,
                  ),
                  Center(
                    child: Opacity(
                      opacity: 0.8,
                      child: SizedBox(
                        height: 70,
                        child: Card(
                          elevation: 1.0,
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                                  Container(
                                    width: 45.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Images/unknown.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 250,
                                    child: InkWell(
                                      onTap: () {},
                                      child: AutoSizeText(
                                        "Aashi",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 17),
                                        maxFontSize: 21,
                                        minFontSize: 17,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.person_add_alt))
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Opacity(
                      opacity: 0.6,
                      child: SizedBox(
                        height: 70,
                        child: Card(
                          elevation: 1.0,
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                                  Container(
                                    width: 45.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Images/unknown.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 250,
                                    child: InkWell(
                                      onTap: () {},
                                      child: AutoSizeText(
                                        "Aditya",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 17),
                                        maxFontSize: 21,
                                        minFontSize: 17,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.person_add_alt))
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Opacity(
                      opacity: 0.4,
                      child: SizedBox(
                        height: 70,
                        child: Card(
                          elevation: 1.0,
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                                  Container(
                                    width: 45.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Images/unknown.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 250,
                                    child: InkWell(
                                      onTap: () {},
                                      child: AutoSizeText(
                                        "Suhani",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 17),
                                        maxFontSize: 21,
                                        minFontSize: 17,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.person_add_alt))
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Opacity(
                      opacity: 0.2,
                      child: SizedBox(
                        height: 70,
                        child: Card(
                          elevation: 1.0,
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                                  Container(
                                    width: 45.0,
                                    height: 45.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Images/unknown.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 250,
                                    child: InkWell(
                                      onTap: () {},
                                      child: AutoSizeText(
                                        "Ritika",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 17),
                                        maxFontSize: 21,
                                        minFontSize: 17,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.person_add_alt))
                                ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 46,
                      child: OutlinedButton(
                        child: Text(
                          "Give Permission",
                          style: TextStyle(
                              color: themeProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        onPressed: () async {
                          bool isPermanent =
                              await Permission.contacts.isPermanentlyDenied;
                          if (isPermanent) {
                            openAppSettings();
                          } else {
                            await getContactPermission();
                          }
                          if (this.mounted) {
                            context.pop(false);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 46,
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
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          side: BorderSide(color: Colors.redAccent),
                        ),
                        onPressed: () async {
                          context.pop(false);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
