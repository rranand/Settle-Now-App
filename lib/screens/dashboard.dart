import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/models/RoomEach.dart';
import 'package:settlenow/others/GoogleSignIN.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/route_service.dart';
import 'package:settlenow/screens/BankTransactions.dart';
import 'package:settlenow/screens/aboutus.dart';
import 'package:settlenow/screens/contactUs.dart';
import 'package:settlenow/screens/expenses.dart';
import 'package:settlenow/screens/lendCredit.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:settlenow/screens/profile.dart';
import 'package:settlenow/screens/rooms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contents.dart' as global;
import '../notificationService/notification_service.dart';
import '../others/themes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'maintain.dart';
import 'package:http_parser/http_parser.dart';

class ShareMessage {
  final String title;
  final String subject;
  final String photo;
  final String web;
  final String playstore;

  ShareMessage(
      {required this.title,
      required this.subject,
      required this.photo,
      required this.web,
      required this.playstore});

  factory ShareMessage.fromJson(Map<String, dynamic> json) {
    return ShareMessage(
      title: crypto.decrypt(json['title']),
      subject: crypto.decrypt(json['subject']),
      photo: crypto.decrypt(json['photo']),
      web: crypto.decrypt(json['web']),
      playstore: crypto.decrypt(json['playstore']),
    );
  }
}

