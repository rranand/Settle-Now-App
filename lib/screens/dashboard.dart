import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/manualUpdateWidget.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/RoomEach.dart';
import 'package:settlenow/notificationService/NotificationController.dart';
import 'package:settlenow/notificationService/notificationProcessor.dart';
import 'package:settlenow/others/GoogleSignIN.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/internetConnectivity.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:settlenow/screens/analysis.dart';
import 'package:settlenow/screens/lendenDashboard.dart';
import 'package:settlenow/screens/personalExpDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contents.dart' as global;
import '../models/FriendEach.dart';
import '../others/themes.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
  final int dash;
  final bool firstTime;
  const DashBoard({Key? key, this.dash = 0, required this.firstTime})
      : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  AppUpdateInfo? _updateInfo;
  final InAppReview inAppReview = InAppReview.instance;
  bool requestType = true;
  int dash = 0;
  bool isGoogle = false;
  final TextEditingController _amt = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  String date = "";
  bool notificationSetupComplete = false;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _search = TextEditingController(text: "");
  String _token = "";
  ValueNotifier<bool> activeRoomHasMore = ValueNotifier(true);
  ValueNotifier<bool> inActiveRoomHasMore = ValueNotifier(true);
  ValueNotifier<bool> quickSplitDataHasMore = ValueNotifier(true);
  TextEditingController _NRoom = TextEditingController();
  ValueNotifier<List<QuickSplitEach>> quickSplitData = ValueNotifier([]);
  ValueNotifier<List<RoomEach>> RoomDataO = ValueNotifier([]);
  ValueNotifier<List<RoomEach>> RoomDataC = ValueNotifier([]);
  ValueNotifier<List<RoomEach>> SearchRoomData = ValueNotifier([]);
  ValueNotifier<List<QuickSplitEach>> SearchQuickSplitData = ValueNotifier([]);
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<RefreshIndicatorState> _requestIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<RefreshIndicatorState> _sentrequestIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  GlobalKey<FormState> _CformKey = GlobalKey<FormState>();
  GlobalKey<FormState> _JformKey = GlobalKey<FormState>();
  bool isContactPermissionGranted = false;
  bool searchTrigger = false;
  bool searching = false;
  bool isRoomRequestLoaded = false;
  bool gotInitialData = false;
  List<dynamic> expenseCategory = [];
  List<List<dynamic>> subCategory = [];
  late ShareMessage shareMessage;
  bool activeRoomDataFetched = false;
  bool inActiveRoomDataFetched = false;
  bool quickSplitDataFetched = false;
  int roomExpenseCategoryIndex = 0;
  int roomsubExpenseCategoryIndex = 0;
  bool isItAndroidDevice = false;
  final ValueNotifier<Map<String, List<dynamic>>> membersData =
      ValueNotifier(new Map());
  bool initalDataLoaded = false;
  bool isInvitePremissionProvided = false;
  bool isNotificationPremissionProvided = false;
  bool isInvitePremissionPoppedProvided = false;
  bool isNotificationPremissionPoppedProvided = false;
  bool isSentRoomRequestLoaded = false;
  List<FriendEach> friendDataSearched = [];
  List<FriendEach> friendData = [];
  bool loadFriendData = false;
  DateTimeRange dateRange =
      DateTimeRange(start: new DateTime(2018, 1), end: DateTime.now());
  bool error = false;
  String errorText = "";
  double heightSearched = 0;
  var updateData = null;
  List<String> roomStatus = ['All', 'Active', 'Closed'];
  int roomStatusIndex = 0;
  int open = 1;
  String _profilePicID = "";
  List<dynamic> RoomRequest = [];
  List<dynamic> sentRoomRequest = [];
  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  // ignore: unused_field
  bool _flexibleUpdateAvailable = false;
  bool importantUpdate = false;
  List<String> liveRoomCategory = ["Settled", "Not Settled"];
  Set<int> filterliveRoomCategoryIndex = Set();
  bool isLogoutTriggered = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool splitManually = false;
  DateTime expenseDate = DateTime.now();
  Map<String, double> manualSplitAmount = {};
  Map<String, double> customManualSplitAmount = {};
  List<FriendEach> addExpenseTo = [];
  List<Map> getContactsFromDB = [];
  final TextEditingController _searchFriend = TextEditingController();
  List<FriendEach> aditionalMembers = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String appVersion = "Unknown";

  Future<void> getContactsFromLocal() async {
    try {
      String path = await getDBFilePath('contact_data.db');

      Database database = await openDatabase(path);
      getContactsFromDB =
          await database.rawQuery('SELECT * FROM ContactHasAccountOnSN');
    } on Exception catch (err, stackTrace) {
      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["DashBoard->getContactsFromLocal"]);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> logout() async {
    if (this.mounted && Overlay.of(context).mounted && !isLogoutTriggered) {
      setState(() {
        isLogoutTriggered = true;
      });
      buildShowDialog(context);
      final prefs = await SharedPreferences.getInstance();
      if (kIsWeb) {
        await Future.wait([
          removePref([
            "token",
            "__token",
            "___token",
            "isGoogle",
            "liveCategoryIndex"
          ]),
          deleteToken(),
          logOutFromGoogle()
        ]);
      } else {
        await Future.wait([
          deleteDB(),
          removePref([
            "token",
            "__token",
            "___token",
            "isGoogle",
            "liveCategoryIndex"
          ]),
          AwesomeNotifications().cancelAllSchedules(),
          deleteToken(),
          logOutFromGoogle()
        ]);
      }
      await prefs.clear();
      while (this.mounted && context.canPop()) {
        context.pop();
      }
      while (this.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      context.pushReplacement(AppRouteConstants.loginRouteName);
    }
  }

  Future<void> checkforScheduledNotifications() async {
    if (widget.firstTime && !notificationSetupComplete) {
      List<dynamic> data = [];
      try {
        Map<String, String> jsonInputData = {
          "email": crypto.encrypt(_email.text),
        };

        final response = await createHTTPreq(
            'reminder', http.post, _token, jsonInputData, context);

        if (response.statusCode == 200) {
          var tempData = jsonDecode(response.body);
          data = tempData['data'];

          for (int i = 0; i < data.length; i++) {
            String notID = crypto.decrypt(data[i]["notID"]);
            List<String> IDs = notID.substring(1, notID.length - 1).split(', ');
            for (int j = 0; j < IDs.length; j++) {
              await AwesomeNotifications().createNotification(
                  content: NotificationContent(
                      id: int.parse(IDs[j]),
                      channelKey: 'reminderID',
                      title: "Reminder",
                      body: crypto.decrypt(data[i]['name']),
                      payload: null),
                  schedule: NotificationCalendar(
                      day: int.parse(crypto.decrypt(data[i]["dates"])),
                      hour: 7 + (j * 4),
                      minute: 0,
                      second: 0,
                      allowWhileIdle: true,
                      timeZone: "Asia/Kolkata"));
            }
          }
        }
      } on Exception catch (err, stackTrace) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error",
            info: ["DashBoard->checkforScheduledNotifications"]);
      }
      if (this.mounted) {
        setState(() {
          notificationSetupComplete = true;
        });
      }
    }
  }

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

  Future<void> ContactPermissionGranted() async {
    isContactPermissionGranted = await Permission.contacts.isGranted;

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getMembersData(int roomType) async {
    try {
      Map<String, dynamic> jsonInputData = {
        "email": crypto.encrypt(_email.text),
        "roomType": roomType == 1,
        'hasAlready': crypto.encrypt("0")
      };

      final response = await createHTTPreq(
          'room/allRoomMembers', http.post, _token, jsonInputData, context);

      if (response.statusCode == 200) {
        var tempData = jsonDecode(response.body)["data"];

        for (int i = 0; i < tempData.length; i++) {
          membersData.value[tempData[i][0]] = tempData[i][1];
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->getMembersData"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> _getImageID() async {
    if (isGoogle) {
      return;
    }

    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text),
      };

      final response = await createHTTPreq(
          'login', http.put, _token, jsonInputData, context);

      if (response.statusCode == 200) {
        var imgData = jsonDecode(response.body);

        if (imgData['havePic']) {
          _profilePicID = crypto.decrypt(imgData["fileId"]);
        } else {
          _profilePicID = global.unknown_avatar_id;
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->_getImageID"]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getInitialData() async {
    var tempDate = DateTime.now();

    if (this.mounted) {
      setState(() {
        date = (tempDate.month - 1).toString() + tempDate.year.toString();
      });
    }
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text),
      };

      final response = await createHTTPreq(
          'profile', http.patch, _token, jsonInputData, context);

      if (response.statusCode == 200) {
        gotInitialData = true;
        var data = jsonDecode(response.body);
        expenseCategory.clear();
        subCategory.clear();
        Map<dynamic, dynamic> categoryMap = data['expenseCategory'];
        categoryMap.forEach((key, value) {
          expenseCategory.add(key);
          subCategory.add(value);
        });
        shareMessage = ShareMessage.fromJson(data['shareMessage']);
      }
    } on Exception catch (err, stackTrace) {
      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["DashBoard->getInitialData"]);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> manualUpdateCheck() async {
    try {
      Map<String, dynamic> jsonInputData = {};

      final response =
          await createHTTPreq('login', http.patch, "", jsonInputData, context);

      if (response.statusCode == 200) {
        updateData = jsonDecode(response.body);
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        int currentVerionCode = int.parse(await packageInfo.buildNumber);
        int updatedVersionCode =
            int.parse(crypto.decrypt(updateData['Version']).split('+').last);
        if (updatedVersionCode > currentVerionCode) {
          importantUpdate = true;
        }
      }
    } on Exception catch (err, stackTrace) {
      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["DashBoard->manualUpdateCheck"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> rateUs() =>
      inAppReview.openStoreListing(appStoreId: 'com.rohit.settlenow');

  Future<void> initalDataLoad() async {
    dash = widget.dash;
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final provider = Provider.of<ThemeProvider>(context, listen: false);
    provider.toggleTheme(await getTheme(context));

    isItAndroidDevice = await checkAndroidInsideWeb();

    if (_email.text == "") {
      if (!kIsWeb) {
        isInvitePremissionPoppedProvided =
            await getInvitePermissionPoppedStatus();
        isNotificationPremissionPoppedProvided =
            await getNotificationPermissionPoppedStatus();
        isInvitePremissionProvided = await Permission.contacts.isGranted;
        isNotificationPremissionProvided =
            await AwesomeNotifications().isNotificationAllowed();
      }

      isGoogle = await getBoolPrefs("isGoogle") ?? false;
      int indexes = await getIntPref("liveCategoryIndex") ?? 2;
      if (indexes == 2) {
        setIntPref("liveCategoryIndex", 2);
        filterliveRoomCategoryIndex.add(1);
        filterliveRoomCategoryIndex.add(0);
      } else {
        filterliveRoomCategoryIndex.add(indexes);
      }

      if (isGoogle) {
        _googleSignIn.isSignedIn().then((value) {
          if (value) {
            _googleSignIn.signInSilently().then((value) {
              if (value != null) {
                _currentUser = value;
              }
            });
          }
        });
      }
      var tokenData = await getStringPref("token");
      if (tokenData != null && parseJWT(tokenData) != null) {
        Map<String, dynamic> jsonOutData = parseJWT(tokenData);
        _email.text = jsonOutData["email"]!;
        _name.text = jsonOutData["name"]!;
        _token = jsonOutData["token"]!;
        initalDataLoaded = true;

        Map<String, dynamic> jsonInputData = {
          'email': crypto.encrypt(_email.text),
          "url": crypto
              .encrypt(AppRouteConstants.dashboardRouteName + "Room/Active"),
          "creationDate": crypto.encrypt(DateTime.now().toString())
        };
        if (!kIsWeb) {
          _fcm.onTokenRefresh.listen((newToken) {
            Map<String, dynamic> jsonInputData = {
              'email': crypto.encrypt(_email.text),
              "fcmToken": crypto.encrypt(newToken)
            };
            createHTTPreq('profile/refreshFCM', http.post, _token,
                jsonInputData, context);
          });
        }
        pushAnalytics(context, jsonInputData, _token);

        if (!kIsWeb && !isInvitePremissionPoppedProvided) {
          isContactPermissionGranted = await context.push(
              AppRouteConstants.inviteFriendsRouteName,
              extra: {"firstTime": true}) as bool;
        }
        if (!kIsWeb && !isNotificationPremissionPoppedProvided) {
          isNotificationPremissionProvided = await context.push(
              AppRouteConstants.notificationPermissionRouteName,
              extra: {"firstTime": true}) as bool;
        }
      } else {
        if (this.mounted) {
          buildShowDialog(context);
        }

        while (this.mounted && context.canPop()) {
          context.pop();
        }

        context.push(AppRouteConstants.loginRouteName);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future _executeParallelRefresh() async {
    if (open == 0) {
      await getQuickSplitExpenses();
    } else {
      _extractEmail(open);
      getMembersData(open);
    }
  }

  Future<void> _extractEmail(int roomType) async {
    if (roomType == 1) {
      activeRoomDataFetched = false;
      RoomDataO.value.clear();
    } else {
      inActiveRoomDataFetched = false;
      RoomDataC.value.clear();
    }

    appVersion = await getAppVersion();

    if (this.mounted) {
      setState(() {});
    }

    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text),
        'version': crypto.encrypt(appVersion),
        'roomType': roomType == 1,
        'hasAlready': crypto.encrypt("0")
      };

      final response = await createHTTPreq(
          'data', http.post, _token, jsonInputData, context);

      if (response.statusCode == 200) {
        if (roomType == 1) {
          activeRoomHasMore.value = jsonDecode(response.body)['hasMore'];
        } else {
          inActiveRoomHasMore.value = jsonDecode(response.body)['hasMore'];
        }

        List<dynamic> list = jsonDecode(response.body)['data'];

        for (int i = 0; i < list.length; i++) {
          if (roomType == 1) {
            RoomDataO.value.add(RoomEach.fromJson(list[i]));
          } else {
            RoomDataC.value.add(RoomEach.fromJson(list[i]));
          }
        }

        if (roomType == 1) {
          activeRoomDataFetched = true;
        } else {
          inActiveRoomDataFetched = true;
        }

        if (this.mounted) {
          setState(() {});
        }
      } else if (response.statusCode == 503) {
        while (context.canPop()) {
          if (this.mounted) {
            context.pop();
          }
        }
        context.push(AppRouteConstants.maintainRouteName);
      } else {
        String errorMessage =
            crypto.decrypt(jsonDecode(response.body)['Message']);

        if (errorMessage == 'Login Expired') {
          await logout();
        } else if (this.mounted) {
          showToast(context, errorMessage, Icons.close);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->_extractEmail"]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getRoomRequest() async {
    try {
      if (this.mounted) {
        setState(() {
          isRoomRequestLoaded = false;
          RoomRequest.clear();
        });
      }
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text),
      };

      final response = await createHTTPreq(
          'friend', http.delete, _token, jsonInputData, context);

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        RoomRequest = data["data"];
      } else {
        String errorMessage = crypto.decrypt(data["Message"]);

        if (errorMessage == 'Login Expired') {
          await logout();
        } else if (this.mounted) {
          showToast(context, errorMessage, Icons.close);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->getRoomRequest"]);
      }
    }

    isRoomRequestLoaded = true;
    if (this.mounted) {
      setState(() {});
    }
  }

  SendingData(bool flag, BuildContext context) async {
    var response;
    if (this.mounted) {
      buildShowDialog(context);
    }

    try {
      if (open == 0) {
        if (!flag) {
          Map<String, dynamic> jsonInputData = {
            'email': crypto.encrypt(_email.text),
            'roomKey': crypto.encrypt(_NRoom.text),
          };

          response = await createHTTPreq(
              'quickSplit/join', http.post, _token, jsonInputData, context);

          _NRoom.text = "";
          var JsonData = jsonDecode(response.body);

          for (int i = 0; i < 3 && this.mounted && context.canPop(); i++) {
            context.pop();
          }
          if (response.statusCode == 200) {
            quickSplitData.value.insert(
                0, QuickSplitEach.fromJson(jsonDecode(response.body)['data']));
          } else {
            showToast(
                context, crypto.decrypt(JsonData["Message"]), Icons.close);
          }
        }
      } else {
        if (flag) {
          Map<String, dynamic> jsonInputData = {
            'email': crypto.encrypt(_email.text),
            'roomName': crypto.encrypt(_NRoom.text),
          };

          response = await createHTTPreq(
              'room', http.post, _token, jsonInputData, context);
        } else {
          Map<String, dynamic> jsonInputData = {
            'email': crypto.encrypt(_email.text),
            'roomKey': crypto.encrypt(_NRoom.text),
          };

          response = await createHTTPreq(
              'room', http.put, _token, jsonInputData, context);
        }

        _NRoom.text = "";
        var JsonData = jsonDecode(response.body);

        for (int i = 0; i < 3 && this.mounted && context.canPop(); i++) {
          context.pop();
        }

        if (response.statusCode == 200 && flag) {
          RoomDataO.value
              .insert(0, RoomEach.fromJson(jsonDecode(response.body)['data']));
          if (this.mounted) {
            setState(() {});
          }
        } else {
          showToast(context, crypto.decrypt(JsonData["Message"]),
              response.statusCode == 200 ? Icons.check : Icons.close);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }

      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["DashBoard->SendingData"]);
    }
  }

  Future<void> fetchSentRequest() async {
    try {
      if (this.mounted) {
        setState(() {
          isSentRoomRequestLoaded = false;
          sentRoomRequest.clear();
        });
      }
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text),
      };

      final response = await createHTTPreq(
          'friend/sender', http.post, _token, jsonInputData, context);

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        sentRoomRequest = data["data"];
      } else {
        String errorMessage = crypto.decrypt(data["Message"]);
        if (errorMessage == 'Login Expired') {
          await logout();
        } else if (this.mounted) {
          showToast(context, errorMessage, Icons.close);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->fetchSentRequest"]);
      }
    }
    isSentRoomRequestLoaded = true;

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> cancelSentRequest(String id, String type) async {
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text),
        'id': id,
        'type': type
      };

      final response = await createHTTPreq(
          'friend/sender', http.put, _token, jsonInputData, context);
      var data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->cancelSentRequest"]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }

    await _sentrequestIndicatorKey.currentState?.show();
  }

  Future<void> getQuickSplitExpenses() async {
    try {
      if (this.mounted) {
        setState(() {
          quickSplitData.value.clear();
          quickSplitDataFetched = false;
        });
      }

      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text),
      };

      final response = await createHTTPreq(
          'quickSplit/get', http.post, _token, jsonInputData, context);
      var data = jsonDecode(response.body);

      quickSplitDataFetched = true;
      if (response.statusCode != 200) {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      } else {
        var tempArr = data["data"];
        for (int i = 0; i < tempArr.length; i++) {
          quickSplitData.value.add(QuickSplitEach.fromJson(tempArr[i]));
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error",
            info: ["DashBoard->getQuickSplitExpenses"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  executeParallel() async {
    do {
      await initalDataLoad();
    } while (!initalDataLoaded);

    if (kIsWeb) {
      getInitialData();
      _extractEmail(1);
      _extractEmail(2);
      _getImageID();
      getMembersData(1);
      getMembersData(2);
      getQuickSplitExpenses();
      getRoomRequest();
      fetchSentRequest();
      getFriendData();
    } else if (Platform.isAndroid) {
      getInitialData();
      manualUpdateCheck();
      _extractEmail(1);
      _extractEmail(2);
      _getImageID();
      getMembersData(1);
      getMembersData(2);
      getQuickSplitExpenses();
      checkforScheduledNotifications();
      ContactPermissionGranted();
      checkForUpdate();
      getRoomRequest();
      fetchSentRequest();
      getFriendData();
    }
  }

  @override
  void initState() {
    super.initState();
    executeParallel();

    if (!kIsWeb) {
      FirebaseMessaging.instance.getInitialMessage().then(
            (message) async {},
          );

      FirebaseMessaging.onMessage.listen(
        (message) async {
          if (message.notification != null) {
            await notificationProcessor(message);
          }
        },
      );

      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) async {
          Map<String, String> notificationData =
              await getDataFromNotification(message.data.toString());
          if (notificationData["type"] == "RoomRequest" ||
              notificationData["type"] == "LenDenRequest") {
            context.push(AppRouteConstants.dashboardRouteName,
                extra: {'dash': 1, 'firstTime': false});
          } else if ((notificationData["type"]!) == "room") {
            context.push(AppRouteConstants.roomRouteName +
                "/" +
                notificationData["roomKey"]!);
          } else if (notificationData["type"] == "lend") {
            context.push(AppRouteConstants.lendByTitleRouteName +
                "/" +
                notificationData["roomKey"]!);
          } else if (notificationData["type"] == "account") {
            context.push(AppRouteConstants.profileRouteName);
          } else if (notificationData["type"] == "quickSplit") {
            context.push(AppRouteConstants.dashboardRouteName,
                extra: {'dash': 0, 'firstTime': false});
          } else {
            context.push(AppRouteConstants.dashboardRouteName,
                extra: {'dash': 0, 'firstTime': false});
          }
        },
      );

      AwesomeNotifications().setListeners(
        onActionReceivedMethod: (ReceivedAction receivedAction) async {
          NotificationController.onActionReceivedMethod(
              context, receivedAction);
        },
        onNotificationCreatedMethod:
            (ReceivedNotification receivedNotification) async {
          NotificationController.onNotificationCreatedMethod(
              context, receivedNotification);
        },
        onNotificationDisplayedMethod:
            (ReceivedNotification receivedNotification) async {
          NotificationController.onNotificationDisplayedMethod(
              context, receivedNotification);
        },
        onDismissActionReceivedMethod: (ReceivedAction receivedAction) async {
          NotificationController.onDismissActionReceivedMethod(
              context, receivedAction);
        },
      );
    }
  }

  Future<void> logOutFromGoogle() async {
    if (isGoogle) {
      await GoogleSignIN.logout();
    }
  }

  Future<void> deleteToken() async {
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email.text)
      };

      await createHTTPreq(
          'verify', http.delete, _token, jsonInputData, context);
    } on Exception catch (err, stackTrace) {
      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["DashBoard->sendContactData"]);
    }
  }

  buildLiveFilterDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setStat) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: SingleChildScrollView(
                    child: Container(
                        width: kIsWeb
                            ? max(
                                MediaQuery.of(context).size.width * 0.5,
                                min(400,
                                    MediaQuery.of(context).size.width * 0.95))
                            : MediaQuery.of(context).size.width * 0.95,
                        child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      "Live Room Filter",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    height: 110,
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: liveRoomCategory.length,
                                        itemBuilder: ((context, index) {
                                          return CheckboxListTile(
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                            title:
                                                Text(liveRoomCategory[index]),
                                            value: filterliveRoomCategoryIndex
                                                .contains(index),
                                            onChanged: (_) {
                                              if (filterliveRoomCategoryIndex
                                                  .contains(index)) {
                                                filterliveRoomCategoryIndex
                                                    .remove(index);
                                              } else {
                                                filterliveRoomCategoryIndex
                                                    .add(index);
                                              }

                                              if (this.mounted) {
                                                setStat(() {});
                                              }
                                            },
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                          );
                                        })),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: 34,
                                        width: 90,
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
                                            if (this.mounted) {
                                              context.pop();
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      SizedBox(
                                        height: 34,
                                        width: 90,
                                        child: OutlinedButton(
                                            child: Text(
                                              "Apply",
                                              style: TextStyle(
                                                  color:
                                                      themeProvider.isDarkTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                  fontSize: 16),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .primaryColor),
                                            ),
                                            onPressed: () async {
                                              if (filterliveRoomCategoryIndex
                                                  .isEmpty) {
                                                showToast(
                                                    context,
                                                    "Choose anyone",
                                                    Icons.warning);
                                              } else {
                                                if (filterliveRoomCategoryIndex
                                                        .length ==
                                                    2) {
                                                  setIntPref(
                                                      "liveCategoryIndex", 2);
                                                } else {
                                                  setIntPref(
                                                      "liveCategoryIndex",
                                                      filterliveRoomCategoryIndex
                                                          .first);
                                                }
                                                if (this.mounted) {
                                                  context.pop();
                                                }
                                                setStat(() {});
                                                setState(() {});
                                              }
                                            }),
                                      )
                                    ],
                                  )
                                ])))));
          });
        });
  }

  Widget memberCard(List<FriendEach> data, int index, Function ss) {
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
                    SizedBox(
                      height: 51,
                      child: CachedNetworkImage(
                        httpHeaders: {'Access-Control-Allow-Origin': '*'},
                        imageUrl: data[index].pic.length == 0
                            ? addCorsinImage(global.unknown_avatar_id)
                            : addCorsinImage(data[index].pic),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage('assets/Images/unknown.jpeg'),
                                fit: BoxFit.cover),
                          ),
                        ),
                        imageBuilder: (context, imageProvider) => Container(
                          width: 45.0,
                          height: 45.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 250,
                      child: InkWell(
                        onTap: () {
                          showToast(context, data[index].name, Icons.person);
                        },
                        child: AutoSizeText(
                          data[index].name,
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
                        onPressed: () async {
                          if (data[index].email.isEmpty) {
                            aditionalMembers.removeAt(index);
                          } else {
                            if (addExpenseTo.contains(data[index])) {
                              addExpenseTo.remove(data[index]);
                            } else {
                              addExpenseTo.add(data[index]);
                            }
                          }
                          if (this.mounted) {
                            ss(() {});
                          }
                        },
                        icon: data[index].email.isEmpty
                            ? Icon(Icons.cancel_outlined)
                            : Icon(!addExpenseTo.contains(data[index])
                                ? Icons.person_add_alt
                                : Icons.cancel_outlined))
                  ]),
            ),
          ),
        ));
  }

  Widget friendListWidget(BuildContext context, List<FriendEach> data) {
    return StatefulBuilder(builder: (context, setState) {
      return Scrollbar(
        radius: Radius.circular(10.0),
        thickness: 5.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.57,
              child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(
                        height: 5,
                      ),
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: data.length + aditionalMembers.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < aditionalMembers.length) {
                      return memberCard(aditionalMembers, index, setState);
                    } else {
                      return memberCard(
                          data, index - aditionalMembers.length, setState);
                    }
                  }),
            ),
          ],
        ),
      );
    });
  }

  SearchFriend() {
    if (this.mounted) {
      setState(() {
        friendDataSearched.clear();
      });
    }

    for (int i = 0; i < friendData.length; i++) {
      if (friendData[i]
          .name
          .toString()
          .toLowerCase()
          .contains(_searchFriend.text.toLowerCase())) {
        friendDataSearched.add(friendData[i]);
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> getFriendData() async {
    try {
      if (this.mounted) {
        setState(() {
          loadFriendData = false;
          friendData.clear();
        });
      }
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email.text),
      };

      final response = await createHTTPreq(
          'friend/all', http.post, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loadFriendData = true;
        List<dynamic> tempData = data['data'];
        for (int i = 0; i < tempData.length; i++) {
          FriendEach friend = FriendEach.fromJson(tempData[i]);
          if (friend.email != _email.text) {
            friendData.add(friend);
          }
        }
      } else {
        if (this.mounted) {
          showToast(context, crypto.decrypt(data["Message"]), Icons.close);
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["Analysis->getFriendData"]);
      }
    }
    if (!kIsWeb) {
      friendData = getUnionOfContacts(getContactsFromDB, friendData);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  addQuickSplitExpenseToSN(bool manualSplit) async {
    try {
      if (this.mounted) {
        buildShowDialog(context);
      }
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email.text),
        'purpose': crypto.encrypt(_purpose.text),
        'type': crypto.encrypt(expenseCategory[roomExpenseCategoryIndex]),
        'subType': crypto.encrypt(roomsubExpenseCategoryIndex != -1 &&
                subCategory[roomExpenseCategoryIndex].length > 0
            ? subCategory[roomExpenseCategoryIndex][roomsubExpenseCategoryIndex]
            : "None"),
        'SNsplit': crypto.encrypt(manualSplitAmount.toString()),
        '_split': crypto.encrypt(customManualSplitAmount.toString()),
        'amt': crypto.encrypt(manualSplit ? "-1" : _amt.text),
        'date': crypto
            .encrypt(DateFormat("MMM dd yyyy h:mm a").format(expenseDate)),
      };

      final response = await createHTTPreq(
          'quickSplit', http.post, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        aditionalMembers.clear();
        addExpenseTo.clear();
        _amt.text = "";
        _purpose.text = "";
        quickSplitData.value.insert(0, QuickSplitEach.fromJson(data["data"]));
        if (this.mounted) {
          setState(() {});
        }
      } else {
        if (this.mounted) {
          showToast(context, crypto.decrypt(data["Message"]), Icons.close);
        }
      }
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        context.pop();
      }
      if (manualSplit) {
        if (this.mounted) {
          context.pop();
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        context.pop();
      }
      if (manualSplit) {
        if (this.mounted) {
          context.pop();
        }
      }
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error",
            info: ["DashBoard->addQuickSplitExpenseToSN"]);
      }
    }
  }

  Widget eachMemberManualSplitCard(List<FriendEach> data, index, bool SNUser) {
    final amountController = new TextEditingController(text: "0");
    return Padding(
      padding: const EdgeInsets.all(11.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                httpHeaders: {'Access-Control-Allow-Origin': '*'},
                imageUrl: addCorsinImage(data[index].pic.length == 0
                    ? global.unknown_avatar_id
                    : data[index].pic),
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    CircularProgressIndicator(value: downloadProgress.progress),
                errorWidget: (context, url, error) => Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: AssetImage('assets/Images/unknown.jpeg'),
                        fit: BoxFit.cover),
                  ),
                ),
                imageBuilder: (context, imageProvider) => Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
              SizedBox(
                width: 6,
              ),
              InkWell(
                onTap: () =>
                    showToast(context, data[index].name, Icons.person_outlined),
                child: SizedBox(
                  width: 130,
                  child: Text(
                    data[index].name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "Rs",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 4,
              ),
              SizedBox(
                width: 50,
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 15),
                  autocorrect: false,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(8.0),
                    counterText: "",
                    errorStyle: const TextStyle(fontSize: 16),
                  ),
                  validator: (value) {
                    if (data[index].email == _email.text) {
                      if (amountController.text == "0") {
                        if (SNUser) {
                          manualSplitAmount[data[index].email] =
                              double.parse(amountController.text) * 100 / 100;
                        } else {
                          customManualSplitAmount[data[index].name] =
                              double.parse(amountController.text) * 100 / 100;
                        }

                        return null;
                      }
                    }
                    RegExp validateText = RegExp(r"^[1-9]\d*(\.\d+)?$");
                    if (!validateText.hasMatch(amountController.text)) {
                      return "";
                    } else {
                      if (SNUser) {
                        manualSplitAmount[data[index].email] =
                            double.parse(amountController.text) * 100 / 100;
                      } else {
                        customManualSplitAmount[data[index].name] =
                            double.parse(amountController.text) * 100 / 100;
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  splitManuallyWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    GlobalKey<FormState> _manualSplitKeySplitManuallyWidget =
        GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: SizedBox(
                    width: kIsWeb
                        ? max(MediaQuery.of(context).size.width * 0.5,
                            min(400, MediaQuery.of(context).size.width * 0.95))
                        : MediaQuery.of(context).size.width * 0.95,
                    child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Form(
                              key: _manualSplitKeySplitManuallyWidget,
                              child: SizedBox(
                                height: min(
                                    75.0 *
                                        (addExpenseTo.length +
                                            aditionalMembers.length +
                                            1),
                                    MediaQuery.of(context).size.height * 0.8),
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: addExpenseTo.length +
                                      aditionalMembers.length +
                                      1,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index < addExpenseTo.length) {
                                      return eachMemberManualSplitCard(
                                          addExpenseTo, index, true);
                                    } else if (index - addExpenseTo.length <
                                        aditionalMembers.length) {
                                      return eachMemberManualSplitCard(
                                          aditionalMembers,
                                          index - addExpenseTo.length,
                                          false);
                                    } else {
                                      return eachMemberManualSplitCard([
                                        FriendEach(
                                            requestID: "",
                                            name: _name.text,
                                            email: _email.text,
                                            status: "",
                                            pic: _profilePicID,
                                            isGoogle: isGoogle,
                                            phoneNo: "",
                                            fromContact: false)
                                      ], 0, true);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 43,
                                    width: 100,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: themeProvider.isDarkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        onPressed: () {
                                          if (this.mounted) {
                                            context.pop();
                                          }
                                        }),
                                  ),
                                  SizedBox(
                                    height: 43,
                                    width: 100,
                                    child: OutlinedButton(
                                        child: Text(
                                          "Add",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: themeProvider.isDarkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        onPressed: () async {
                                          if (_manualSplitKeySplitManuallyWidget
                                              .currentState!
                                              .validate()) {
                                            addQuickSplitExpenseToSN(true);
                                          } else {
                                            showToast(context, "Invalid Amount",
                                                Icons.warning_outlined);
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ))));
          });
        });
  }

  AddQuickSplitExpense() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: Container(
                width: kIsWeb
                    ? max(MediaQuery.of(context).size.width * 0.5,
                        min(400, MediaQuery.of(context).size.width * 0.9))
                    : MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(
                        "Add Expense",
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            splitManually
                                ? SizedBox()
                                : TextFormField(
                                    controller: _amt,
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    maxLines: 1,
                                    style: const TextStyle(fontSize: 18),
                                    autocorrect: false,
                                    validator: (value) {
                                      RegExp validateNumber =
                                          RegExp(r'^\d+(\.\d{1,2})?$');
                                      if (!validateNumber.hasMatch(_amt.text)) {
                                        return "Enter Valid Amount";
                                      }
                                      return null;
                                    },
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.all(8.0),
                                      hintText: "Enter Amount",
                                      counterText: "",
                                      labelText: "Amount",
                                      errorStyle: TextStyle(fontSize: 15),
                                    ),
                                  ),
                            TextFormField(
                              controller: _purpose,
                              keyboardType: TextInputType.text,
                              maxLength: 1000,
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
                                counterText: "",
                                errorStyle: TextStyle(fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: expenseCategory.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        child: Card(
                                          color: Theme.of(context)
                                              .dialogBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color:
                                                    roomExpenseCategoryIndex ==
                                                            index
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .cardColor),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                              child: Text(
                                                expenseCategory[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          if (this.mounted) {
                                            setState(
                                              () {
                                                roomExpenseCategoryIndex =
                                                    index;
                                                roomsubExpenseCategoryIndex = 0;
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            subCategory[roomExpenseCategoryIndex].length > 0
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.96,
                                    height: 70,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          subCategory[roomExpenseCategoryIndex]
                                              .length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              child: Card(
                                                color: Theme.of(context)
                                                    .dialogBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: (index ==
                                                              roomsubExpenseCategoryIndex
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .cardColor)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Center(
                                                    child: InkWell(
                                                      child: Text(
                                                        subCategory[
                                                                roomExpenseCategoryIndex]
                                                            [index],
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                if (this.mounted) {
                                                  setState(
                                                    () {
                                                      roomsubExpenseCategoryIndex =
                                                          index;
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 7,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Add Member",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (this.mounted) {
                                        showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext context) =>
                                                    StatefulBuilder(builder:
                                                        (context, setState) {
                                                      return Dialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0)),
                                                        child: Container(
                                                            width: kIsWeb
                                                                ? max(
                                                                    MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                    min(
                                                                        400,
                                                                        MediaQuery.of(context)
                                                                            .size
                                                                            .width))
                                                                : MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          "Invite Member",
                                                                          style:
                                                                              TextStyle(fontSize: 22),
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                if (this.mounted) {
                                                                                  setState(() {
                                                                                    loadFriendData = false;
                                                                                    friendData.clear();
                                                                                  });
                                                                                }
                                                                                await getFriendData();
                                                                                if (this.mounted) {
                                                                                  setState(() {});
                                                                                }
                                                                              },
                                                                              child: Icon(Icons.refresh, size: 26),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 6,
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () {
                                                                                context.pop();
                                                                              },
                                                                              child: Icon(Icons.cancel_outlined, size: 26),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    loadFriendData
                                                                        ? friendData.isEmpty &&
                                                                                aditionalMembers.isEmpty
                                                                            ? SizedBox(
                                                                                height: MediaQuery.of(context).size.height * 0.7,
                                                                                child: Center(
                                                                                  child: Text(
                                                                                    "No User Found",
                                                                                    style: TextStyle(fontSize: 20),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Column(
                                                                                children: [
                                                                                  TextField(
                                                                                    controller: _searchFriend,
                                                                                    keyboardType: TextInputType.text,
                                                                                    maxLines: 1,
                                                                                    style: const TextStyle(fontSize: 15),
                                                                                    autocorrect: false,
                                                                                    decoration: InputDecoration(
                                                                                      contentPadding: const EdgeInsets.all(8.0),
                                                                                      labelText: "Enter Name",
                                                                                      counterText: "",
                                                                                      errorStyle: const TextStyle(fontSize: 15),
                                                                                    ),
                                                                                    onChanged: (String s) {
                                                                                      _searchFriend.text = s;
                                                                                      _searchFriend.selection = TextSelection.collapsed(offset: _searchFriend.text.length);
                                                                                      SearchFriend();
                                                                                      if (this.mounted) {
                                                                                        setState(() {});
                                                                                      }
                                                                                    },
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 13,
                                                                                  ),
                                                                                  SingleChildScrollView(
                                                                                    child: SizedBox(
                                                                                      height: MediaQuery.of(context).size.height * 0.57,
                                                                                      child: _searchFriend.text.isEmpty
                                                                                          ? friendListWidget(context, friendData)
                                                                                          : (friendDataSearched.isEmpty
                                                                                              ? Center(
                                                                                                  child: Text(
                                                                                                    "No User Found",
                                                                                                    style: TextStyle(fontSize: 18),
                                                                                                  ),
                                                                                                )
                                                                                              : friendListWidget(context, friendDataSearched)),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                        : SizedBox(
                                                                            height:
                                                                                MediaQuery.of(context).size.height - 310,
                                                                            child:
                                                                                Center(
                                                                              child: CircularProgressIndicator.adaptive(),
                                                                            ),
                                                                          ),
                                                                    SizedBox(
                                                                      height:
                                                                          55,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.9,
                                                                      child:
                                                                          OutlinedButton(
                                                                        style: OutlinedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                          side:
                                                                              BorderSide(color: Theme.of(context).primaryColor),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          final name =
                                                                              new TextEditingController();
                                                                          GlobalKey<FormState>
                                                                              nameForm =
                                                                              GlobalKey<FormState>();
                                                                          showDialog(
                                                                              context: context,
                                                                              barrierDismissible: false,
                                                                              builder: (BuildContext context) {
                                                                                return StatefulBuilder(builder: (context, setState) {
                                                                                  return Dialog(
                                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                                                                                      child: SizedBox(
                                                                                        height: 165,
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.all(10.0),
                                                                                          child: Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                            children: [
                                                                                              Form(
                                                                                                key: nameForm,
                                                                                                child: TextFormField(
                                                                                                  controller: name,
                                                                                                  keyboardType: TextInputType.text,
                                                                                                  maxLength: 100,
                                                                                                  maxLines: 1,
                                                                                                  style: const TextStyle(fontSize: 18),
                                                                                                  autocorrect: false,
                                                                                                  validator: (value) {
                                                                                                    RegExp validateName = RegExp(r'^[\w\s]{2,}$');
                                                                                                    if (!validateName.hasMatch(name.text)) {
                                                                                                      return "Enter Valid Name";
                                                                                                    }
                                                                                                    return null;
                                                                                                  },
                                                                                                  decoration: const InputDecoration(
                                                                                                    contentPadding: EdgeInsets.all(8.0),
                                                                                                    hintText: "Enter Name",
                                                                                                    counterText: "",
                                                                                                    labelText: "Name",
                                                                                                    errorStyle: TextStyle(fontSize: 15),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: 15,
                                                                                              ),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                children: [
                                                                                                  SizedBox(
                                                                                                    height: 43,
                                                                                                    width: 100,
                                                                                                    child: OutlinedButton(
                                                                                                        style: OutlinedButton.styleFrom(
                                                                                                          shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                                                          ),
                                                                                                          side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                                        ),
                                                                                                        child: Text(
                                                                                                          "Close",
                                                                                                          style: TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                                                        ),
                                                                                                        onPressed: () {
                                                                                                          if (this.mounted) {
                                                                                                            context.pop();
                                                                                                          }
                                                                                                        }),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 43,
                                                                                                    width: 100,
                                                                                                    child: OutlinedButton(
                                                                                                        style: OutlinedButton.styleFrom(
                                                                                                          shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(10.0),
                                                                                                          ),
                                                                                                          side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                                        ),
                                                                                                        child: Text(
                                                                                                          "Add",
                                                                                                          style: TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                                                        ),
                                                                                                        onPressed: () {
                                                                                                          if (nameForm.currentState!.validate()) {
                                                                                                            aditionalMembers.add(FriendEach(requestID: "", name: name.text, email: "", status: "", pic: "", isGoogle: false, phoneNo: "", fromContact: false));
                                                                                                            if (this.mounted) {
                                                                                                              setState(() {});
                                                                                                              context.pop();
                                                                                                            }
                                                                                                          }
                                                                                                        }),
                                                                                                  ),
                                                                                                ],
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ));
                                                                                });
                                                                              });
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Add Member Manually",
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          55,
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.9,
                                                                      child:
                                                                          OutlinedButton(
                                                                        style: OutlinedButton
                                                                            .styleFrom(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                          side:
                                                                              BorderSide(color: Theme.of(context).primaryColor),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          if (this
                                                                              .mounted) {
                                                                            context.pop();
                                                                          }
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          "Done",
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ))),
                                                      );
                                                    }));
                                      }
                                    },
                                    child: Icon(
                                      Icons.person_add_outlined,
                                      size: 20,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Split Manually",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (this.mounted) {
                                        setState(() {
                                          splitManually = !splitManually;
                                        });
                                      }
                                    },
                                    child: Icon(
                                      splitManually
                                          ? Icons.toggle_on
                                          : Icons.toggle_off,
                                      size: 40,
                                      color: splitManually
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat(global.dateTimeFormat_new)
                                          .format(expenseDate),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        DateTime? dateTime =
                                            await showOmniDateTimePicker(
                                          context: context,
                                          is24HourMode: false,
                                          isShowSeconds: false,
                                          initialDate: expenseDate,
                                          firstDate: DateTime(2018),
                                          lastDate: DateTime.now(),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        );

                                        if (this.mounted) {
                                          setState(() {
                                            expenseDate = dateTime!;
                                          });
                                        }
                                      },
                                      child: Icon(
                                        Icons.edit_calendar,
                                        size: 22,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    height: 43,
                                    width: 100,
                                    child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        child: Text(
                                          "Close",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: themeProvider.isDarkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        onPressed: () {
                                          if (this.mounted) {
                                            context.pop();
                                          }
                                        }),
                                  ),
                                  SizedBox(
                                    height: 43,
                                    width: 100,
                                    child: OutlinedButton(
                                        child: Text(
                                          splitManually ? "Next" : "Add",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: themeProvider.isDarkTheme
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        onPressed: () async {
                                          if (addExpenseTo.isEmpty &&
                                              aditionalMembers.isEmpty) {
                                            showToast(context, "Choose Members",
                                                Icons.warning_outlined);
                                          } else {
                                            manualSplitAmount.clear();
                                            customManualSplitAmount.clear();
                                            if (splitManually) {
                                              RegExp validateText =
                                                  RegExp(r'\b[\w]+\b');
                                              if (!validateText
                                                  .hasMatch(_purpose.text)) {
                                                showToast(
                                                    context,
                                                    "Enter Valid Purpose",
                                                    Icons.warning_outlined);
                                              } else {
                                                splitManuallyWidget(context);
                                              }
                                            } else {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                int membersCnt = 1 +
                                                    addExpenseTo.length +
                                                    aditionalMembers.length;
                                                double avgAmt =
                                                    (double.parse(_amt.text) *
                                                            100 /
                                                            membersCnt) /
                                                        100;
                                                addExpenseTo.forEach((element) {
                                                  manualSplitAmount[
                                                      element.email] = avgAmt;
                                                });
                                                aditionalMembers
                                                    .forEach((element) {
                                                  customManualSplitAmount[
                                                      element.name] = avgAmt;
                                                });

                                                manualSplitAmount[_email.text] =
                                                    avgAmt;

                                                await addQuickSplitExpenseToSN(
                                                    false);
                                              }
                                            }
                                          }
                                        }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            );
          });
        });
  }

  void pickDateRange(Function fn) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final picked = await showDateRangePicker(
        context: context,
        initialDateRange: dateRange,
        confirmText: "Ok",
        helpText: "Select Date",
        saveText: "Save",
        firstDate: new DateTime(1999),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: themeProvider.isDarkTheme
                ? ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.white,
                    ),
                    dialogBackgroundColor: Colors.white,
                  )
                : ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    dialogBackgroundColor: Colors.white,
                  ),
            child: child!,
          );
        });
    if (picked != null) {
      if (this.mounted) {
        setState(() {
          dateRange = picked;
        });
        fn(() {
          dateRange = picked;
        });
      }
    }
  }

  buildFilterDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setStat) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              child: SingleChildScrollView(
                child: Container(
                  width: kIsWeb
                      ? max(MediaQuery.of(context).size.width * 0.5,
                          min(400, MediaQuery.of(context).size.width * 0.95))
                      : MediaQuery.of(context).size.width * 0.95,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                                onPressed: () {
                                  pickDateRange(setStat);
                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                                icon: Icon(Icons.date_range)),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                pickDateRange(setStat);
                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                              child: Card(
                                elevation: 1,
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Theme.of(context).cardColor),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      DateFormat('dd MMM, yyyy')
                                          .format(dateRange.start),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 35,
                              child: Text("-", style: TextStyle(fontSize: 18)),
                            ),
                            Card(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Theme.of(context).cardColor),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: InkWell(
                                    onTap: () {
                                      pickDateRange(setStat);
                                      if (this.mounted) {
                                        setState(() {});
                                      }
                                    },
                                    child: Text(
                                        DateFormat('dd MMM, yyyy')
                                            .format(dateRange.end),
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                          setStat(() {
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
                                  if (this.mounted) {
                                    context.pop();
                                  }
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
                                  "Clear",
                                  style: TextStyle(
                                      color: themeProvider.isDarkTheme
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16),
                                ),
                                onPressed: () {
                                  if (this.mounted) {
                                    setState(() {
                                      roomStatusIndex = 0;
                                      dateRange = DateTimeRange(
                                          start: new DateTime(2018, 1),
                                          end: DateTime.now());
                                    });
                                    setStat(() {
                                      roomStatusIndex = 0;
                                      dateRange = DateTimeRange(
                                          start: new DateTime(2018, 1),
                                          end: DateTime.now());
                                    });
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  side: BorderSide(color: Colors.redAccent),
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
                                  if (this.mounted) {
                                    setState(() {});
                                    setStat(() {});
                                  }
                                  if (this.mounted) {
                                    context.pop();
                                  }
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
      if (open == 0) {
        SearchAndFilterQuickSplitData();
      } else {
        SearchAndFilterRoomData();
      }
    });
  }

  SearchAndFilterRoomData() {
    if (this.mounted) {
      setState(() {
        searching = true;
        SearchRoomData.value.clear();
      });
    }
    DateFormat dateFormat = DateFormat("MMM dd yyyy h:mm a");
    for (int i = 0;
        i < RoomDataC.value.length &&
            (roomStatusIndex == 0 || roomStatusIndex == 2);
        i++) {
      DateTime transDate = dateFormat
          .parse(RoomDataC.value[i].date.substring(0, 12) + "12:00 AM");
      if (_search.text.length > 0 &&
          RoomDataC.value[i].roomName
              .toLowerCase()
              .contains(_search.text.toLowerCase())) {
        if ((dateRange.start.isAtSameMomentAs(transDate) ||
                dateRange.start.isBefore(transDate)) &&
            (dateRange.end.isAtSameMomentAs(transDate) ||
                dateRange.end.isAfter(transDate))) {
          SearchRoomData.value.add(RoomDataC.value[i]);
        }
      } else if ((_search.text.length == 7 &&
              RoomDataC.value[i].roomKey == _search.text) ||
          _search.text.length == 0) {
        if ((dateRange.start.isAtSameMomentAs(transDate) ||
                dateRange.start.isBefore(transDate)) &&
            (dateRange.end.isAtSameMomentAs(transDate) ||
                dateRange.end.isAfter(transDate))) {
          SearchRoomData.value.add(RoomDataC.value[i]);
        }
      }
    }
    for (int i = 0;
        i < RoomDataO.value.length &&
            (roomStatusIndex == 0 || roomStatusIndex == 1);
        i++) {
      DateTime transDate = dateFormat
          .parse(RoomDataO.value[i].date.substring(0, 12) + "12:00 AM");
      if (_search.text.length > 0 &&
          RoomDataO.value[i].roomName
              .toLowerCase()
              .contains(_search.text.toLowerCase())) {
        if ((dateRange.start.isAtSameMomentAs(transDate) ||
                dateRange.start.isBefore(transDate)) &&
            (dateRange.end.isAtSameMomentAs(transDate) ||
                dateRange.end.isAfter(transDate))) {
          SearchRoomData.value.add(RoomDataO.value[i]);
        }
      } else if ((_search.text.length == 7 &&
              RoomDataO.value[i].roomKey == _search.text) ||
          _search.text.length == 0) {
        if ((dateRange.start.isAtSameMomentAs(transDate) ||
                dateRange.start.isBefore(transDate)) &&
            (dateRange.end.isAtSameMomentAs(transDate) ||
                dateRange.end.isAfter(transDate))) {
          SearchRoomData.value.add(RoomDataO.value[i]);
        }
      }
    }

    SearchRoomData.value.sort((b, a) {
      DateTime tempDate_1 =
          new DateFormat(global.dateTimeFormat_new).parse(a.date);
      DateTime tempDate_2 =
          new DateFormat(global.dateTimeFormat_new).parse(b.date);
      return tempDate_1.compareTo(tempDate_2);
    });

    heightSearched = SearchRoomData.value.length * 120;
    searching = false;

    if (this.mounted) {
      setState(() {});
    }
  }

  SearchAndFilterQuickSplitData() {
    if (this.mounted) {
      setState(() {
        searching = true;
        SearchQuickSplitData.value.clear();
      });
    }
    DateFormat dateFormat = DateFormat("MMM dd yyyy h:mm a");

    for (int i = 0; i < quickSplitData.value.length; i++) {
      DateTime transDate = dateFormat
          .parse(quickSplitData.value[i].date.substring(0, 12) + "12:00 AM");
      if ((quickSplitData.value[i].active && roomStatusIndex == 1) ||
          (!quickSplitData.value[i].active && roomStatusIndex == 2) ||
          roomStatusIndex == 0) {
        if ((_search.text.length > 0 &&
                quickSplitData.value[i].purpose
                    .toLowerCase()
                    .contains(_search.text.toLowerCase())) ||
            _search.text.length == 0) {
          if ((dateRange.start.isAtSameMomentAs(transDate) ||
                  dateRange.start.isBefore(transDate)) &&
              (dateRange.end.isAtSameMomentAs(transDate) ||
                  dateRange.end.isAfter(transDate))) {
            SearchQuickSplitData.value.add(quickSplitData.value[i]);
          }
        }
      }
    }

    SearchQuickSplitData.value.sort((b, a) {
      DateTime tempDate_1 =
          new DateFormat(global.dateTimeFormat_new).parse(a.date);
      DateTime tempDate_2 =
          new DateFormat(global.dateTimeFormat_new).parse(b.date);
      return tempDate_1.compareTo(tempDate_2);
    });

    heightSearched = SearchQuickSplitData.value.length * 120;
    searching = false;

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> JoinRequest(String flag, String roomKey, String id) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, dynamic> jsonInputData = {
        'roomKey': roomKey,
        'email': crypto.encrypt(_email.text),
        'id': id,
        'confirm': crypto.encrypt(flag)
      };

      final response = await createHTTPreq(
          'friend', http.put, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
      if (flag == "1") {
        _extractEmail(1);
        getRoomRequest();
        getMembersData(1);
      } else {
        await _requestIndicatorKey.currentState?.show();
      }
      if (this.mounted) {
        context.pop();
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->JoinRequest"]);
      }
    }
  }

  Future<void> JoinRequestLend(String flag, String roomKey, String id) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, dynamic> jsonInputData = {
        'roomKey': roomKey,
        'id': id,
        'email': crypto.encrypt(_email.text),
        'confirm': crypto.encrypt(flag)
      };

      final response = await createHTTPreq(
          'friend/lend', http.put, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
      await _requestIndicatorKey.currentState?.show();
      if (this.mounted) {
        context.pop();
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->JoinRequestLend"]);
      }
    }
  }

  Widget RequestWidget(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(context).size.width - 162) * 0.5,
              vertical: 16),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.all(Radius.circular(24))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (this.mounted) {
                    setState(() {
                      requestType = true;
                    });
                  }
                  Map<String, dynamic> jsonInputData = {
                    'email': crypto.encrypt(_email.text),
                    "url": crypto.encrypt(AppRouteConstants.dashboardRouteName +
                        "Request/Receive"),
                    "creationDate": crypto.encrypt(DateTime.now().toString())
                  };
                  pushAnalytics(context, jsonInputData, _token);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 8.0),
                  child: Text(
                    "Receive",
                    style: TextStyle(
                        fontSize: 18,
                        color:
                            requestType ? Theme.of(context).primaryColor : null,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Text(
                "|",
                style: TextStyle(
                    fontSize: 18, color: null, fontWeight: FontWeight.w600),
              ),
              InkWell(
                onTap: () {
                  if (this.mounted) {
                    setState(() {
                      requestType = false;
                    });
                  }
                  Map<String, dynamic> jsonInputData = {
                    'email': crypto.encrypt(_email.text),
                    "url": crypto.encrypt(
                        AppRouteConstants.dashboardRouteName + "Request/Sent"),
                    "creationDate": crypto.encrypt(DateTime.now().toString())
                  };
                  pushAnalytics(context, jsonInputData, _token);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 8.0),
                  child: Text(
                    "Sent",
                    style: TextStyle(
                        fontSize: 18,
                        color:
                            requestType ? null : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          )),
      body: requestType
          ? RefreshIndicator(
              color: Theme.of(context).primaryColor,
              key: _requestIndicatorKey,
              onRefresh: getRoomRequest,
              child: RoomRequest.isEmpty
                  ? isRoomRequestLoaded
                      ? (ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
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
                        ))
                      : SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Shimmer.fromColors(
                              baseColor: Theme.of(context).cardColor,
                              highlightColor: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.separated(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(8.0),
                                    itemCount: 16,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          height: 8,
                                        ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              170,
                                                      height: 15.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      height: 15.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              140,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          Icon(
                                                            Icons.cancel_sharp,
                                                            size: 30,
                                                          ),
                                                          Icon(
                                                            Icons.check,
                                                            size: 30,
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )),
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
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
                                          httpHeaders: {
                                            'Access-Control-Allow-Origin': '*'
                                          },
                                          imageUrl: crypto
                                                      .decrypt(
                                                          RoomRequest[index]
                                                              ["pic"])
                                                      .length ==
                                                  0
                                              ? addCorsinImage(
                                                  global.unknown_avatar_id)
                                              : addCorsinImage(crypto.decrypt(
                                                  RoomRequest[index]["pic"])),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
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
                                          imageBuilder:
                                              (context, imageProvider) =>
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
                                                            RoomRequest[index]
                                                                ["by"]) +
                                                        (RoomRequest[index]
                                                                ["selfInvite"]
                                                            ? " requested to join "
                                                            : " invited to join ") +
                                                        crypto.decrypt(
                                                            RoomRequest[index]
                                                                ["name"]) +
                                                        (crypto.decrypt(RoomRequest[
                                                                        index]
                                                                    ["type"]) ==
                                                                "Room"
                                                            ? ""
                                                            : " (Len-Den)"),
                                                    style: TextStyle(
                                                      overflow:
                                                          TextOverflow.clip,
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
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () async {
                                                            if ((crypto.decrypt(
                                                                    RoomRequest[
                                                                            index]
                                                                        [
                                                                        "type"]) ==
                                                                "Room")) {
                                                              await JoinRequest(
                                                                  "0",
                                                                  RoomRequest[
                                                                          index]
                                                                      ["key"],
                                                                  RoomRequest[
                                                                          index]
                                                                      ["id"]);
                                                            } else {
                                                              await JoinRequestLend(
                                                                  "0",
                                                                  RoomRequest[
                                                                          index]
                                                                      ["key"],
                                                                  RoomRequest[
                                                                          index]
                                                                      ["id"]);
                                                            }
                                                          },
                                                          icon: Icon(
                                                            Icons.cancel_sharp,
                                                            size: 30,
                                                            color: Colors.red,
                                                          )),
                                                      IconButton(
                                                          onPressed: () async {
                                                            if ((crypto.decrypt(
                                                                    RoomRequest[
                                                                            index]
                                                                        [
                                                                        "type"]) ==
                                                                "Room")) {
                                                              await JoinRequest(
                                                                  "1",
                                                                  RoomRequest[
                                                                          index]
                                                                      ["key"],
                                                                  RoomRequest[
                                                                          index]
                                                                      ["id"]);
                                                            } else {
                                                              await JoinRequestLend(
                                                                  "1",
                                                                  RoomRequest[
                                                                          index]
                                                                      ["key"],
                                                                  RoomRequest[
                                                                          index]
                                                                      ["id"]);
                                                            }
                                                          },
                                                          icon: Icon(
                                                              Icons.check,
                                                              size: 30,
                                                              color: Colors
                                                                  .greenAccent)),
                                                    ],
                                                  ),
                                                )
                                              ])),
                                    ],
                                  )),
                            );
                          }),
                    ),
            )
          : RefreshIndicator(
              color: Theme.of(context).primaryColor,
              key: _sentrequestIndicatorKey,
              onRefresh: fetchSentRequest,
              child: sentRoomRequest.isEmpty
                  ? isSentRoomRequestLoaded
                      ? ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.85,
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
                      : SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: Shimmer.fromColors(
                              baseColor: Theme.of(context).cardColor,
                              highlightColor: Theme.of(context).primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListView.separated(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(8.0),
                                    itemCount: 16,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(
                                          height: 5,
                                        ),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              160,
                                                      height: 15.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Container(
                                                      width: 200,
                                                      height: 15.0,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.white,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            140,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              height: 42,
                                                              width: 90,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(10))),
                                                              child: Center(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          12.0),
                                                                  child: Text(
                                                                    "Cancel",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ))
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              )),
                        )
                  : Scrollbar(
                      radius: Radius.circular(10.0),
                      thickness: 5.5,
                      child: ListView.separated(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(8.0),
                          itemCount: sentRoomRequest.length,
                          separatorBuilder: (context, index) => SizedBox(
                                height: 5,
                              ),
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              child: Card(
                                  elevation: 1.0,
                                  clipBehavior: Clip.antiAlias,
                                  shadowColor: Theme.of(context).primaryColor,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
                                          httpHeaders: {
                                            'Access-Control-Allow-Origin': '*'
                                          },
                                          imageUrl: crypto
                                                      .decrypt(
                                                          sentRoomRequest[index]
                                                              ["pic"])
                                                      .length ==
                                                  0
                                              ? addCorsinImage(
                                                  global.unknown_avatar_id)
                                              : addCorsinImage(crypto.decrypt(
                                                  sentRoomRequest[index]
                                                      ["pic"])),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
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
                                          imageBuilder:
                                              (context, imageProvider) =>
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
                                                    (sentRoomRequest[index]
                                                            ["selfInvite"])
                                                        ? ("You requested to join " +
                                                            crypto.decrypt(
                                                                sentRoomRequest[index]
                                                                    ["name"]))
                                                        : ("You invited " +
                                                            crypto.decrypt(
                                                                sentRoomRequest[
                                                                        index]
                                                                    ["by"]) +
                                                            " to join " +
                                                            crypto.decrypt(
                                                                sentRoomRequest[
                                                                        index]
                                                                    ["name"]) +
                                                            (crypto.decrypt(sentRoomRequest[index]
                                                                        ["type"]) ==
                                                                    "Room"
                                                                ? ""
                                                                : " (Len-Den)")),
                                                    style: TextStyle(
                                                      overflow:
                                                          TextOverflow.clip,
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
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          buildShowDialog(
                                                              context);
                                                          cancelSentRequest(
                                                              sentRoomRequest[
                                                                  index]["key"],
                                                              sentRoomRequest[
                                                                      index]
                                                                  ["type"]);
                                                          context.pop();
                                                        },
                                                        child: SizedBox(
                                                          child: Card(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      12.0),
                                                              child: Text(
                                                                "Cancel",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ])),
                                    ],
                                  )),
                            );
                          }),
                    ),
            ),
    );
  }

  Widget splitRoomShimmerWidget() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 250,
          child: ListView.separated(
            padding: EdgeInsets.all(8.0),
            itemCount: 16,
            separatorBuilder: (context, index) => SizedBox(
              height: 30,
            ),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 250,
                        height: 18.0,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              Container(
                                width: 28.0,
                                height: 28.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/Images/unknown.jpeg'),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                child: Container(
                                  width: 28.0,
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/Images/unknown.jpeg'),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 40,
                                child: Container(
                                  width: 28.0,
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/Images/unknown.jpeg'),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 60,
                                child: Container(
                                  width: 28.0,
                                  height: 28.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/Images/unknown.jpeg'),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              )
                            ],
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
                                Container(
                                  width: 150,
                                  height: 14.0,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  width: 150,
                                  height: 14.0,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 14.0,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Container(
                                  width: 150,
                                  height: 14.0,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget homeWidget(BuildContext context) {
    return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        key: _refreshIndicatorKey,
        onRefresh: _executeParallelRefresh,
        child: (RoomDataO.value.isEmpty &&
                RoomDataC.value.isEmpty &&
                quickSplitData.value.isEmpty)
            ? ((activeRoomDataFetched ||
                    inActiveRoomDataFetched ||
                    quickSplitDataFetched)
                ? ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 40,
                              decoration: open == 0
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
                                    onTap: () {
                                      if (this.mounted) {
                                        setState(() {
                                          open = 0;
                                        });
                                      }
                                    },
                                    child: Text(
                                      "Quick Split",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 80,
                              height: 40,
                              decoration: open == 1
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
                                      if (this.mounted) {
                                        setState(() {
                                          open = 1;
                                        });
                                      }
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
                              decoration: open == 2
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: Colors.red, width: 2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(13)))
                                  : null,
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
                                      if (this.mounted) {
                                        setState(() {
                                          open = 2;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                          onHorizontalDragEnd: (details) async {
                            if (details.primaryVelocity! > 0) {
                              if (this.mounted) {
                                setState(() {
                                  open = max(0, open - 1);
                                });
                              }
                            }

                            if (details.primaryVelocity! < 0) {
                              if (this.mounted) {
                                setState(() {
                                  open = min(2, open + 1);
                                });
                              }
                            }
                          },
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.9,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                "No Room Joined, Create One!",
                                style: TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ))
                    ],
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Shimmer.fromColors(
                      baseColor: Theme.of(context).cardColor,
                      highlightColor: Theme.of(context).primaryColor,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 40,
                                decoration: open == 0
                                    ? BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 2),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(13)))
                                    : null,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      "Quick Split",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 80,
                                height: 40,
                                decoration: open == 1
                                    ? BoxDecoration(
                                        border: Border.all(
                                            color:
                                                Theme.of(context).primaryColor,
                                            width: 2),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(13)))
                                    : null,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      "Live",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
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
                                decoration: open == 2
                                    ? BoxDecoration(
                                        border: Border.all(
                                            color: Colors.red, width: 2),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(13)))
                                    : null,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      "Closed",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          splitRoomShimmerWidget()
                        ],
                      ),
                    ),
                  ))
            : (searchTrigger
                ? _search.text.length == 0 &&
                        (SearchRoomData.value.isEmpty ||
                            SearchQuickSplitData.value.isEmpty)
                    ? Center(
                        child: Text(
                          open == 0
                              ? "Search QuickSplit..."
                              : "Search Rooms...",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      )
                    : (SearchRoomData.value.isEmpty &&
                            SearchQuickSplitData.value.isEmpty
                        ? Center(
                            child: searching
                                ? CircularProgressIndicator.adaptive()
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
                                  child: Text((open == 0
                                              ? SearchQuickSplitData.value
                                              : SearchRoomData.value)
                                          .length
                                          .toString() +
                                      " Results Found"),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 180,
                                  child: open == 0
                                      ? QuickSplit(
                                          RoomData: SearchQuickSplitData,
                                          email: _email.text,
                                          hasMore: ValueNotifier(false),
                                          token: _token,
                                          expenseCategory: expenseCategory,
                                          subCategory: subCategory,
                                        )
                                      : RoomWidget(
                                          RoomData: SearchRoomData,
                                          ClosedRoomData: RoomDataC,
                                          email: _email.text,
                                          flag: true,
                                          token: _token,
                                          hasMore: ValueNotifier(false),
                                          roomType: 2,
                                          membersData: membersData,
                                          liveRoomType: 0,
                                        ),
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
                              width: 100,
                              height: 40,
                              decoration: open == 0
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
                                    onTap: () {
                                      if (this.mounted) {
                                        setState(() {
                                          open = 0;
                                        });
                                      }
                                      Map<String, dynamic> jsonInputData = {
                                        'email': crypto.encrypt(_email.text),
                                        "url": crypto.encrypt(AppRouteConstants
                                                .dashboardRouteName +
                                            "Room/QuickSplit"),
                                        "creationDate": crypto
                                            .encrypt(DateTime.now().toString())
                                      };
                                      pushAnalytics(
                                          context, jsonInputData, _token);
                                    },
                                    child: Text(
                                      "Quick Split",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: 80,
                              height: 40,
                              decoration: open == 1
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
                                      Map<String, dynamic> jsonInputData = {
                                        'email': crypto.encrypt(_email.text),
                                        "url": crypto.encrypt(AppRouteConstants
                                                .dashboardRouteName +
                                            "Room/Active"),
                                        "creationDate": crypto
                                            .encrypt(DateTime.now().toString())
                                      };
                                      pushAnalytics(
                                          context, jsonInputData, _token);
                                      if (this.mounted) {
                                        setState(() {
                                          open = 1;
                                        });
                                      }
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
                              decoration: open == 2
                                  ? BoxDecoration(
                                      border: Border.all(
                                          color: Colors.red, width: 2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(13)))
                                  : null,
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
                                      if (this.mounted) {
                                        setState(() {
                                          open = 2;
                                        });
                                      }

                                      Map<String, dynamic> jsonInputData = {
                                        'email': crypto.encrypt(_email.text),
                                        "url": crypto.encrypt(AppRouteConstants
                                                .dashboardRouteName +
                                            "Room/Closed"),
                                        "creationDate": crypto
                                            .encrypt(DateTime.now().toString())
                                      };
                                      pushAnalytics(
                                          context, jsonInputData, _token);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onHorizontalDragEnd: (details) async {
                          if (details.primaryVelocity! > 0) {
                            if (this.mounted) {
                              setState(() {
                                open = max(0, open - 1);
                              });
                            }
                          }

                          if (details.primaryVelocity! < 0) {
                            if (this.mounted) {
                              setState(() {
                                open = min(2, open + 1);
                              });
                            }
                          }

                          if (details.primaryVelocity! != 0) {
                            Map<String, dynamic> jsonInputData = {
                              'email': crypto.encrypt(_email.text),
                              "url": crypto.encrypt(
                                  AppRouteConstants.dashboardRouteName +
                                      ("Room/" +
                                          (open == 0
                                              ? "QuickSplit"
                                              : (open == 1
                                                  ? "Active"
                                                  : "Closed")))),
                              "creationDate":
                                  crypto.encrypt(DateTime.now().toString())
                            };
                            pushAnalytics(context, jsonInputData, _token);
                          }
                        },
                        child: SizedBox(
                          height: (MediaQuery.of(context).size.height - 220),
                          child: open == 0
                              ? quickSplitData.value.isEmpty
                                  ? (quickSplitDataFetched
                                      ? Scrollbar(
                                          radius: Radius.circular(10.0),
                                          thickness: 5.5,
                                          child: SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Center(
                                              child: Text(
                                                "No Transaction Found!",
                                                style: TextStyle(
                                                  fontSize: 25,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Shimmer.fromColors(
                                            baseColor:
                                                Theme.of(context).cardColor,
                                            highlightColor:
                                                Theme.of(context).primaryColor,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 8,
                                                ),
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height -
                                                      250,
                                                  child: ListView.separated(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    itemCount: 16,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            SizedBox(
                                                      height: 30,
                                                    ),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Container(
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                          height: 140,
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    8.0,
                                                                    8.0,
                                                                    0,
                                                                    8.0),
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                      flex: 1,
                                                                      child: SizedBox(
                                                                          width: MediaQuery.of(context).size.width * 0.95,
                                                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                            Container(
                                                                              width: 200,
                                                                              height: 24.0,
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  border: Border.all(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                            ),
                                                                            SizedBox(height: 10),
                                                                            Container(
                                                                              width: 150,
                                                                              height: 20.0,
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  border: Border.all(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                            ),
                                                                            SizedBox(height: 10),
                                                                            Container(
                                                                              width: 250,
                                                                              height: 20.0,
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  border: Border.all(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                            ),
                                                                            SizedBox(height: 10),
                                                                            Container(
                                                                              width: 220,
                                                                              height: 20.0,
                                                                              decoration: BoxDecoration(
                                                                                  color: Colors.white,
                                                                                  border: Border.all(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                  borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                            ),
                                                                          ]))),
                                                                  Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                            flex:
                                                                                0,
                                                                            child:
                                                                                SizedBox(
                                                                              width: MediaQuery.of(context).size.width * 0.25,
                                                                              child: Column(
                                                                                children: [
                                                                                  Container(
                                                                                    width: 90,
                                                                                    height: 18.0,
                                                                                    decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        border: Border.all(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: 4,
                                                                                  ),
                                                                                  Container(
                                                                                    width: 110,
                                                                                    height: 18.0,
                                                                                    decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        border: Border.all(
                                                                                          color: Colors.white,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.all(Radius.circular(20))),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ))
                                                                      ]),
                                                                ]),
                                                          ));
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                  : Scrollbar(
                                      radius: Radius.circular(10.0),
                                      thickness: 5.5,
                                      child: QuickSplit(
                                        RoomData: quickSplitData,
                                        email: _email.text,
                                        hasMore: quickSplitDataHasMore,
                                        token: _token,
                                        expenseCategory: expenseCategory,
                                        subCategory: subCategory,
                                      ))
                              : open == 1
                                  ? RoomDataO.value.isEmpty
                                      ? activeRoomDataFetched
                                          ? Scrollbar(
                                              radius: Radius.circular(10.0),
                                              thickness: 5.5,
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Text(
                                                    "No Live Room Found!",
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: Shimmer.fromColors(
                                                  baseColor: Theme.of(context)
                                                      .cardColor,
                                                  highlightColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  child:
                                                      splitRoomShimmerWidget()))
                                      : Scrollbar(
                                          radius: Radius.circular(10.0),
                                          thickness: 5.5,
                                          child: RoomWidget(
                                            RoomData: RoomDataO,
                                            ClosedRoomData: RoomDataC,
                                            email: _email.text,
                                            flag: false,
                                            hasMore: activeRoomHasMore,
                                            roomType: 1,
                                            token: _token,
                                            liveRoomType:
                                                filterliveRoomCategoryIndex
                                                            .length ==
                                                        2
                                                    ? 3
                                                    : (filterliveRoomCategoryIndex
                                                            .contains(0)
                                                        ? 1
                                                        : 2),
                                            membersData: membersData,
                                          ))
                                  : (RoomDataC.value.isEmpty
                                      ? inActiveRoomDataFetched
                                          ? Scrollbar(
                                              radius: Radius.circular(10.0),
                                              thickness: 5.5,
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Text(
                                                    "No Closed Room Found!",
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height,
                                              child: Shimmer.fromColors(
                                                  baseColor: Theme.of(context)
                                                      .cardColor,
                                                  highlightColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  child:
                                                      splitRoomShimmerWidget()))
                                      : Scrollbar(
                                          radius: Radius.circular(10.0),
                                          thickness: 5.5,
                                          child: RoomWidget(
                                            RoomData: RoomDataC,
                                            ClosedRoomData: RoomDataC,
                                            email: _email.text,
                                            flag: false,
                                            hasMore: inActiveRoomHasMore,
                                            roomType: 0,
                                            token: _token,
                                            liveRoomType: 0,
                                            membersData: membersData,
                                          ))),
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
      return PersonalExpenseDashBoard(
        expenseCategory: expenseCategory,
        subCategory: subCategory,
      );
    } else if (dash == 3) {
      return LendDenDashboard();
    } else {
      return Analysis(
        RoomDataC: RoomDataC.value,
        RoomDataO: RoomDataO.value,
        expenseCategory: expenseCategory,
        subCategory: subCategory,
      );
    }
  }

  bool isRefreshVisible() {
    if (open == 0 && quickSplitDataFetched) {
      return quickSplitData.value.isEmpty;
    } else if (open == 1 && activeRoomDataFetched) {
      return RoomDataO.value.isEmpty;
    } else if (open == 2 && inActiveRoomDataFetched) {
      return RoomDataC.value.isEmpty;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final internetConnProvider =
        Provider.of<InternetconnectivityProvider>(context, listen: false);
    return importantUpdate
        ? updateWidget(context, updateData)
        : PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
              if (dash == 0 && searchTrigger) {
                if (this.mounted) {
                  setState(() {
                    searchTrigger = false;
                  });
                }
              } else {
                SystemNavigator.pop();
              }
            },
            child: Scaffold(
                key: _scaffoldKey,
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
                                  if (this.mounted) {
                                    setState(() {
                                      _search.setText(s);
                                    });
                                  }
                                  if (open == 0) {
                                    SearchAndFilterQuickSplitData();
                                  } else {
                                    SearchAndFilterRoomData();
                                  }
                                },
                              )
                            : Text(
                                "Settle Now",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                        actions: [
                          IconButton(
                              onPressed: () {
                                if (this.mounted) {
                                  setState(() {
                                    _search.setText("");
                                    searchTrigger = !searchTrigger;
                                    roomStatusIndex = 0;
                                    dateRange = DateTimeRange(
                                        start: new DateTime(2018, 1),
                                        end: DateTime.now());
                                  });
                                }
                                if (open == 0) {
                                  SearchAndFilterQuickSplitData();
                                } else {
                                  SearchAndFilterRoomData();
                                }
                              },
                              icon: Icon(
                                Icons.search,
                                color: themeProvider.darkTheme
                                    ? Colors.white
                                    : Colors.black,
                              )),
                          (open > 0 || searchTrigger)
                              ? IconButton(
                                  onPressed: () {
                                    if (searchTrigger) {
                                      buildFilterDialog(context);
                                    } else {
                                      buildLiveFilterDialog(context);
                                    }
                                  },
                                  icon: Icon(
                                    filterliveRoomCategoryIndex.length != 2
                                        ? Icons.filter_alt_off
                                        : Icons.filter_alt_outlined,
                                    color: themeProvider.darkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ))
                              : SizedBox()
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
                            ? AppBar(
                                title: Text(
                                  "Personal Expense",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            : (dash == 3
                                ? AppBar(
                                    title: Text(
                                      "Len-Den",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : AppBar(
                                    title: Text(
                                      "Analysis",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )))),
                body: chooseFromBottomNavigator(dash),
                bottomNavigationBar: internetConnProvider.isAlertSet
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          color: internetConnProvider.isDeviceConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                        height: 40,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                              child: Text(
                            internetConnProvider.isDeviceConnected
                                ? "You are connected to Internet"
                                : "You aren't connected to Internet",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          )),
                        ),
                      )
                    : BottomNavigationBar(
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: Theme.of(context).primaryColor,
                        unselectedItemColor: Colors.grey,
                        currentIndex: dash,
                        onTap: (index) {
                          if (dash != index && index <= 1) {
                            Map<String, dynamic> jsonInputData = {
                              'email': crypto.encrypt(_email.text),
                              "url": crypto.encrypt(AppRouteConstants
                                      .dashboardRouteName +
                                  (index == 1
                                      ? ("Request/" +
                                          (requestType ? "Receive" : "Sent"))
                                      : ("Room/" +
                                          (open == 0
                                              ? "QuickSplit"
                                              : (open == 1
                                                  ? "Active"
                                                  : "Closed"))))),
                              "creationDate":
                                  crypto.encrypt(DateTime.now().toString())
                            };
                            pushAnalytics(context, jsonInputData, _token);
                          }
                          if (this.mounted) {
                            setState(() {
                              dash = index;
                            });
                          }
                        },
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
                                Icons.notifications_outlined,
                                size: 27,
                              ),
                              RoomRequest.isNotEmpty
                                  ? Positioned(
                                      right: 0,
                                      child: new Container(
                                        padding: EdgeInsets.all(1),
                                        decoration: new BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                              Icons.assessment_outlined,
                              size: 27,
                            ),
                            label: "",
                          )
                        ],
                      ),
                drawer: Drawer(
                  child: ListView(
                    children: [
                      _name.text.length == 0
                          ? Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : UserAccountsDrawerHeader(
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .drawerTheme
                                      .backgroundColor),
                              margin: EdgeInsets.all(0),
                              currentAccountPicture: Stack(
                                children: [
                                  isGoogle
                                      ? CachedNetworkImage(
                                          httpHeaders: {
                                            'Access-Control-Allow-Origin': '*'
                                          },
                                          imageUrl: (_currentUser != null
                                              ? _currentUser!.photoUrl
                                                  .toString()
                                              : addCorsinImage(
                                                  global.unknown_avatar_id)),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              Container(
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
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            width: 120.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        )
                                      : CachedNetworkImage(
                                          httpHeaders: {
                                            'Access-Control-Allow-Origin': '*'
                                          },
                                          imageUrl: addCorsinImage(
                                              (_profilePicID.length == 0
                                                  ? global.unknown_avatar_id
                                                  : _profilePicID)),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              Container(
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
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            width: 120.0,
                                            height: 120.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              accountName: Text(_name.text,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                              accountEmail: Text(_email.text,
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white)),
                            ),
                      ListTile(
                        onTap: () {
                          if (this.mounted) {
                            context.push(AppRouteConstants.profileRouteName);
                          }
                        },
                        leading: Icon(
                          Icons.person_2_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        title: Text(
                          "Profile",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      kIsWeb || Platform.isIOS
                          ? SizedBox()
                          : ListTile(
                              onTap: () async {
                                if (this.mounted) {
                                  context.push(
                                    AppRouteConstants.bankTransactionRouteName,
                                  );

                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                }
                              },
                              leading: Icon(
                                Icons.payments,
                                color: Colors.white,
                                size: 22,
                              ),
                              title: Text(
                                "Bank Transactions",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text("Beta",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.white)),
                                  )),
                            ),
                      kIsWeb
                          ? SizedBox()
                          : ListTile(
                              onTap: () {
                                if (this.mounted) {
                                  context.push(AppRouteConstants
                                      .schduleNotificationRouteName);
                                }
                              },
                              leading: Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              title: Text(
                                "Reminder",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                      kIsWeb || isContactPermissionGranted
                          ? SizedBox()
                          : ListTile(
                              onTap: () async {
                                isContactPermissionGranted = await context.push(
                                    AppRouteConstants.inviteFriendsRouteName,
                                    extra: {"firstTime": false}) as bool;
                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                              leading: Icon(
                                Icons.import_contacts_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              title: Text(
                                "Import Contacts",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                      kIsWeb || isNotificationPremissionProvided
                          ? SizedBox()
                          : ListTile(
                              onTap: () async {
                                isNotificationPremissionProvided = await context
                                    .push(
                                        AppRouteConstants
                                            .notificationPermissionRouteName,
                                        extra: {"firstTime": false}) as bool;
                                if (this.mounted) {
                                  setState(() {});
                                }
                              },
                              leading: Icon(
                                Icons.notifications_active_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              title: Text(
                                "Get Notified",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
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
                            onPressed: () async {
                              final provider = Provider.of<ThemeProvider>(
                                  context,
                                  listen: false);
                              provider.toggleTheme(!themeProvider.darkTheme);
                              setBoolPrefs(
                                  'darkTheme', themeProvider.darkTheme);
                            },
                            icon: Icon(
                              Icons.brightness_2,
                              color: themeProvider.darkTheme
                                  ? Colors.black87
                                  : Colors.white,
                              size: 22,
                            )),
                      ),
                      kIsWeb
                          ? SizedBox()
                          : ListTile(
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
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                      ListTile(
                        onTap: () {
                          if (this.mounted) {
                            context.push(AppRouteConstants.aboutRouteName);
                          }
                        },
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
                        onTap: () {
                          if (this.mounted) {
                            context.push(AppRouteConstants.contactUsRouteName);
                          }
                        },
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
                      kIsWeb || Platform.isIOS
                          ? SizedBox()
                          : ListTile(
                              onTap: rateUs,
                              leading: Icon(
                                Icons.star_border_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              title: Text(
                                "Rate Us",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                      ListTile(
                        onTap: () async {
                          if (this.mounted) {
                            await logout();
                          }
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
                              "Version " + appVersion,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                            InkWell(
                              onTap: () async {
                                launchUrl(
                                  Uri.parse(
                                      "https://settlenow.in/privacy-policy"),
                                  mode: LaunchMode.inAppWebView,
                                  webViewConfiguration:
                                      const WebViewConfiguration(
                                          enableJavaScript: true),
                                );
                              },
                              child: Text(
                                "Privacy Policy",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      isItAndroidDevice
                          ? InkWell(
                              onTap: () async {
                                launchUrl(
                                  Uri.parse(
                                      "https://play.google.com/store/apps/details?id=com.rohit.settlenow"),
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: Image(
                                width: 250,
                                height: 80,
                                image:
                                    AssetImage('assets/Images/play_store.png'),
                              ))
                          : SizedBox()
                    ],
                  ),
                ),
                floatingActionButton: dash == 0
                    ? (searchTrigger
                        ? null
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              isRefreshVisible()
                                  ? FloatingActionButton(
                                      onPressed: () async {
                                        _executeParallelRefresh();
                                      },
                                      child: Icon(
                                        Icons.refresh_outlined,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      backgroundColor:
                                          Theme.of(context).cardColor,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 3,
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.7)),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                height: isRefreshVisible() ? 6 : 0,
                              ),
                              FloatingActionButton(
                                onPressed: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) {
                                      return Padding(
                                        padding:
                                            MediaQuery.of(context).viewInsets,
                                        child: SizedBox(
                                          height: open == 0 ? 60 : 120,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                ListTile(
                                                  leading: Icon(
                                                    Icons.add,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  title: Text(open == 0
                                                      ? "Create Expense"
                                                      : "Create Room"),
                                                  onTap: () {
                                                    if (open == 0) {
                                                      aditionalMembers.clear();
                                                      addExpenseTo.clear();
                                                      AddQuickSplitExpense();
                                                    } else {
                                                      showModalBottomSheet<
                                                          void>(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        builder: (BuildContext
                                                            context) {
                                                          return Padding(
                                                            padding:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .viewInsets,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <Widget>[
                                                                Form(
                                                                  key:
                                                                      _CformKey,
                                                                  child:
                                                                      TextFormField(
                                                                    controller:
                                                                        _NRoom,
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .text,
                                                                    maxLength:
                                                                        70,
                                                                    maxLines: 1,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                    autocorrect:
                                                                        false,
                                                                    validator:
                                                                        (value) {
                                                                      RegExp
                                                                          validateText =
                                                                          RegExp(
                                                                              r'\b[\w]{4,}\b');
                                                                      if (!validateText
                                                                          .hasMatch(
                                                                              _NRoom.text)) {
                                                                        return open ==
                                                                                0
                                                                            ? "Enter Valid Purpose"
                                                                            : "Enter Valid Room Name";
                                                                      }
                                                                      return null;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      counterText:
                                                                          "",
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      hintText: open ==
                                                                              0
                                                                          ? "Enter Valid Purpose"
                                                                          : "Enter Room Name",
                                                                      errorStyle:
                                                                          TextStyle(
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
                                                                  child:
                                                                      OutlinedButton(
                                                                    child: Text(
                                                                      "Create",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color: themeProvider.isDarkTheme
                                                                              ? Colors.white
                                                                              : Colors.black),
                                                                    ),
                                                                    style: OutlinedButton
                                                                        .styleFrom(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      side: BorderSide(
                                                                          color:
                                                                              Theme.of(context).primaryColor),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      if (_CformKey
                                                                          .currentState!
                                                                          .validate()) {
                                                                        SendingData(
                                                                            true,
                                                                            context);
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
                                                    }
                                                  },
                                                ),
                                                open == 0
                                                    ? SizedBox()
                                                    : ListTile(
                                                        leading: Icon(
                                                          Icons.edit,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        title:
                                                            Text("Join Room"),
                                                        onTap: () {
                                                          showModalBottomSheet<
                                                              void>(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Padding(
                                                                padding: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: <Widget>[
                                                                    Form(
                                                                      key:
                                                                          _JformKey,
                                                                      child:
                                                                          TextFormField(
                                                                        controller:
                                                                            _NRoom,
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        maxLength:
                                                                            7,
                                                                        maxLines:
                                                                            1,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18),
                                                                        autocorrect:
                                                                            false,
                                                                        validator:
                                                                            (value) {
                                                                          RegExp
                                                                              validateText =
                                                                              RegExp(r'\b[\w]{7}\b');
                                                                          if (!validateText
                                                                              .hasMatch(_NRoom.text)) {
                                                                            return open == 0
                                                                                ? "Enter Valid Transcation Key"
                                                                                : "Enter Valid Room Key";
                                                                          }
                                                                          return null;
                                                                        },
                                                                        decoration:
                                                                            InputDecoration(
                                                                          counterText:
                                                                              "",
                                                                          contentPadding:
                                                                              EdgeInsets.all(8.0),
                                                                          hintText: open == 0
                                                                              ? "Enter Valid Transaction Key"
                                                                              : "Enter Room Key",
                                                                          labelText: open == 0
                                                                              ? "Transaction Key"
                                                                              : "Room Key",
                                                                          errorStyle:
                                                                              TextStyle(fontSize: 15),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          15,
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          43,
                                                                      width:
                                                                          100,
                                                                      child: OutlinedButton(
                                                                          child: Text(
                                                                            "Join",
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                          ),
                                                                          style: OutlinedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(10.0),
                                                                            ),
                                                                            side:
                                                                                BorderSide(color: Theme.of(context).primaryColor),
                                                                          ),
                                                                          onPressed: () {
                                                                            if (_JformKey.currentState!.validate()) {
                                                                              SendingData(false, context);
                                                                            }
                                                                          }),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
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
                                child: Icon(
                                  Icons.add,
                                  color: Theme.of(context).primaryColor,
                                ),
                                backgroundColor: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 3,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.7)),
                                    borderRadius: BorderRadius.circular(20)),
                              ),
                            ],
                          ))
                    : null),
          );
  }
}

class QuickSplit extends StatefulWidget {
  final ValueNotifier<List<QuickSplitEach>> RoomData;
  final String email;
  final String token;
  final int fetchSize = 10;
  final ValueNotifier<bool> hasMore;
  final List<dynamic> expenseCategory;
  final List<List<dynamic>> subCategory;

  const QuickSplit(
      {Key? key,
      required this.RoomData,
      required this.email,
      required this.token,
      required this.hasMore,
      required this.expenseCategory,
      required this.subCategory})
      : super(key: key);

  @override
  State<QuickSplit> createState() => _QuickSplitState();
}

class _QuickSplitState extends State<QuickSplit> {
  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  AutoScrollController controller = AutoScrollController();
  int roomExpenseCategoryIndex = -1;
  int roomsubExpenseCategoryIndex = -1;

  updateExpenseManual(List<dynamic> memberExpense, String id, int index,
      int roomExpenseCategoryIndex, int roomsubExpenseCategoryIndex) async {
    try {
      Map<String, String> splitMember = {};
      for (int i = 0; i < memberExpense.length; i++) {
        if (crypto.decrypt(memberExpense[i]['userData']['email']).isNotEmpty) {
          splitMember[crypto.decrypt(memberExpense[i]['userData']['email'])] =
              crypto.decrypt(memberExpense[i]['amount']);
        } else {
          splitMember[crypto.decrypt(memberExpense[i]['userData']['name'])] =
              crypto.decrypt(memberExpense[i]['amount']);
        }
      }

      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'purpose': crypto.encrypt(_purpose.text),
        'id': crypto.encrypt(id),
        'split': crypto.encrypt(splitMember.toString()),
        'type':
            crypto.encrypt(widget.expenseCategory[roomExpenseCategoryIndex]),
        'subType': crypto.encrypt((roomsubExpenseCategoryIndex != -1 &&
                widget.subCategory[roomExpenseCategoryIndex].length > 0
            ? widget.subCategory[roomExpenseCategoryIndex]
                [roomsubExpenseCategoryIndex]
            : "None"))
      };

      final response = await createHTTPreq(
          'quickSplit', http.put, widget.token, jsonInputData, context);

      var updateMessage = jsonDecode(response.body);
      if (response.statusCode == 200) {
        widget.RoomData.value[index] =
            QuickSplitEach.fromJson(updateMessage["data"]);
        if (this.mounted) {
          setState(() {});
        }
      }
      showToast(context, crypto.decrypt(updateMessage["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->updateExpenseManual"]);
      }
    }
  }

  Widget splitManuallyWidget(
      BuildContext context,
      List<dynamic> memberExpenseOG,
      String purpose,
      String id,
      int index,
      int roomExpenseCategory,
      int roomsubExpenseCategory) {
    List<dynamic> memberExpense = memberExpenseOG.toList();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    GlobalKey<FormState> _manualSplitKey_2 = GlobalKey<FormState>();
    _purpose.text = purpose;
    List<TextEditingController> amountController = [];
    for (int i = 0; i < memberExpense.length; i++) {
      amountController.add(TextEditingController(
          text: crypto.decrypt(memberExpense[i]['amount'])));
    }
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: SizedBox(
              width: kIsWeb
                  ? max(MediaQuery.of(context).size.width * 0.5,
                      min(400, MediaQuery.of(context).size.width * 0.95))
                  : MediaQuery.of(context).size.width * 0.95,
              child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                        key: _manualSplitKey_2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _purpose,
                              keyboardType: TextInputType.text,
                              maxLength: 1000,
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
                                counterText: "",
                                errorStyle: TextStyle(fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 70,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.expenseCategory.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return SizedBox(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: InkWell(
                                        child: Card(
                                          color: Theme.of(context)
                                              .dialogBackgroundColor,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color:
                                                    roomExpenseCategory == index
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .cardColor),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                              child: Text(
                                                widget.expenseCategory[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          if (this.mounted) {
                                            setState(
                                              () {
                                                roomExpenseCategory = index;
                                                roomsubExpenseCategory = 0;
                                              },
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            widget.subCategory[roomExpenseCategory].length > 0
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.96,
                                    height: 70,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: widget
                                          .subCategory[roomExpenseCategory]
                                          .length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return SizedBox(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              child: Card(
                                                color: Theme.of(context)
                                                    .dialogBackgroundColor,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: (index ==
                                                              roomsubExpenseCategory
                                                          ? Theme.of(context)
                                                              .primaryColor
                                                          : Theme.of(context)
                                                              .cardColor)),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Center(
                                                    child: InkWell(
                                                      child: Text(
                                                        widget.subCategory[
                                                                roomExpenseCategory]
                                                            [index],
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                if (this.mounted) {
                                                  setState(
                                                    () {
                                                      roomsubExpenseCategory =
                                                          index;
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: min(75.0 * memberExpense.length,
                                  MediaQuery.of(context).size.height * 0.8),
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: memberExpense.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(11.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CachedNetworkImage(
                                              httpHeaders: {
                                                'Access-Control-Allow-Origin':
                                                    '*'
                                              },
                                              imageUrl: addCorsinImage(crypto
                                                          .decrypt(memberExpense[
                                                                      index]
                                                                  ['userData']
                                                              ['pic'])
                                                          .length ==
                                                      0
                                                  ? global.unknown_avatar_id
                                                  : crypto.decrypt(
                                                      memberExpense[index]
                                                          ['userData']['pic'])),
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      CircularProgressIndicator(
                                                          value:
                                                              downloadProgress
                                                                  .progress),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/Images/unknown.jpeg'),
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                width: 40.0,
                                                height: 40.0,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6,
                                            ),
                                            InkWell(
                                              onTap: () => showToast(
                                                  context,
                                                  crypto.decrypt(
                                                      memberExpense[index]
                                                          ['userData']['name']),
                                                  Icons.person_outlined),
                                              child: SizedBox(
                                                width: 130,
                                                child: Text(
                                                  crypto.decrypt(
                                                      memberExpense[index]
                                                          ['userData']['name']),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Rs",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            SizedBox(
                                              width: 50,
                                              child: TextFormField(
                                                controller:
                                                    amountController[index],
                                                keyboardType:
                                                    TextInputType.number,
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontSize: 15),
                                                autocorrect: false,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.all(8.0),
                                                  counterText: "",
                                                  errorStyle: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                validator: (value) {
                                                  if (crypto.decrypt(
                                                          memberExpense[index]
                                                                  ['userData']
                                                              ['email']) ==
                                                      widget.email) {
                                                    if (amountController[index]
                                                            .text ==
                                                        "0") {
                                                      memberExpense[index]
                                                              ['amount'] =
                                                          crypto.encrypt(
                                                              (double.parse(amountController[
                                                                              index]
                                                                          .text) *
                                                                      100 /
                                                                      100)
                                                                  .toString());
                                                      return null;
                                                    }
                                                  }
                                                  RegExp validateText = RegExp(
                                                      r"^[1-9]\d*(\.\d+)?$");
                                                  if (!validateText.hasMatch(
                                                      amountController[index]
                                                          .text)) {
                                                    return "";
                                                  } else {
                                                    memberExpense[index]
                                                            ['amount'] =
                                                        crypto.encrypt((double.parse(
                                                                    amountController[
                                                                            index]
                                                                        .text) *
                                                                100 /
                                                                100)
                                                            .toString());
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 43,
                              width: 100,
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  child: Text(
                                    "Close",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: themeProvider.isDarkTheme
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  onPressed: () {
                                    if (this.mounted) {
                                      context.pop();
                                    }
                                  }),
                            ),
                            SizedBox(
                              height: 43,
                              width: 120,
                              child: OutlinedButton(
                                  child: Text(
                                    "Update",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: themeProvider.isDarkTheme
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onPressed: () async {
                                    if (_manualSplitKey_2.currentState!
                                        .validate()) {
                                      if (this.mounted) {
                                        buildShowDialog(context);
                                      }
                                      await updateExpenseManual(
                                          memberExpense,
                                          id,
                                          index,
                                          roomExpenseCategory,
                                          roomsubExpenseCategory);
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                    } else {
                                      showToast(context, "Invalid Amount",
                                          Icons.warning_outlined);
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ))));
    });
  }

  settleThisTransaction(String objId, int index) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'id': crypto.encrypt(objId)
      };

      final response = await createHTTPreq(
          'quickSplit/settle', http.post, widget.token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        widget.RoomData.value[index] = QuickSplitEach.fromJson(data["data"]);
        if (this.mounted) {
          setState(() {});
        }
      }
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error",
            info: ["DashBoard->settleThisTransaction"]);
      }
    }
    if (this.mounted) {
      context.pop();
    }
  }

  addToPersonalExpense(String objId) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'id': crypto.encrypt(objId)
      };

      final response = await createHTTPreq('quickSplit/personalExpense',
          http.post, widget.token, jsonInputData, context);

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->addToPersonalExpense"]);
      }
    }
    if (this.mounted) {
      context.pop();
    }
  }

  bool userInPartialExpense(List<dynamic> partialExpense, String email) {
    for (int i = 0; i < partialExpense.length; i++) {
      if (crypto.decrypt(partialExpense[i]['userData']['email']) == email) {
        return true;
      }
    }

    return false;
  }

  closeRoomWidget(BuildContext context, String id, int index) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: SingleChildScrollView(
            child: Container(
                width: kIsWeb
                    ? max(MediaQuery.of(context).size.width * 0.5,
                        min(400, MediaQuery.of(context).size.width))
                    : MediaQuery.of(context).size.width,
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
                            child: OutlinedButton(
                              onPressed: () {
                                if (this.mounted) {
                                  context.pop();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: Text(
                                "No",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                              onPressed: () async {
                                if (this.mounted) {
                                  buildShowDialog(context);
                                }
                                await settleThisTransaction(id, index);
                                if (this.mounted) {
                                  context.pop();
                                }
                                if (this.mounted) {
                                  context.pop();
                                }
                                if (this.mounted) {
                                  context.pop();
                                }
                              },
                              child: Text(
                                "Yes",
                                style: TextStyle(
                                    color: themeProvider.isDarkTheme
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ))));
  }

  Widget _buildPopupDialog(
      BuildContext context,
      String name,
      String date,
      String email,
      String id,
      String purpose,
      String amount,
      bool locked,
      List<dynamic> partialExpense,
      String type,
      String subType,
      bool isEdited,
      String lastModDate,
      int index,
      bool isActive,
      bool isUserClosed) {
    return StatefulBuilder(builder: (context, setState) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: SizedBox(
          width: kIsWeb
              ? max(MediaQuery.of(context).size.width * 0.5,
                  min(400, MediaQuery.of(context).size.width * 0.95))
              : MediaQuery.of(context).size.width * 0.95,
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
                      "Expense Detail",
                      style: TextStyle(fontSize: 23),
                    ),
                    widget.email == email && !locked
                        ? Row(
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    await deleteExpense(id, index);
                                  },
                                  icon: Icon(Icons.delete)),
                              IconButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            splitManuallyWidget(
                                                context,
                                                partialExpense,
                                                purpose,
                                                id,
                                                index,
                                                widget.expenseCategory
                                                    .indexOf(type),
                                                widget.subCategory[widget
                                                        .expenseCategory
                                                        .indexOf(type)]
                                                    .indexOf(subType)));
                                  },
                                  icon: Icon(Icons.edit)),
                            ],
                          )
                        : SizedBox()
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  _purpose.text,
                  style: TextStyle(fontSize: 22),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        partialExpense.isEmpty
                            ? Text(
                                name,
                                style: TextStyle(fontSize: 20),
                              )
                            : SizedBox(),
                        partialExpense.isEmpty
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox(),
                        Text(
                          type,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    Text(
                      "₹ " + _amount.text,
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Spent On: " + date,
                  style: TextStyle(fontSize: 19),
                ),
                isEdited
                    ? SizedBox(
                        height: 10,
                      )
                    : SizedBox(),
                isEdited
                    ? Text(
                        "Modified: " + lastModDate,
                        style: TextStyle(fontSize: 19),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                partialExpense.isEmpty
                    ? SizedBox()
                    : SizedBox(
                        height: 20,
                      ),
                partialExpense.isEmpty
                    ? SizedBox()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width - 65,
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: partialExpense.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 1.0,
                              shadowColor: Theme.of(context).primaryColor,
                              color: Theme.of(context).dialogBackgroundColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: !partialExpense[index]['isSettled']
                                        ? Theme.of(context)
                                            .primaryColor
                                            .withAlpha(80)
                                        : Colors.redAccent),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 8, 10, 5),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CachedNetworkImage(
                                          httpHeaders: {
                                            'Access-Control-Allow-Origin': '*'
                                          },
                                          imageUrl: addCorsinImage(crypto
                                                      .decrypt(
                                                          partialExpense[index]
                                                                  ['userData']
                                                              ['pic'])
                                                      .length ==
                                                  0
                                              ? global.unknown_avatar_id
                                              : crypto.decrypt(
                                                  partialExpense[index]
                                                      ['userData']['pic'])),
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: 35.0,
                                            height: 35.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/Images/unknown.jpeg'),
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            width: 35.0,
                                            height: 35.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 6,
                                        ),
                                        InkWell(
                                          onTap: () => showToast(
                                              context,
                                              crypto.decrypt(
                                                  partialExpense[index]
                                                      ['userData']['name']),
                                              Icons.person_outline_rounded),
                                          child: SizedBox(
                                            width: crypto
                                                        .decrypt(partialExpense[
                                                                    index]
                                                                ['userData']
                                                            ['name'])
                                                        .length <
                                                    12
                                                ? null
                                                : 100,
                                            child: Text(
                                              crypto.decrypt(
                                                  partialExpense[index]
                                                      ['userData']['name']),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "₹ " +
                                          crypto.decrypt(
                                              partialExpense[index]['amount']),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(
                  height: 25,
                ),
                (isActive && !isUserClosed)
                    ? SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width * 0.95 - 25,
                        child: OutlinedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) =>
                                  closeRoomWidget(context, id, index),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            side: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          child: Text(
                            email == widget.email
                                ? "Amount Settled?"
                                : "Settle Amount",
                            style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkTheme
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      )
                    : SizedBox(),
                (isActive && !isUserClosed)
                    ? SizedBox(
                        height: 12,
                      )
                    : SizedBox(),
                SizedBox(
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.95 - 25,
                  child: OutlinedButton(
                    onPressed: () async {
                      if (this.mounted) {
                        buildShowDialog(context);
                      }
                      await addToPersonalExpense(id);
                      if (this.mounted) {
                        context.pop();
                      }
                      if (this.mounted) {
                        context.pop();
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      "Add To Personal Expense",
                      style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                SizedBox(
                  height: 45,
                  width: MediaQuery.of(context).size.width * 0.95 - 25,
                  child: OutlinedButton(
                    child: Text(
                      "Close",
                      style: TextStyle(
                          fontSize: 16,
                          color: themeProvider.isDarkTheme
                              ? Colors.white
                              : Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () {
                      if (this.mounted) {
                        context.pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  deleteExpense(String id, int index) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'id': crypto.encrypt(id),
      };

      final response = await createHTTPreq(
          'quickSplit', http.delete, widget.token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        widget.RoomData.value.removeAt(index);
        if (this.mounted) {
          setState(() {});
        }
        if (this.mounted) {
          context.pop();
        }
      }
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->deleteExpense"]);
      }
    }
    if (this.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
                height: 5,
              ),
          controller: controller,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: widget.RoomData.value.length,
          itemBuilder: (BuildContext context, int index) {
            bool isRoomOwnerClosed = false;
            List<dynamic> isInSplitAmount =
                widget.RoomData.value[index].splitBetween.where((element) {
              if (crypto.decrypt(element['userData']['email']) ==
                  widget.email) {
                isRoomOwnerClosed = element['isSettled'];
                return true;
              }
              return false;
            }).toList();
            return AutoScrollTag(
              controller: controller,
              index: index,
              key: ValueKey(index),
              child: InkWell(
                onTap: () {
                  _purpose.text = widget.RoomData.value[index].purpose;
                  _amount.text = widget.RoomData.value[index].amount.toString();
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => _buildPopupDialog(
                          context,
                          widget.RoomData.value[index].owner,
                          widget.RoomData.value[index].date,
                          widget.RoomData.value[index].email,
                          widget.RoomData.value[index].roomID,
                          widget.RoomData.value[index].purpose,
                          widget.RoomData.value[index].amount.toString(),
                          widget.RoomData.value[index].isClosedAny,
                          widget.RoomData.value[index].splitBetween,
                          widget.RoomData.value[index].type,
                          widget.RoomData.value[index].subType,
                          widget.RoomData.value[index].isEdited,
                          widget.RoomData.value[index].lastModDate,
                          index,
                          widget.RoomData.value[index].active,
                          isRoomOwnerClosed));
                },
                child: SizedBox(
                    height: 150,
                    child: Card(
                      elevation: 1.0,
                      shadowColor: Theme.of(context).primaryColor,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: (widget.RoomData.value[index].active &&
                                    !isRoomOwnerClosed)
                                ? Theme.of(context).primaryColor.withAlpha(80)
                                : Colors.redAccent),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 8.0, 0, 8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.RoomData.value[index].purpose,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Opacity(
                                          opacity: 0.8,
                                          child: Text(
                                            widget.RoomData.value[index].owner,
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Opacity(
                                          opacity: 0.8,
                                          child: InkWell(
                                            onTap: () => showToast(
                                                context,
                                                widget.RoomData.value[index]
                                                        .type +
                                                    (widget
                                                                .RoomData
                                                                .value[index]
                                                                .subType
                                                                .length >
                                                            0
                                                        ? ' (${widget.RoomData.value[index].subType})'
                                                        : ""),
                                                Icons.check_outlined),
                                            child: Text(
                                              "Category: " +
                                                  widget.RoomData.value[index]
                                                      .type +
                                                  (widget.RoomData.value[index]
                                                              .subType.length >
                                                          0
                                                      ? ' (${widget.RoomData.value[index].subType})'
                                                      : ""),
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Opacity(
                                          opacity: 0.8,
                                          child: Text(
                                            widget.RoomData.value[index].date,
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: (widget
                                            .RoomData.value[index].isEdited ||
                                        !(widget.RoomData.value[index].active &&
                                            !isRoomOwnerClosed))
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      widget.RoomData.value[index].isEdited
                                          ? Card(
                                              shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Text("Edited",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: themeProvider
                                                                .isDarkTheme
                                                            ? Colors.white
                                                            : Colors.black)),
                                              ))
                                          : SizedBox(),
                                      !(widget.RoomData.value[index].active &&
                                              !isRoomOwnerClosed)
                                          ? Icon(
                                              Icons.lock_outline,
                                              size: 24,
                                            )
                                          : SizedBox()
                                    ],
                                  ),
                                  (widget.RoomData.value[index].isEdited ||
                                          !(widget.RoomData.value[index]
                                                  .active &&
                                              !isRoomOwnerClosed))
                                      ? SizedBox(
                                          height: 8,
                                        )
                                      : SizedBox(),
                                  Expanded(
                                    flex: 0,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      child: Column(
                                        children: [
                                          Text(
                                            "₹ " +
                                                commaSeperator(widget.RoomData
                                                    .value[index].amount
                                                    .toString()),
                                            style: const TextStyle(
                                              fontSize: 19,
                                            ),
                                          ),
                                          Text(
                                            "(₹ " +
                                                crypto.decrypt(
                                                    isInSplitAmount[0]
                                                        ['amount']) +
                                                ")",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    )),
              ),
            );
          }),
    );
  }
}

class RoomWidget extends StatefulWidget {
  final ValueNotifier<List<RoomEach>> RoomData;
  final ValueNotifier<List<RoomEach>> ClosedRoomData;
  final String email;
  final bool flag;
  final String token;
  final ValueNotifier<Map<String, List<dynamic>>> membersData;
  final int fetchSize = 10;
  final int roomType;
  final ValueNotifier<bool> hasMore;
  final int liveRoomType;

  RoomWidget(
      {Key? key,
      required this.RoomData,
      required this.ClosedRoomData,
      required this.email,
      required this.flag,
      required this.token,
      required this.membersData,
      required this.roomType,
      required this.hasMore,
      required this.liveRoomType})
      : super(key: key);

  @override
  State<RoomWidget> createState() => _RoomWidgetState();
}

class _RoomWidgetState extends State<RoomWidget> {
  final scrollController = ScrollController();
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
  int indexLoading = -1;
  bool isDataLoading = false;
  bool fetchingData = false;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  Future _executeParallelRefresh(bool roomType) async {
    _extractEmail(roomType);
    getMembersData(roomType);
  }

  Future<void> getMembersData(bool roomType) async {
    try {
      Map<String, dynamic> jsonInputData = {
        "email": crypto.encrypt(widget.email),
        "roomType": roomType,
        'hasAlready': crypto.encrypt(widget.RoomData.value.length.toString())
      };

      final response = await createHTTPreq('room/allRoomMembers', http.post,
          widget.token, jsonInputData, context);

      if (response.statusCode == 200) {
        var tempData = jsonDecode(response.body)["data"];

        for (int i = 0; i < tempData.length; i++) {
          widget.membersData.value[tempData[i][0]] = tempData[i][1];
        }
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->getMembersData"]);
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> _extractEmail(bool roomType) async {
    isDataLoading = true;
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'roomType': roomType,
        'hasAlready': crypto.encrypt(widget.RoomData.value.length.toString())
      };

      final response = await createHTTPreq(
          'data', http.post, widget.token, jsonInputData, context);

      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body)['data'];
        widget.hasMore.value = jsonDecode(response.body)['hasMore'];

        for (int i = 0; i < list.length; i++) {
          widget.RoomData.value.add(RoomEach.fromJson(list[i]));
        }

        if (this.mounted) {
          setState(() {});
        }
      } else if (response.statusCode == 503) {
        while (context.canPop()) {
          if (this.mounted) {
            context.pop();
          }
        }
        context.push(AppRouteConstants.maintainRouteName);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->_extractEmail"]);
      }
    }

    fetchingData = false;
    isDataLoading = false;

    if (this.mounted) {
      context.pop();
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  void _scrollListener() async {
    if (widget.roomType <= 1) {
      if (widget.hasMore.value) {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          fetchingData = true;
          if (!isDataLoading) {
            if (widget.roomType == 0) {
              await _executeParallelRefresh(false);
            } else if (widget.roomType == 1) {
              await _executeParallelRefresh(true);
            }
          }
        }
      }

      if (this.mounted) {
        setState(() {});
      }
    }
  }

  Future updateRoom(BuildContext context, int index, String roomID) async {
    if (this.mounted) {
      setState(() {
        indexLoading = index;
      });
    }
    try {
      Map<String, dynamic> jsonInputData = {
        "email": crypto.encrypt(widget.email),
        "roomKey": crypto.encrypt(roomID)
      };

      final response = await createHTTPreq(
          'update/room', http.post, widget.token, jsonInputData, context);

      if (response.statusCode == 200) {
        RoomEach tempData =
            RoomEach.fromJson(jsonDecode(response.body)["data"]);
        if (tempData.active) {
          widget.RoomData.value[index] = tempData;
        } else {
          widget.RoomData.value.removeAt(index);
          widget.ClosedRoomData.value.insert(0, tempData);
        }
      } else {
        showToast(context, crypto.decrypt(jsonDecode(response.body)['Message']),
            Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        onException(context, err, stackTrace,
            reason: "Unknwon Error", info: ["DashBoard->updateRoom"]);
      }
    }

    indexLoading = -1;
    if (this.mounted) {
      setState(() {});
    }
  }

  _MoveToNext(BuildContext context, int index) async {
    final dataFrom = await context.push(AppRouteConstants.roomRouteName +
        "/" +
        widget.RoomData.value[index].roomKey) as bool;
    if (dataFrom) {
      await updateRoom(context, index, widget.RoomData.value[index].roomKey);
    }
  }

  Future<List<dynamic>> getMembers(int index) async {
    if (widget.membersData.value.isEmpty) {
      return [];
    }

    if (widget.membersData.value
        .containsKey(widget.RoomData.value[index].roomID)) {
      return widget.membersData.value[widget.RoomData.value[index].roomID]!;
    }

    try {
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(widget.email),
        'roomKey': crypto.encrypt(widget.RoomData.value[index].roomKey)
      };

      final response = await createHTTPreq('room/roomSplitMembers', http.post,
          widget.token, jsonInputData, context);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['data'];
      }
    } on Exception catch (err, stackTrace) {
      onException(context, err, stackTrace,
          reason: "Unknwon Error", info: ["DashBoard->sendContactData"]);
    }
    return [];
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
            side: BorderSide(
                color: widget.RoomData.value[index].done
                    ? Colors.red
                    : Theme.of(context).primaryColor.withAlpha(95)),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: indexLoading == index
              ? Shimmer.fromColors(
                  baseColor: Theme.of(context).cardColor,
                  highlightColor: Theme.of(context).primaryColor,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 250,
                            height: 18.0,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 28.0,
                                    height: 28.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'assets/Images/unknown.jpeg'),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  Positioned(
                                    left: 20,
                                    child: Container(
                                      width: 28.0,
                                      height: 28.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/Images/unknown.jpeg'),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 40,
                                    child: Container(
                                      width: 28.0,
                                      height: 28.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/Images/unknown.jpeg'),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 60,
                                    child: Container(
                                      width: 28.0,
                                      height: 28.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                'assets/Images/unknown.jpeg'),
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 14.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Container(
                                      width: 150,
                                      height: 14.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 150,
                                      height: 14.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Container(
                                      width: 150,
                                      height: 14.0,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                widget.RoomData.value[index].roomName,
                                textScaler: TextScaler.linear(1.0),
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 22,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            widget.RoomData.value[index].done
                                ? Icon(
                                    Icons.lock_outline,
                                    size: 26,
                                  )
                                : SizedBox()
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: FutureBuilder<List<dynamic>>(
                              builder: (context,
                                  AsyncSnapshot<List<dynamic>> snapshot) {
                                List<Widget> allImages = [];
                                if (snapshot.hasData) {
                                  int length = min(4, snapshot.data!.length);
                                  int leftMembers =
                                      (snapshot.data!.length - length + 1);
                                  for (int i = 0; i < length; i++) {
                                    if (i == 0) {
                                      allImages.add(CachedNetworkImage(
                                        httpHeaders: {
                                          'Access-Control-Allow-Origin': '*'
                                        },
                                        imageUrl: crypto
                                                    .decrypt(snapshot.data![i]
                                                        ['pic'])
                                                    .length ==
                                                0
                                            ? addCorsinImage(
                                                global.unknown_avatar_id)
                                            : addCorsinImage(crypto.decrypt(
                                                snapshot.data![i]['pic'])),
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          width: 28.0,
                                          height: 28.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'assets/Images/unknown.jpeg'),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          width: 28.0,
                                          height: 28.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      ));
                                    } else {
                                      allImages.add(Positioned(
                                          left: i * 20,
                                          child: CachedNetworkImage(
                                            httpHeaders: {
                                              'Access-Control-Allow-Origin': '*'
                                            },
                                            imageUrl: crypto
                                                        .decrypt(snapshot
                                                            .data![i]['pic'])
                                                        .length ==
                                                    0
                                                ? addCorsinImage(
                                                    global.unknown_avatar_id)
                                                : addCorsinImage(crypto.decrypt(
                                                    snapshot.data![i]['pic'])),
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                CircularProgressIndicator(
                                                    value: downloadProgress
                                                        .progress),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              width: 28.0,
                                              height: 28.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        'assets/Images/unknown.jpeg'),
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              width: 28.0,
                                              height: 28.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    image: imageProvider,
                                                    fit: BoxFit.cover),
                                              ),
                                            ),
                                          )));
                                    }
                                    if (leftMembers > 1) {
                                      allImages.add(Positioned(
                                          left: 60,
                                          child: Container(
                                            width: 28.0,
                                            height: 28.0,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: Stack(
                                              alignment: AlignmentDirectional
                                                  .centerStart,
                                              children: [
                                                Positioned(
                                                  left: leftMembers > 9
                                                      ? -0.2
                                                      : 2.5,
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                    size: 15,
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 6.5,
                                                  left:
                                                      leftMembers > 9 ? 11 : 15,
                                                  child: Text(
                                                    leftMembers.toString(),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )));
                                    }
                                  }
                                } else if (snapshot.hasError) {
                                  for (int i = 0;
                                      i < widget.RoomData.value[index].members;
                                      i++) {
                                    if (i == 0) {
                                      allImages.add(Container(
                                        width: 28.0,
                                        height: 28.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/Images/unknown.jpeg'),
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
                                                image: AssetImage(
                                                    'assets/Images/unknown.jpeg'),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      ));
                                    }
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  );
                                }
                                return Stack(
                                  children: allImages,
                                );
                              },
                              future: getMembers(index),
                            ),
                          ),
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
                                    "Members: " +
                                        widget.RoomData.value[index].members
                                            .toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      if (!kIsWeb) {
                                        await Share.share("Join " +
                                            widget.RoomData.value[index]
                                                .roomName +
                                            "\nRoom Key: " +
                                            widget
                                                .RoomData.value[index].roomKey +
                                            "\n" +
                                            widget.RoomData.value[index]
                                                .roomLink);
                                      }
                                    },
                                    onLongPress: () async {
                                      Clipboard.setData(ClipboardData(
                                          text: widget
                                              .RoomData.value[index].roomKey));
                                      showToast(context, "Join Key Copied",
                                          Icons.check);
                                    },
                                    child: Text(
                                      "Room Key: " +
                                          widget.RoomData.value[index].roomKey,
                                      textScaler: TextScaler.linear(1.0),
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
                                    "Contribution: ₹ " +
                                        commaSeperator(widget
                                            .RoomData.value[index].total
                                            .toString()),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "Spent: ₹ " +
                                        commaSeperator(widget
                                            .RoomData.value[index].spend
                                            .toString()),
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
      ),
      onTap: () async {
        if (this.mounted) {
          await _MoveToNext(context, index);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      physics: widget.flag ? ScrollPhysics() : AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      itemCount: widget.RoomData.value.length + 1,
      separatorBuilder: (context, index) {
        if (widget.roomType == 1) {
          if (widget.liveRoomType == 3) {
            return SizedBox(
              height: 5,
            );
          } else if (widget.liveRoomType == 2) {
            if (!widget.RoomData.value[index].done) {
              return SizedBox(
                height: 5,
              );
            } else {
              return SizedBox();
            }
          } else {
            if (widget.RoomData.value[index].done) {
              return SizedBox(
                height: 5,
              );
            } else {
              return SizedBox();
            }
          }
        } else {
          return SizedBox(
            height: 5,
          );
        }
      },
      itemBuilder: (BuildContext context, int index) {
        if (index == widget.RoomData.value.length) {
          if (fetchingData) {
            return Card(
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoActivityIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(
                        height: 40,
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SizedBox();
          }
        }
        if (widget.roomType == 1) {
          if (widget.liveRoomType == 3) {
            return roomSectors(context, index);
          } else if (widget.liveRoomType == 2) {
            if (!widget.RoomData.value[index].done) {
              return roomSectors(context, index);
            } else {
              return SizedBox();
            }
          } else {
            if (widget.RoomData.value[index].done) {
              return roomSectors(context, index);
            } else {
              return SizedBox();
            }
          }
        } else {
          return roomSectors(context, index);
        }
      },
    );
  }
}
