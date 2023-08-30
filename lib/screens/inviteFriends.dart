import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/others/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import '../contents.dart' as global;
import 'package:settlenow/others/crypto.dart';

class InviteFriends extends StatefulWidget {
  final String email;
  final String token;
  final bool firstTime;
  const InviteFriends(
      {Key? key,
      required this.email,
      required this.token,
      required this.firstTime})
      : super(key: key);

  @override
  State<InviteFriends> createState() => _InviteFriendsState();
}

class _InviteFriendsState extends State<InviteFriends> {
  late SharedPreferences prefs;
  bool contactPermissionGranted = false;

  initialization() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool("isInvitePremissionProvided", true);
  }

  pushToDB(List<dynamic> allContacts, List<FriendEach> allContactsData) async {
    String path = await getDBFilePath('contact_data.db');

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE ContactHasNoAccountOnSN (phoneNo TEXT PRIMARY KEY)');
      await db.execute(
          'CREATE TABLE ContactHasAccountOnSN (phoneNo TEXT PRIMARY KEY, name TEXT, email TEXT)');
    });

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
        } on Exception catch (_) {}
      }
      for (int i = 0; i < allContacts.length; i++) {
        try {
          await txn.rawInsert(
              'INSERT INTO ContactHasNoAccountOnSN(phoneNo) VALUES(?)',
              [allContacts[i]]);
        } on Exception catch (_) {}
      }
    });

    await database.close();
  }

  getContacts() async {
    buildShowDialog(context);
    try {
      List<Contact> contacts = await ContactsService.getContacts(
          withThumbnails: false,
          androidLocalizedLabels: false,
          photoHighResolution: false);
      List<String> allContacts = [];

      for (int i = 0; i < contacts.length; i++) {
        Map<dynamic, dynamic> tempMap = contacts[i].toMap();
        for (int j = 0; j < contacts[i].phones!.length; j++) {
          allContacts.add(fixPhoneNumber(tempMap['phones'][j]['value']));
        }
      }

      final response = await http.post(
          Uri.parse(global.url + 'profile/localContact'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'contacts': crypto.encrypt(allContacts.toString())
          }));

      var resData = jsonDecode(response.body)['data'];

      if (response.statusCode == 200) {
        List<FriendEach> allContactsData = [];
        for (int i = 0; i < resData.length; i++) {
          allContacts
              .removeWhere((element) => element == resData[i]['phoneNo']);
          allContactsData.add(FriendEach.fromLocal(resData[i]));
        }

        pushToDB(Set.from(allContacts).toList(), allContactsData);
        showToast(context, "Contacts Imported Successfully", Icons.done);
      }
    } on Exception catch (_) {}

    if (this.mounted) {
      Navigator.pop(context, contactPermissionGranted);
    }
    if (this.mounted) {
      Navigator.pop(context, contactPermissionGranted);
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
      body: WillPopScope(
        onWillPop: () {
          Navigator.pop(context, contactPermissionGranted);
          return new Future(() => false);
        },
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
                        shadowColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        shadowColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Asmee",
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
                        shadowColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Raveena",
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
                        shadowColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      "Anala",
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
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () async {
                        await getContactPermission();
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
                        Navigator.pop(context, false);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