class DashBoard extends StatefulWidget {
  final String version;
  const DashBoard({Key? key, required this.version}) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  AppUpdateInfo? _updateInfo;
  final InAppReview inAppReview = InAppReview.instance;
  int dash = 0;
  double yourSpend = 0;
  bool isGoogle = false;
  var now;
  String date = "";
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _search = TextEditingController();
  String _token = "";
  int appOpened = 0;
  late SharedPreferences prefs;
  final TextEditingController _NRoom = TextEditingController();
  final List<RoomEach> RoomDataO = [];
  final List<RoomEach> RoomDataC = [];
  final List<RoomEach> SearchRoomData = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _requestIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final _CformKey = GlobalKey<FormState>();
  final _JformKey = GlobalKey<FormState>();
  bool searchTrigger = false;
  bool searching = false;
  bool dateIndex = true;
  List<String> Year = [];
  bool isImageLoaded = false;
  bool isRoomRequestLoaded = false;
  bool gotInitialData = false;
  List<dynamic> expenseCategory = [];
  List<dynamic> investmentCategory = [];
  List<dynamic> roomExpenseCategory = [];
  late ShareMessage shareMessage;
  List<String> Month = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<String> Date = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
    '30',
    '31'
  ];
  bool initalDataLoaded = false;
  List<int> from = [];
  List<int> to = [];
  bool error = false;
  String errorText = "";
  bool DateChanged = false;
  double heightSearched = 0;
  var updateData = null;
  List<String> roomStatus = ['All', 'Active', 'Closed'];
  int roomStatusIndex = 0;
  bool imageUploading = false;
  bool haveImg = false;
  bool open = true;
  String amtSpend = "";
  double amtSpendOpen = 0;
  double amtSpendClose = 0;
  String _profilePicID = "";
  List<dynamic> RoomRequest = [];
  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  bool isBankMessageLoadedOnce = false;
  bool _flexibleUpdateAvailable = false;

  Future<void> checkForUpdate() async {
    await InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) {});

    if (_updateInfo?.updateAvailability == UpdateAvailability.updateAvailable) {
      await InAppUpdate.startFlexibleUpdate().then((_) {
        setState(() {
          _flexibleUpdateAvailable = true;
        });
      }).catchError((e) {});

      await InAppUpdate.completeFlexibleUpdate();
    }
  }

  Future _getImageID() async {
    if (this.mounted) {
      setState(() {
        haveImg = false;
      });
    }

    try {
      if (isGoogle) {
        _profilePicID = (await _currentUser!.photoUrl).toString();
        haveImg = true;
      } else {
        final response = await http.put(Uri.parse(global.url + 'login'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': _token
            },
            body: jsonEncode({
              'email': crypto.encrypt(_email.text),
            }));

        if (response.statusCode == 200) {
          var imgData = jsonDecode(response.body);

          if (imgData['havePic']) {
            _profilePicID = crypto.decrypt(imgData["fileId"]);
            haveImg = true;
          } else {
            _profilePicID = "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8";
            haveImg = true;
          }
        }
      }
    } on Exception catch (_) {
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getInitialData() async {
    now = DateTime.now();
    date = (now.month - 1).toString() + now.year.toString();
    try {
      final response = await http.patch(Uri.parse(global.url + 'profile'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'email': crypto.encrypt(_email.text),
          }));

      if (response.statusCode == 200) {
        gotInitialData = true;
        var data = jsonDecode(response.body);
        expenseCategory = data['expenseCategory'];
        for (int i = 0; i < expenseCategory.length; i++) {
          expenseCategory[i] = crypto.decrypt(expenseCategory[i]);
        }
        investmentCategory = data['investmentCategory'];
        for (int i = 0; i < investmentCategory.length; i++) {
          investmentCategory[i] = crypto.decrypt(investmentCategory[i]);
        }
        roomExpenseCategory = data['roomExpenseCategory'];
        for (int i = 0; i < roomExpenseCategory.length; i++) {
          roomExpenseCategory[i] = crypto.decrypt(roomExpenseCategory[i]);
        }
        shareMessage = ShareMessage.fromJson(data['shareMessage']);
      }
    } on Exception catch (_) {}

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> rateUs() =>
      inAppReview.openStoreListing(appStoreId: 'com.rohit.settlenow');

  Future imageUpload(ImageSource imageSource) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: imageSource,
      imageQuality: 25,
    );
    Dio dio = new Dio();

    if (image != null) {
      double sz = (await image.length()) / (1024 * 1024);
      if (sz > 10) {
        showToast(context, "Image Size is too large", Icons.close);
        return;
      }

      if (this.mounted) {
        setState(() {
          imageUploading = true;
        });
      }

      try {
        String ext = image.path.split('.').last;

        FormData formData = new FormData.fromMap({
          "image": await MultipartFile.fromFile(image.path,
              contentType: new MediaType('image', ext)),
          "type": "image/" + ext,
          "email": crypto.encrypt(_email.text),
        });

        final response = await dio.delete(global.url + 'login',
            data: formData,
            options: Options(headers: {
              "Content-Type": "multipart/form-data",
              'Auth': _token
            }));

        if (response.statusCode == 200) {
          await _getImageID();
          showToast(context, "Image Uploaded Successfully", Icons.check);
        } else {
          showToast(context, "Failed to Upload Image", Icons.close);
        }
      } on Exception catch (_) {
        showToast(context, "Failed to Upload Image", Icons.close);
      }

      if (this.mounted) {
        setState(() {
          imageUploading = false;
        });
      }
    }
  }

  Future<void> initalDataLoad() async {
    var date = DateTime.now();
    from = [0, date.month - 1, date.day - 1];
    to = [0, date.month - 1, date.day - 1];

    for (int i = date.year; i >= 2018; i--) {
      Year.add(i.toString());
    }

    if (_email.text == "") {
      prefs = await SharedPreferences.getInstance();

      if (prefs.getBool("isBankMessageLoadedOnce") != null) {
        isBankMessageLoadedOnce = prefs.getBool("isBankMessageLoadedOnce")!;
      }

      if (prefs.getInt("appOpened") != null) {
        appOpened = prefs.getInt("appOpened")!;
        prefs.setInt("appOpened", 1 + appOpened);
      } else {
        prefs.setInt("appOpened", 1);
      }

      if (prefs.getBool("isGoogle") != null) {
        isGoogle = prefs.getBool("isGoogle")!;
      }

      if (isGoogle) {
        _googleSignIn.onCurrentUserChanged
            .listen((GoogleSignInAccount? account) {
          setState(() {
            _currentUser = account;
          });
        });
        _googleSignIn.signInSilently();
      }

      if (prefs.getString("email") != null &&
          prefs.getString("name") != null &&
          prefs.getString("token") != null &&
          prefs.getString("pushToken") != null) {
        _email.text = prefs.getString("email")!;
        _name.text = prefs.getString("name")!;
        _token = prefs.getString("token")!;
      } else {
        await prefs.remove("email");
        await prefs.remove("name");
        await prefs.remove("token");
        await prefs.remove("pushToken");
        await deleteToken();

        if (isGoogle) {
          await GoogleSignIN.logout();
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future _extractEmail() async {
    if (!initalDataLoaded) {
      await initalDataLoad();
      initalDataLoaded = true;
    }

    String appVersion = await getAppVersion();

    try {
      final response = await http.post(Uri.parse(global.url + 'data'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'email': crypto.encrypt(_email.text),
            'version': crypto.encrypt(appVersion)
          }));

      if (response.statusCode == 200) {
        amtSpend = crypto.decrypt(jsonDecode(response.body)['amtSpend']);
        List<dynamic> list = jsonDecode(response.body)['data'];
        RoomDataO.clear();
        RoomDataC.clear();
        yourSpend = 0;
        amtSpendClose = 0;
        amtSpendOpen = 0;

        for (int i = 0; i < list.length; i++) {
          if (list[i]['active']) {
            RoomDataO.add(RoomEach.fromJson(list[i]));
            yourSpend += RoomDataO.last.spend -
                (RoomDataO.last.total / RoomDataO.last.members);
            amtSpendOpen += (RoomDataO.last.total / RoomDataO.last.members);
          } else {
            RoomDataC.add(RoomEach.fromJson(list[i]));
            amtSpendClose += RoomDataC.last.total / RoomDataC.last.members;
          }
        }

        RoomDataO.sort((b, a) {
          DateTime tempDate_1 = new DateFormat("MMM dd yyyy").parse(a.date);
          DateTime tempDate_2 = new DateFormat("MMM dd yyyy").parse(b.date);
          return tempDate_1.compareTo(tempDate_2);
        });

        RoomDataC.sort((b, a) {
          DateTime tempDate_1 = new DateFormat("MMM dd yyyy").parse(a.date);
          DateTime tempDate_2 = new DateFormat("MMM dd yyyy").parse(b.date);
          return tempDate_1.compareTo(tempDate_2);
        });

        if (this.mounted) {
          setState(() {});
        }

        do {
          await getInitialData();
        } while (!gotInitialData);

        if (!isRoomRequestLoaded) {
          await getRoomRequest();
          isRoomRequestLoaded = true;
        }

        if (!isImageLoaded) {
          await _getImageID();
          isImageLoaded = true;
        }
      } else if (jsonDecode(response.body)['maintenance'] != null &&
          jsonDecode(response.body)['maintenance']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Maintenance()),
          (Route<dynamic> route) => false,
        );
      } else {
        await prefs.remove("email");
        await prefs.remove("name");
        await prefs.remove("token");
        await prefs.remove("pushToken");
        await deleteToken();

        if (isGoogle) {
          await GoogleSignIN.logout();
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } on Exception catch (_) {
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getRoomRequest() async {
    try {
      if (this.mounted) {
        setState(() {
          RoomRequest.clear();
        });
      }
      final response = await http.delete(Uri.parse(global.url + 'friend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'email': crypto.encrypt(_email.text),
          }));
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        RoomRequest = data["data"];
      } else {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  SendingData(bool flag, BuildContext context) async {
    var response;
    buildShowDialog(context);

    try {
      if (flag) {
        response = await http.post(Uri.parse(global.url + 'room'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': _token
            },
            body: jsonEncode({
              'email': crypto.encrypt(_email.text),
              'roomName': crypto.encrypt(_NRoom.text),
            }));
      } else {
        response = await http.put(Uri.parse(global.url + 'room'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Auth': _token
            },
            body: jsonEncode({
              'email': crypto.encrypt(_email.text),
              'roomKey': crypto.encrypt(_NRoom.text),
            }));
      }

      _NRoom.text = "";
      var JsonData = jsonDecode(response.body);

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);

      if (response.statusCode == 200) {
        _refreshIndicatorKey.currentState?.show();
      } else {
        showToast(context, crypto.decrypt(JsonData["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }
  }

  _updateCheck() async {
    await checkForUpdate();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
    LocalNotificationService.initialize();

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) async {
        if (message != null) {
          Map<String, String> notificationData =
              await getDataFromNotification(message.data.toString());

          NavKey.navKey.currentState!.push(MaterialPageRoute(
              builder: (_) => RoomExpense(
                  roomKey: notificationData["roomKey"]!,
                  email: notificationData["email"]!,
                  roomName: notificationData["roomName"]!,
                  token: notificationData["token"]!,
                  roomLink: notificationData["roomLink"]!,
                  isRoomActive: ((notificationData["isRoomActive"]!) == 'true'
                      ? true
                      : false))));
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (message) {
        if (message.notification != null) {
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        if (message.notification != null) {
          Map<String, String> notificationData =
              await getDataFromNotification(message.data.toString());
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RoomExpense(
                      roomKey: notificationData["roomKey"]!,
                      email: notificationData["email"]!,
                      roomName: notificationData["roomName"]!,
                      token: notificationData["token"]!,
                      roomLink: notificationData["roomLink"]!,
                      isRoomActive:
                          ((notificationData["isRoomActive"]!) == 'true'
                              ? true
                              : false))));
        }
      },
    );

    _updateCheck();
  }

  deleteToken() async {
    buildShowDialog(context);

    try {
      await http.delete(Uri.parse(global.url + 'verify'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'email': crypto.encrypt(_email.text),
          }));
    } on Exception catch (_) {}

    Navigator.pop(context);
  }

  buildFilterDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: dateIndex
                                  ? BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide(
                                              width: 2,
                                              color: Theme.of(context)
                                                  .primaryColor)))
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  child: Text(
                                    "From",
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      dateIndex = true;
                                    });
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              decoration: dateIndex
                                  ? null
                                  : BoxDecoration(
                                      border: Border.symmetric(
                                          horizontal: BorderSide(
                                              width: 2,
                                              color: Theme.of(context)
                                                  .primaryColor))),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  child: Text(
                                    "To",
                                    style: TextStyle(
                                      fontSize: 24,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      dateIndex = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Year",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9 - 50,
                            height: 70,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: Year.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 70,
                                    width: 95,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (dateIndex) {
                                              from[0] = index;
                                            } else {
                                              to[0] = index;
                                            }
                                          });
                                        },
                                        child: Card(
                                          elevation: 1.0,
                                          shadowColor:
                                              Theme.of(context).primaryColor,
                                          color: dateIndex
                                              ? (index == from[0]
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Theme.of(context)
                                                      .dialogBackgroundColor)
                                              : (index == to[0]
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Theme.of(context)
                                                      .dialogBackgroundColor),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Center(
                                            child: InkWell(
                                              child: Text(
                                                Year[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: dateIndex
                                                      ? (index == from[0]
                                                          ? Colors.white
                                                          : themeProvider
                                                                  .isDarkTheme
                                                              ? Colors.white
                                                              : Colors.black)
                                                      : (index == to[0]
                                                          ? Colors.white
                                                          : themeProvider
                                                                  .isDarkTheme
                                                              ? Colors.white
                                                              : Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Month",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9 - 50,
                          height: 75,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: Month.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  height: 75,
                                  width: 120,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (dateIndex) {
                                            from[1] = index;
                                          } else {
                                            to[1] = index;
                                          }
                                        });
                                      },
                                      child: Card(
                                        elevation: 1.0,
                                        shadowColor:
                                            Theme.of(context).primaryColor,
                                        color: dateIndex
                                            ? (index == from[1]
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .dialogBackgroundColor)
                                            : (index == to[1]
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .dialogBackgroundColor),
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: InkWell(
                                            child: Text(
                                              Month[index],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: dateIndex
                                                    ? (index == from[1]
                                                        ? Colors.white
                                                        : themeProvider
                                                                .isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black)
                                                    : (index == to[1]
                                                        ? Colors.white
                                                        : themeProvider
                                                                .isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Day",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9 - 50,
                          height: 70,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: Date.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (dateIndex) {
                                            from[2] = index;
                                          } else {
                                            to[2] = index;
                                          }
                                        });
                                      },
                                      child: Card(
                                        elevation: 1.0,
                                        color: dateIndex
                                            ? (index == from[2]
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .dialogBackgroundColor)
                                            : (index == to[2]
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context)
                                                    .dialogBackgroundColor),
                                        shadowColor:
                                            Theme.of(context).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Center(
                                          child: InkWell(
                                            child: Text(
                                              Date[index],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: dateIndex
                                                    ? (index == from[2]
                                                        ? Colors.white
                                                        : themeProvider
                                                                .isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black)
                                                    : (index == to[2]
                                                        ? Colors.white
                                                        : themeProvider
                                                                .isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Room Status",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9 - 50,
                            height: 70,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: roomStatus.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    height: 70,
                                    width: 100,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            roomStatusIndex = index;
                                          });
                                        },
                                        child: Card(
                                          elevation: 1.0,
                                          color: (index == roomStatusIndex
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context)
                                                  .dialogBackgroundColor),
                                          shadowColor:
                                              Theme.of(context).primaryColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Center(
                                            child: InkWell(
                                              child: Text(
                                                roomStatus[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      (index == roomStatusIndex
                                                          ? Colors.white
                                                          : themeProvider
                                                                  .isDarkTheme
                                                              ? Colors.white
                                                              : Colors.black),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                })),
                        SizedBox(
                          height: 10,
                        ),
                        error
                            ? Text(
                                errorText,
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 45,
                              width: 100,
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
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              height: 45,
                              width: 100,
                              child: OutlinedButton(
                                child: Text(
                                  "Apply",
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
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                onPressed: () {
                                  setState(() {
                                    DateChanged = false;
                                    errorText = "";
                                    error = false;
                                  });

                                  var validate_1 = DateTime(
                                      int.parse(Year[from[0]]),
                                      from[1] + 1,
                                      from[2] + 1);
                                  var validate_2 = DateTime(
                                      int.parse(Year[to[0]]),
                                      to[1] + 1,
                                      to[2] + 1);
                                  if (validate_1.month != from[1] + 1 ||
                                      from[2] + 1 != validate_1.day ||
                                      validate_1.year !=
                                          int.parse(Year[from[0]])) {
                                    errorText = "Wrong From Date";
                                    error = true;
                                  }

                                  if (validate_2.month != to[1] + 1 ||
                                      to[2] + 1 != validate_2.day ||
                                      validate_2.year !=
                                          int.parse(Year[to[0]])) {
                                    if (errorText.length == 0) {
                                      errorText = "Wrong To Date";
                                    } else {
                                      errorText = "Wrong From and To Date";
                                    }
                                    error = true;
                                  }

                                  if (validate_1.isAfter(validate_2)) {
                                    error = true;
                                    if (errorText.length == 0) {
                                      errorText =
                                          "To Date Can't Before From Date";
                                    }
                                  }

                                  if (validate_2.isAfter(DateTime.now())) {
                                    error = true;
                                    if (errorText.length == 0) {
                                      errorText =
                                          "To Date Can't After Current Date";
                                    }
                                  }
                                  if (!error) {
                                    DateChanged = true;
                                    Navigator.pop(context);
                                  }
                                  setState(() {});
                                },
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        }).then((val) {
      SearchData();
    });
  }

  bool getDate(String date) {
    final dd = date.split(' ');
    int mn = 0;
    for (int i = 0; i < 12; i++) {
      if (Month[i].contains(dd[0])) {
        mn = i;
      }
    }
    DateTime RD = DateTime(int.parse(dd[2]), mn + 1, int.parse(dd[1]));
    DateTime FROMD =
        DateTime(int.parse(Year[from[0]]), from[1] + 1, from[2] + 1);
    DateTime TOD = DateTime(int.parse(Year[to[0]]), to[1] + 1, to[2] + 1);

    if (TOD.isAtSameMomentAs(RD) || FROMD.isAtSameMomentAs(RD)) {
      return true;
    } else if (TOD.isAfter(RD) && FROMD.isBefore(RD)) {
      return true;
    } else {
      return false;
    }
  }

  SearchData() {
    if (this.mounted) {
      setState(() {
        searching = true;
        SearchRoomData.clear();
      });
    }

    SearchRoomData.clear();

    if (roomStatusIndex == 0) {
      for (int i = 0; i < RoomDataC.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataC[i]
                .roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataC[i].date)) {
              SearchRoomData.add(RoomDataC[i]);
            }
          } else {
            SearchRoomData.add(RoomDataC[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataC[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataC[i].date)) {
              SearchRoomData.add(RoomDataC[i]);
            }
          } else {
            SearchRoomData.add(RoomDataC[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataC[i].date)) {
            SearchRoomData.add(RoomDataC[i]);
          }
        }
      }
      for (int i = 0; i < RoomDataO.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataO[i]
                .roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataO[i].date)) {
              SearchRoomData.add(RoomDataO[i]);
            }
          } else {
            SearchRoomData.add(RoomDataO[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataO[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataO[i].date)) {
              SearchRoomData.add(RoomDataO[i]);
            }
          } else {
            SearchRoomData.add(RoomDataO[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataO[i].date)) {
            SearchRoomData.add(RoomDataO[i]);
          }
        }
      }
    } else if (roomStatusIndex == 1) {
      for (int i = 0; i < RoomDataO.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataO[i]
                .roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataO[i].date)) {
              SearchRoomData.add(RoomDataO[i]);
            }
          } else {
            SearchRoomData.add(RoomDataO[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataO[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataO[i].date)) {
              SearchRoomData.add(RoomDataO[i]);
            }
          } else {
            SearchRoomData.add(RoomDataO[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataO[i].date)) {
            SearchRoomData.add(RoomDataO[i]);
          }
        }
      }
    } else {
      for (int i = 0; i < RoomDataC.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataC[i]
                .roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataC[i].date)) {
              SearchRoomData.add(RoomDataC[i]);
            }
          } else {
            SearchRoomData.add(RoomDataC[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataC[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataC[i].date)) {
              SearchRoomData.add(RoomDataC[i]);
            }
          } else {
            SearchRoomData.add(RoomDataC[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataC[i].date)) {
            SearchRoomData.add(RoomDataC[i]);
          }
        }
      }
    }

    SearchRoomData.sort((b, a) {
      DateTime tempDate_1 = new DateFormat("MMM dd yyyy").parse(a.date);
      DateTime tempDate_2 = new DateFormat("MMM dd yyyy").parse(b.date);
      return tempDate_1.compareTo(tempDate_2);
    });

    if (this.mounted) {
      setState(() {
        heightSearched =
            SearchRoomData.length * 115 + SearchRoomData.length * 5;
        searching = false;
      });
    }
  }

  Future<void> JoinRequest(String flag, String roomKey) async {
    buildShowDialog(context);
    try {
      final response = await http.put(Uri.parse(global.url + 'friend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'roomKey': crypto.encrypt(roomKey),
            'email': crypto.encrypt(_email.text),
            'confirm': crypto.encrypt(flag)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
      await _requestIndicatorKey.currentState?.show();
      if (flag == "1") {
        await _extractEmail();
      }
      Navigator.pop(context);
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }
  }

  Widget updateWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settle Now (New Update Available)",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                final provider =
                    Provider.of<ThemeProvider>(context, listen: false);
                provider.toggleTheme(!themeProvider.darkTheme);
                prefs.setBool('darkTheme', themeProvider.darkTheme);
              },
              icon: Icon(
                Icons.brightness_2,
                color: themeProvider.darkTheme ? Colors.white : Colors.black87,
              ))
        ],
      ),
      body: updatePage(data: updateData),
    );
  }

  Widget RequestWidget(BuildContext context) {
    return RefreshIndicator(
      key: _requestIndicatorKey,
      onRefresh: getRoomRequest,
      child: RoomRequest.isEmpty
          ? ListView(
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "No Request Found",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ))
              ],
            )
          : Scrollbar(
              radius: Radius.circular(10.0),
              thickness: 5.5,
              child: ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8.0),
                  itemCount: RoomRequest.length,
                  separatorBuilder: (context, index) => SizedBox(
                        height: 5,
                      ),
                  itemBuilder: (BuildContext context, int index) {
                    return SizedBox(
                      child: Card(
                          elevation: 1.0,
                          clipBehavior: Clip.antiAlias,
                          shadowColor: Theme.of(context).primaryColor,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withAlpha(95)),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: crypto
                                              .decrypt(
                                                  RoomRequest[index]["pic"])
                                              .length ==
                                          0
                                      ? global.driveUrl +
                                          "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                      : crypto
                                          .decrypt(RoomRequest[index]["pic"]),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 65.0,
                                    height: 65.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Images/unknown.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 65.0,
                                    height: 65.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              140,
                                          child: Text(
                                            crypto.decrypt(
                                                    RoomRequest[index]["by"]) +
                                                " invited to join " +
                                                crypto.decrypt(
                                                    RoomRequest[index]["name"]),
                                            style: TextStyle(
                                              overflow: TextOverflow.clip,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              140,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              IconButton(
                                                  onPressed: () async {
                                                    await JoinRequest(
                                                        "0",
                                                        crypto.decrypt(
                                                            RoomRequest[index]
                                                                ["key"]));
                                                  },
                                                  icon: Icon(
                                                    Icons.cancel_sharp,
                                                    size: 30,
                                                    color: Colors.red,
                                                  )),
                                              IconButton(
                                                  onPressed: () async {
                                                    await JoinRequest(
                                                        "1",
                                                        crypto.decrypt(
                                                            RoomRequest[index]
                                                                ["key"]));
                                                  },
                                                  icon: Icon(Icons.check,
                                                      size: 30,
                                                      color:
                                                          Colors.greenAccent)),
                                            ],
                                          ),
                                        )
                                      ])),
                            ],
                          )),
                    );
                  }),
            ),
    );
  }

  Widget homeWidget(BuildContext context) {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _extractEmail,
        child: (RoomDataO.isEmpty && RoomDataC.isEmpty)
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        "No Rooms to Join, Create One!!!",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  )
                ],
              )
            : (searchTrigger
                ? _search.text.length == 0 && SearchRoomData.isEmpty
                    ? Center(
                        child: Text(
                          "Search Rooms...",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      )
                    : (SearchRoomData.isEmpty
                        ? Center(
                            child: searching
                                ? CircularProgressIndicator()
                                : Text("No Results Found",
                                    style: TextStyle(
                                      fontSize: 22,
                                    )))
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  child: Text(SearchRoomData.length.toString() +
                                      " Results Found"),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 180,
                                  child: RoomWidget(
                                      RoomData: SearchRoomData,
                                      email: _email.text,
                                      flag: true,
                                      token: _token),
                                ),
                              ],
                            ),
                          ))
                : Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 40,
                              decoration: open
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(13)))
                                  : null,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: InkWell(
                                    child: Text(
                                      "Live",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        open = true;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: 40,
                              width: 80,
                              decoration: open
                                  ? null
                                  : BoxDecoration(
                                      border: Border.all(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(13))),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: InkWell(
                                    child: Text(
                                      "Closed",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        open = false;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      open
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total : ₹ " + commaSeperator(amtSpend),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    (yourSpend >= 0
                                            ? "Gain : ₹ "
                                            : "Owe : ₹ ") +
                                        commaSeperator(
                                            yourSpend.toStringAsFixed(2)),
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                      GestureDetector(
                        onPanUpdate: (details) {
                          if (details.delta.dx > 0) {
                            setState(() {
                              open = true;
                            });
                          }

                          if (details.delta.dx < 0) {
                            setState(() {
                              open = false;
                            });
                          }
                        },
                        child: SizedBox(
                          height: open
                              ? (MediaQuery.of(context).size.height - 250)
                              : (MediaQuery.of(context).size.height - 220),
                          child: open
                              ? RoomDataO.isEmpty
                                  ? Scrollbar(
                                      radius: Radius.circular(10.0),
                                      thickness: 5.5,
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Center(
                                          child: Text(
                                            "No Live Room Found!!!",
                                            style: TextStyle(
                                              fontSize: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Scrollbar(
                                      radius: Radius.circular(10.0),
                                      thickness: 5.5,
                                      child: RoomWidget(
                                          RoomData: RoomDataO,
                                          email: _email.text,
                                          flag: false,
                                          token: _token))
                              : (RoomDataC.isEmpty
                                  ? Scrollbar(
                                      radius: Radius.circular(10.0),
                                      thickness: 5.5,
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.8,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Center(
                                          child: Text(
                                            "No Closed Room Found!!!",
                                            style: TextStyle(
                                              fontSize: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Scrollbar(
                                      radius: Radius.circular(10.0),
                                      thickness: 5.5,
                                      child: RoomWidget(
                                          RoomData: RoomDataC,
                                          email: _email.text,
                                          flag: false,
                                          token: _token))),
                        ),
                      ),
                    ],
                  )));
  }

  Widget chooseFromBottomNavigator(int dash) {
    if (dash == 0) {
      return homeWidget(context);
    } else if (dash == 1) {
      return RequestWidget(context);
    } else if (dash == 2) {
      return Expenses(
        email: _email.text,
        date: date,
        token: _token,
        expenseCategory: expenseCategory,
        investmentCategory: investmentCategory,
      );
    } else if (dash == 3) {
      return LendCredit(
        email: _email.text,
        token: _token,
      );
    } else {
      return Profile(
        email: _email.text,
        token: _token,
        closeRoomSpend: amtSpendClose,
        openRoomSpend: amtSpendOpen,
        expenseCategory: expenseCategory,
        investmentCategory: investmentCategory,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
        appBar: dash == 0
            ? AppBar(
                title: searchTrigger
                    ? TextField(
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.search,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          counterText: "",
                          contentPadding: EdgeInsets.all(8.0),
                          hintText: "Search ...",
                        ),
                        onChanged: (String s) {
                          setState(() {
                            _search.text = s;
                          });
                          SearchData();
                        },
                      )
                    : Text(
                        "Settle Now",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                actions: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          searchTrigger = !searchTrigger;
                          DateChanged = false;
                        });
                      },
                      icon: Icon(
                        Icons.search,
                        color: themeProvider.darkTheme
                            ? Colors.white
                            : Colors.black,
                      ))
                ],
              )
            : (dash == 1
                ? AppBar(
                    title: Text(
                      "Room Request",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : (dash == 2
                    ? null
                    : (dash == 3
                        ? AppBar(
                            title: Text(
                              "Len-Den",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )
                        : AppBar(
                            title: Text(
                              "Profile",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          )))),
        body: chooseFromBottomNavigator(dash),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: dash,
          onTap: (index) => setState(() {
            dash = index;
          }),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 27,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Stack(children: [
                Icon(
                  Icons.person_add_outlined,
                  size: 27,
                ),
                RoomRequest.isNotEmpty
                    ? Positioned(
                        right: 0,
                        child: new Container(
                          padding: EdgeInsets.all(1),
                          decoration: new BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: new Text(
                            RoomRequest.length.toString(),
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SizedBox()
              ]),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.wallet,
                size: 27,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.account_balance_outlined,
                size: 27,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 27,
              ),
              label: "",
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              _name.text.length == 0
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                          color: Theme.of(context).drawerTheme.backgroundColor),
                      margin: EdgeInsets.all(0),
                      currentAccountPicture: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: isGoogle
                                ? _profilePicID
                                : (global.driveUrl +
                                    (_profilePicID.length == 0
                                        ? "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                        : _profilePicID)),
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                        value: downloadProgress.progress),
                            errorWidget: (context, url, error) => Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/Images/unknown.jpeg'),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          isGoogle
                              ? SizedBox()
                              : Positioned(
                                  left: 40,
                                  top: 43,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () {
                                          showModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return SizedBox(
                                                height: 120,
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      leading:
                                                          Icon(Icons.camera),
                                                      title: Text('Camera'),
                                                      onTap: () {
                                                        imageUpload(
                                                            ImageSource.camera);
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading:
                                                          Icon(Icons.image),
                                                      title: Text('Gallery'),
                                                      onTap: () {
                                                        imageUpload(ImageSource
                                                            .gallery);
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.camera_alt,
                                          size: 20,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ))
                        ],
                      ),
                      accountName: Text(_name.text,
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                      accountEmail: Text(_email.text,
                          style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BankTransactions(
                              email: _email.text,
                              token: _token,
                              isBankMessageLoadedOnce: isBankMessageLoadedOnce,
                              expenseCategory: expenseCategory,
                              investmentCategory: investmentCategory,
                              roomExpenseCategory: roomExpenseCategory,
                            )),
                  );
                },
                leading: Icon(
                  Icons.payments,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text(
                  "Bank Transactions",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                trailing: Container(
                    width: 55,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: themeProvider.isDarkTheme
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text("Beta",
                          style: TextStyle(fontSize: 13, color: Colors.white)),
                    )),
              ),
              ListTile(
                leading: Icon(
                  Icons.border_color,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text(
                  "Theme",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                trailing: IconButton(
                    onPressed: () {
                      final provider =
                          Provider.of<ThemeProvider>(context, listen: false);
                      provider.toggleTheme(!themeProvider.darkTheme);
                      prefs.setBool('darkTheme', themeProvider.darkTheme);
                    },
                    icon: Icon(
                      Icons.brightness_2,
                      color: themeProvider.darkTheme
                          ? Colors.black87
                          : Colors.white,
                      size: 22,
                    )),
              ),
              ListTile(
                onTap: () async {
                  await Share.share(shareMessage.title +
                      "\n\n" +
                      shareMessage.subject +
                      "\n\n" +
                      shareMessage.playstore);
                },
                leading: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text(
                  "Share",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUs()),
                ),
                leading: Icon(
                  Icons.book_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text(
                  "About Us",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ContactUs(
                            email: _email.text,
                            token: _token,
                          )),
                ),
                leading: Icon(
                  Icons.rate_review_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text(
                  "Contact Us",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ListTile(
                onTap: rateUs,
                leading: Icon(
                  Icons.star_border_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text(
                  "Rate Us",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ListTile(
                onTap: () async {
                  await prefs.remove('name');
                  await prefs.remove('email');
                  await prefs.remove('token');
                  await prefs.remove('pushToken');
                  await deleteToken();

                  if (isGoogle) {
                    await GoogleSignIN.logout();
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (Route<dynamic> route) => false,
                  );
                },
                leading: Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text(
                  "Log Out",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Version " + widget.version,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    InkWell(
                      onTap: () async {
                        launchUrl(
                          Uri.parse("https://settlenow.in/privacy-policy"),
                          mode: LaunchMode.inAppWebView,
                          webViewConfiguration: const WebViewConfiguration(
                              enableJavaScript: true),
                        );
                      },
                      child: Text(
                        "Privacy Policy",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: dash == 0
            ? (searchTrigger
                ? FloatingActionButton(
                    onPressed: () {
                      buildFilterDialog(context);
                    },
                    child: Icon(
                      Icons.filter_alt_outlined,
                      color: Colors.white,
                    ),
                  )
                : FloatingActionButton(
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
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(
                                        Icons.add,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: const Text("Create Room"),
                                      onTap: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return Padding(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Form(
                                                    key: _CformKey,
                                                    child: TextFormField(
                                                      controller: _NRoom,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      maxLength: 70,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                      cursorColor: Colors.black,
                                                      autocorrect: false,
                                                      validator: (value) {
                                                        RegExp validateText =
                                                            RegExp(
                                                                r'\b[\w]{4,}\b');
                                                        if (!validateText
                                                            .hasMatch(
                                                                _NRoom.text)) {
                                                          return "Enter Valid Room Name";
                                                        }
                                                        return null;
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                        counterText: "",
                                                        contentPadding:
                                                            EdgeInsets.all(8.0),
                                                        hintText:
                                                            "Enter Room Name",
                                                        errorStyle: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 43,
                                                    width: 100,
                                                    child: OutlinedButton(
                                                      child: Text(
                                                        "Create",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: themeProvider
                                                                    .isDarkTheme
                                                                ? Colors.white
                                                                : Colors.black),
                                                      ),
                                                      style: OutlinedButton
                                                          .styleFrom(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        side: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                      ),
                                                      onPressed: () {
                                                        if (_CformKey
                                                            .currentState!
                                                            .validate()) {
                                                          SendingData(
                                                              true, context);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  )
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      title: const Text("Join Room"),
                                      onTap: () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return Padding(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Form(
                                                    key: _JformKey,
                                                    child: TextFormField(
                                                      controller: _NRoom,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      maxLength: 7,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                          fontSize: 18),
                                                      cursorColor: Colors.black,
                                                      autocorrect: false,
                                                      validator: (value) {
                                                        RegExp validateText =
                                                            RegExp(
                                                                r'\b[\w]{7}\b');
                                                        if (!validateText
                                                            .hasMatch(
                                                                _NRoom.text)) {
                                                          return "Enter Valid Room Key";
                                                        }
                                                        return null;
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                        counterText: "",
                                                        contentPadding:
                                                            EdgeInsets.all(8.0),
                                                        hintText:
                                                            "Enter Room Key",
                                                        labelText: "Room Key",
                                                        errorStyle: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 43,
                                                    width: 100,
                                                    child: OutlinedButton(
                                                        child: Text(
                                                          "Join",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: themeProvider
                                                                      .isDarkTheme
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black),
                                                        ),
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          side: BorderSide(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                        ),
                                                        onPressed: () {
                                                          if (_JformKey
                                                              .currentState!
                                                              .validate()) {
                                                            SendingData(
                                                                false, context);
                                                          }
                                                        }),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  )
                                                ],
                                              ),
                                            );
                                          },
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
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ))
            : null);
  }
}

class RoomWidget extends StatelessWidget {
  final List<dynamic> RoomData;
  final String email;
  final bool flag;
  final String token;

  final Shader linearGradient = LinearGradient(
    colors: <Color>[
      Color.fromARGB(255, 243, 33, 112),
      Color.fromARGB(255, 255, 235, 7),
      Color.fromARGB(255, 33, 150, 243),
      Color.fromARGB(255, 255, 0, 235)
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Shader linearGradient_2 = LinearGradient(
    colors: <Color>[
      Color.fromARGB(255, 0, 219, 222),
      Color.fromARGB(255, 252, 0, 255)
    ],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  RoomWidget(
      {Key? key,
      required this.RoomData,
      required this.email,
      required this.flag,
      required this.token})
      : super(key: key);

  _MoveToNext(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RoomExpense(
              roomKey: RoomData[index].roomKey,
              email: email,
              roomName: RoomData[index].roomName,
              token: token,
              roomLink: RoomData[index].roomLink,
              isRoomActive: RoomData[index].active)),
    );
  }

  Widget roomSectors(BuildContext context, int index) {
    return InkWell(
      child: SizedBox(
        child: Card(
          elevation: 1.0,
          clipBehavior: Clip.antiAlias,
          shadowColor: Theme.of(context).primaryColor,
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            side:
                BorderSide(color: Theme.of(context).primaryColor.withAlpha(95)),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        RoomData[index].roomName,
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
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
                                "Members: " +
                                    RoomData[index].members.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Created: " + RoomData[index].date,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await Share.share("Join " +
                                      RoomData[index].roomName +
                                      "\nRoom Key: " +
                                      RoomData[index].roomKey +
                                      "\n" +
                                      RoomData[index].roomLink);
                                },
                                onLongPress: () async {
                                  Clipboard.setData(ClipboardData(
                                      text: RoomData[index].roomKey));
                                  showToast(
                                      context, "Join Key Copied", Icons.check);
                                },
                                child: Text(
                                  "Room Key: " + RoomData[index].roomKey,
                                  textScaleFactor: 1.0,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Spend: ₹ " +
                                    commaSeperator(
                                        RoomData[index].total.toString()),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Your Spend: ₹ " +
                                    commaSeperator(
                                        RoomData[index].spend.toString()),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Average Spend: ₹ " +
                                    commaSeperator(double.parse(
                                            (RoomData[index].total /
                                                    RoomData[index].members)
                                                .toString())
                                        .toStringAsFixed(2)),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ])),
        ),
      ),
      onTap: () {
        _MoveToNext(context, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: flag ? ScrollPhysics() : null,
      padding: EdgeInsets.all(8.0),
      itemCount: RoomData.length,
      separatorBuilder: (context, index) => SizedBox(
        height: 5,
      ),
      itemBuilder: (BuildContext context, int index) {
        return roomSectors(context, index);
      },
    );
  }
}

class updatePage extends StatelessWidget {
  final data;
  updatePage({Key? key, required this.data}) : super(key: key);

  _launchURL(BuildContext context) async {
    launchUrl(
      Uri.parse(crypto.decrypt(data["link"])),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Container(
          width: 300,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Version: ' + crypto.decrypt(data["Version"]),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Description: ' + crypto.decrypt(data["description"]),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      child: Text(
                        'Download',
                        style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.isDarkTheme
                                ? Colors.white
                                : Colors.black),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      onPressed: () {
                        _launchURL(context);
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
