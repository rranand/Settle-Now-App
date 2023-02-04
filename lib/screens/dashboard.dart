import 'dart:convert';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/models/RoomEach.dart';
import 'package:settlenow/others/GoogleSignIN.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/screens/BankTransactions.dart';
import 'package:settlenow/screens/aboutus.dart';
import 'package:settlenow/screens/analysis.dart';
import 'package:settlenow/screens/contactUs.dart';
import 'package:settlenow/screens/expenses.dart';
import 'package:settlenow/screens/lendCredit.dart';
import 'package:settlenow/screens/loginPage.dart';
import 'package:settlenow/screens/profile.dart';
import 'package:settlenow/screens/rooms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../contents.dart' as global;
import '../notificationService/NotificationController.dart';
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
  final int dash;
  const DashBoard({Key? key, required this.version, this.dash = 0})
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
  var now;
  String date = "";
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _search = TextEditingController();
  String _token = "";
  int appOpened = 0;
  late SharedPreferences prefs;
  final TextEditingController _NRoom = TextEditingController();
  final ValueNotifier<List<RoomEach>> RoomDataO = ValueNotifier([]);
  final ValueNotifier<List<RoomEach>> RoomDataC = ValueNotifier([]);
  final ValueNotifier<List<RoomEach>> SearchRoomData = ValueNotifier([]);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _requestIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _sentrequestIndicatorKey =
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
  bool roomDataFetched = false;
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
  bool isSentRoomRequestLoaded = false;
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
  bool open = true;
  String amtSpend = "";
  String due = "";
  double amtSpendOpen = 0;
  double amtSpendClose = 0;
  String _profilePicID = "";
  List<dynamic> RoomRequest = [];
  List<dynamic> sentRoomRequest = [];
  GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  bool isBankMessageLoadedOnce = false;
  bool _flexibleUpdateAvailable = false;
  bool importantUpdate = false;

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

  Future<void> _getImageID() async {
    if (isGoogle) {
      return;
    }

    try {
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
        } else {
          _profilePicID = "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8";
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

  Future<void> manualUpdateCheck() async {
    try {
      final response = await http.patch(
        Uri.parse(global.url + 'login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

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
    } on Exception catch (_) {}
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> rateUs() =>
      inAppReview.openStoreListing(appStoreId: 'com.rohit.settlenow');

  Future imageUpload(ImageSource imageSource) async {
    final ImagePicker _picker = ImagePicker();

    final XFile? orgImage = await _picker.pickImage(
      source: imageSource,
      imageQuality: 50,
    );

    CroppedFile? image = await ImageCropper().cropImage(
      sourcePath: orgImage!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop',
            toolbarColor: Theme.of(context).primaryColor.withOpacity(0.9),
            activeControlsWidgetColor:
                Theme.of(context).primaryColor.withOpacity(0.9),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
      ],
    );

    Dio dio = new Dio();

    if (image != null) {
      double sz = (await image.readAsBytes()).lengthInBytes / (1024 * 1024);
      if (sz > 10) {
        showToast(context, "Image Size is too large", Icons.warning);
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
    dash = widget.dash;
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

      if (await prefs.getBool("isGoogle") != null) {
        isGoogle = await prefs.getBool("isGoogle")!;
      }

      if (isGoogle) {
        _googleSignIn.onCurrentUserChanged
            .listen((GoogleSignInAccount? account) async {
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
        initalDataLoaded = true;
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

  Future<void> _extractEmail() async {
    roomDataFetched = false;
    RoomDataO.value.clear();
    RoomDataC.value.clear();
    amtSpendClose = 0;
    amtSpendOpen = 0;
    String appVersion = await getAppVersion();

    if (this.mounted) {
      setState(() {});
    }

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
        due = crypto.decrypt(jsonDecode(response.body)['due']);
        List<dynamic> list = jsonDecode(response.body)['data'];

        for (int i = 0; i < list.length; i++) {
          if (list[i]['active']) {
            RoomDataO.value.add(RoomEach.fromJson(list[i]));
            amtSpendOpen += RoomDataO.value.last.spend;
          } else {
            RoomDataC.value.add(RoomEach.fromJson(list[i]));
            amtSpendClose += RoomDataC.value.last.spend;
          }
        }

        RoomDataO.value.sort((b, a) {
          DateTime tempDate_1 =
              new DateFormat(global.dateTimeFormat_new).parse(a.date);
          DateTime tempDate_2 =
              new DateFormat(global.dateTimeFormat_new).parse(b.date);
          return tempDate_1.compareTo(tempDate_2);
        });

        RoomDataC.value.sort((b, a) {
          DateTime tempDate_1 =
              new DateFormat(global.dateTimeFormat_new).parse(a.date);
          DateTime tempDate_2 =
              new DateFormat(global.dateTimeFormat_new).parse(b.date);
          return tempDate_1.compareTo(tempDate_2);
        });
        roomDataFetched = true;
        if (this.mounted) {
          setState(() {});
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
          isRoomRequestLoaded = false;
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

    isRoomRequestLoaded = true;
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
        RoomDataO.value
            .insert(0, RoomEach.fromJson(jsonDecode(response.body)['data']));
      } else {
        showToast(context, crypto.decrypt(JsonData["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }
  }

  Future<void> _updateCheck() async {
    await checkForUpdate();
  }

  Future<void> fetchSentRequest() async {
    try {
      if (this.mounted) {
        setState(() {
          isSentRoomRequestLoaded = false;
          sentRoomRequest.clear();
        });
      }
      final response = await http.post(Uri.parse(global.url + 'friend/sender'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'email': crypto.encrypt(_email.text),
          }));
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        sentRoomRequest = data["data"];
      } else {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }
    isSentRoomRequestLoaded = true;

    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> cancelSentRequest(String id, String type) async {
    try {
      final response = await http.put(Uri.parse(global.url + 'friend/sender'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode(
              {'email': crypto.encrypt(_email.text), 'id': id, 'type': type}));
      var data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (_) {
      await onException(context);
    }

    if (this.mounted) {
      setState(() {});
    }

    await _sentrequestIndicatorKey.currentState?.show();
  }

  notificationProcessor(message) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    String notificationFrom = "";

    if (message.data.isNotEmpty) {
      notificationFrom = crypto.decrypt(message.data["type"]);
    }

    if (notificationFrom == "room") {
      Map<String, String> notificationData =
          await getDataFromNotification(message.data.toString());
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              channelKey: 'roomID',
              title: message.notification!.title,
              body: message.notification!.body,
              payload: notificationData));
    } else if (notificationFrom == "lend") {
      Map<String, String> notificationData =
          await getDataFromNotification(message.data.toString());
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              channelKey: 'lendenID',
              title: message.notification!.title,
              body: message.notification!.body,
              payload: notificationData));
    } else {
      Map<String, String> notificationData =
          await getDataFromNotification(message.data.toString());
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: id,
              channelKey: 'requestID',
              title: message.notification!.title,
              body: message.notification!.body,
              payload: notificationData),
          actionButtons: [
            NotificationActionButton(key: 'JOIN', label: 'Join'),
            NotificationActionButton(key: 'CANCEL', label: 'Cancel'),
          ]);
    }
  }

  executeParallel() async {
    do {
      await initalDataLoad();
    } while (!initalDataLoaded);

    await Future.wait([
      getInitialData(),
      manualUpdateCheck(),
      _extractEmail(),
      _updateCheck(),
      getRoomRequest(),
      fetchSentRequest(),
      _getImageID()
    ]);
  }

  @override
  void initState() {
    super.initState();
    executeParallel();
    AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: "roomID",
        channelName: "Room",
        channelDescription: 'Notification channel for Room',
        defaultColor: Colors.deepPurple,
      ),
      NotificationChannel(
          channelKey: "lendenID",
          channelName: "Len-Den",
          channelDescription: 'Notification channel for Len-Den',
          defaultColor: Colors.deepPurple),
      NotificationChannel(
          channelKey: "requestID",
          channelName: "Room Request",
          channelDescription: 'Notification channel for Room Request',
          defaultColor: Colors.deepPurple),
    ]);

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) async {
        if (message != null) {
          await notificationProcessor(message);
        }
      },
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
        if (message.notification != null) {
          await notificationProcessor(message);
        }
      },
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        NotificationController.onActionReceivedMethod(context, receivedAction);
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
        SearchRoomData.value.clear();
      });
    }

    SearchRoomData.value.clear();

    if (roomStatusIndex == 0) {
      for (int i = 0; i < RoomDataC.value.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataC.value[i].roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataC.value[i].date)) {
              SearchRoomData.value.add(RoomDataC.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataC.value[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataC.value[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataC.value[i].date)) {
              SearchRoomData.value.add(RoomDataC.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataC.value[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataC.value[i].date)) {
            SearchRoomData.value.add(RoomDataC.value[i]);
          }
        }
      }
      for (int i = 0; i < RoomDataO.value.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataO.value[i].roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataO.value[i].date)) {
              SearchRoomData.value.add(RoomDataO.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataO.value[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataO.value[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataO.value[i].date)) {
              SearchRoomData.value.add(RoomDataO.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataO.value[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataO.value[i].date)) {
            SearchRoomData.value.add(RoomDataO.value[i]);
          }
        }
      }
    } else if (roomStatusIndex == 1) {
      for (int i = 0; i < RoomDataO.value.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataO.value[i].roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataO.value[i].date)) {
              SearchRoomData.value.add(RoomDataO.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataO.value[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataO.value[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataO.value[i].date)) {
              SearchRoomData.value.add(RoomDataO.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataO.value[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataO.value[i].date)) {
            SearchRoomData.value.add(RoomDataO.value[i]);
          }
        }
      }
    } else {
      for (int i = 0; i < RoomDataC.value.length; i++) {
        if (_search.text.length > 0 &&
            RoomDataC.value[i].roomName
                .toLowerCase()
                .contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataC.value[i].date)) {
              SearchRoomData.value.add(RoomDataC.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataC.value[i]);
          }
        } else if (_search.text.length == 7 &&
            RoomDataC.value[i].roomKey == _search.text) {
          if (DateChanged) {
            if (getDate(RoomDataC.value[i].date)) {
              SearchRoomData.value.add(RoomDataC.value[i]);
            }
          } else {
            SearchRoomData.value.add(RoomDataC.value[i]);
          }
        } else if (_search.text.length == 0) {
          if (DateChanged && getDate(RoomDataC.value[i].date)) {
            SearchRoomData.value.add(RoomDataC.value[i]);
          }
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

    if (this.mounted) {
      setState(() {
        heightSearched =
            SearchRoomData.value.length * 115 + SearchRoomData.value.length * 5;
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
            'roomKey': roomKey,
            'email': crypto.encrypt(_email.text),
            'confirm': crypto.encrypt(flag)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
      if (flag == "1") {
        await Future.wait([_extractEmail(), getRoomRequest()]);
      } else {
        await _requestIndicatorKey.currentState?.show();
      }
      Navigator.pop(context);
    } on Exception catch (_) {
      Navigator.pop(context);
      await onException(context);
    }
  }

  Future<void> JoinRequestLend(String flag, String id) async {
    buildShowDialog(context);
    try {
      final response = await http.put(Uri.parse(global.url + 'friend/lend'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'id': id,
            'email': crypto.encrypt(_email.text),
            'confirm': crypto.encrypt(flag)
          }));

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
      await _requestIndicatorKey.currentState?.show();
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
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(horizontal: 110, vertical: 16),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.all(Radius.circular(24))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    if (this.mounted) {
                      setState(() {
                        requestType = true;
                      });
                    }
                  },
                  child: Text(
                    "Receive",
                    style: TextStyle(
                        fontSize: 20,
                        color:
                            requestType ? Theme.of(context).primaryColor : null,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Text(
                  "|",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
                ),
                SizedBox(
                  width: 6,
                ),
                InkWell(
                  onTap: () {
                    if (this.mounted) {
                      setState(() {
                        requestType = false;
                      });
                    }
                  },
                  child: Text(
                    "Sent",
                    style: TextStyle(
                        fontSize: 20,
                        color:
                            requestType ? null : Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )),
      ),
      body: requestType
          ? RefreshIndicator(
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
                                          imageUrl: crypto
                                                      .decrypt(
                                                          RoomRequest[index]
                                                              ["pic"])
                                                      .length ==
                                                  0
                                              ? global.driveUrl +
                                                  "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                              : crypto.decrypt(
                                                  RoomRequest[index]["pic"]),
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
                                                        " invited to join " +
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
                                                                      ["key"]);
                                                            } else {
                                                              await JoinRequestLend(
                                                                  "0",
                                                                  RoomRequest[
                                                                          index]
                                                                      ["key"]);
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
                                                                      ["key"]);
                                                            } else {
                                                              await JoinRequestLend(
                                                                  "1",
                                                                  RoomRequest[
                                                                          index]
                                                                      ["key"]);
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
                                          imageUrl: crypto
                                                      .decrypt(
                                                          sentRoomRequest[index]
                                                              ["pic"])
                                                      .length ==
                                                  0
                                              ? global.driveUrl +
                                                  "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                              : crypto.decrypt(
                                                  sentRoomRequest[index]
                                                      ["pic"]),
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
                                                    "You invited " +
                                                        crypto.decrypt(
                                                            sentRoomRequest[
                                                                index]["by"]) +
                                                        " to join " +
                                                        crypto.decrypt(
                                                            sentRoomRequest[
                                                                    index]
                                                                ["name"]) +
                                                        (crypto.decrypt(sentRoomRequest[
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
                                                          Navigator.pop(
                                                              context);
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

  Widget homeWidget(BuildContext context) {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _extractEmail,
        child: (RoomDataO.value.isEmpty && RoomDataC.value.isEmpty)
            ? (roomDataFetched
                ? ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Text(
                            "No Room Joined, Create One!!!",
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                        ),
                      )
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
                                width: 80,
                                height: 40,
                                decoration: open
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Total : ",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 20.0,
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
                                Row(
                                  children: [
                                    Text(
                                      "Gain : ",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 20.0,
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
                          ),
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 250,
                                          height: 18.0,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.white,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20))),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 150,
                                                    height: 14.0,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
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
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: 150,
                                                    height: 14.0,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: Colors.white,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
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
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20))),
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
                      ),
                    ),
                  ))
            : (searchTrigger
                ? _search.text.length == 0 && SearchRoomData.value.isEmpty
                    ? Center(
                        child: Text(
                          "Search Rooms...",
                          style: TextStyle(
                            fontSize: 22,
                          ),
                        ),
                      )
                    : (SearchRoomData.value.isEmpty
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
                                  child: Text(
                                      SearchRoomData.value.length.toString() +
                                          " Results Found"),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 180,
                                  child: RoomWidget(
                                    RoomData: SearchRoomData,
                                    ClosedRoomData: RoomDataC,
                                    email: _email.text,
                                    flag: true,
                                    token: _token,
                                    refreshKey: _refreshIndicatorKey,
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
                                  due.isEmpty
                                      ? Text("")
                                      : Text(
                                          (due[0] != "-"
                                                  ? "Gain : ₹ "
                                                  : "Owe : ₹ ") +
                                              commaSeperator(due),
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
                              ? RoomDataO.value.isEmpty
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
                                        ClosedRoomData: RoomDataC,
                                        email: _email.text,
                                        flag: false,
                                        token: _token,
                                        refreshKey: _refreshIndicatorKey,
                                      ))
                              : (RoomDataC.value.isEmpty
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
                                        ClosedRoomData: RoomDataC,
                                        email: _email.text,
                                        flag: false,
                                        token: _token,
                                        refreshKey: _refreshIndicatorKey,
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
    } else if (dash == 4) {
      return Analysis(
        RoomDataC: RoomDataC.value,
        RoomDataO: RoomDataO.value,
        email: _email.text,
        token: _token,
        RoomExpenseCategory: roomExpenseCategory,
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

    return importantUpdate
        ? updateWidget(context)
        : Scaffold(
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
                            : (dash == 4
                                ? AppBar(
                                    title: Text(
                                      "Analysis",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : AppBar(
                                    title: Text(
                                      "Profile",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ))))),
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
                    Icons.analytics_outlined,
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
                              color: Theme.of(context)
                                  .drawerTheme
                                  .backgroundColor),
                          margin: EdgeInsets.all(0),
                          currentAccountPicture: Stack(
                            children: [
                              isGoogle
                                  ? CachedNetworkImage(
                                      imageUrl: (_currentUser != null
                                          ? _currentUser!.photoUrl.toString()
                                          : global.driveUrl +
                                              "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"),
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
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
                                      imageBuilder: (context, imageProvider) =>
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
                                  : (imageUploading
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : CachedNetworkImage(
                                          imageUrl: (global.driveUrl +
                                              (_profilePicID.length == 0
                                                  ? "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
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
                                        )),
                              isGoogle
                                  ? SizedBox()
                                  : Positioned(
                                      left: 50,
                                      top: 51,
                                      child: Container(
                                        width: 25,
                                        height: 25,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: InkWell(
                                            onTap: () async {
                                              showModalBottomSheet<void>(
                                                context: context,
                                                isScrollControlled: true,
                                                builder:
                                                    (BuildContext context) {
                                                  return SizedBox(
                                                    height: 120,
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          leading: Icon(
                                                              Icons.camera),
                                                          title: Text('Camera'),
                                                          onTap: () {
                                                            imageUpload(
                                                                ImageSource
                                                                    .camera);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        ListTile(
                                                          leading:
                                                              Icon(Icons.image),
                                                          title:
                                                              Text('Gallery'),
                                                          onTap: () {
                                                            imageUpload(
                                                                ImageSource
                                                                    .gallery);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: Icon(
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
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                          accountEmail: Text(_email.text,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white)),
                        ),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BankTransactions(
                                  email: _email.text,
                                  token: _token,
                                  isBankMessageLoadedOnce:
                                      isBankMessageLoadedOnce,
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("Beta",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white)),
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
                          final provider = Provider.of<ThemeProvider>(context,
                              listen: false);
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
                      _email.text == "rrohitanand3336@gmail.com"
                          ? "Contact Data"
                          : "Contact Us",
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: Icon(
                                            Icons.add,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          title: const Text("Create Room"),
                                          onTap: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding:
                                                      MediaQuery.of(context)
                                                          .viewInsets,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Form(
                                                        key: _CformKey,
                                                        child: TextFormField(
                                                          controller: _NRoom,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          maxLength: 70,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                          cursorColor:
                                                              Colors.black,
                                                          autocorrect: false,
                                                          validator: (value) {
                                                            RegExp
                                                                validateText =
                                                                RegExp(
                                                                    r'\b[\w]{4,}\b');
                                                            if (!validateText
                                                                .hasMatch(_NRoom
                                                                    .text)) {
                                                              return "Enter Valid Room Name";
                                                            }
                                                            return null;
                                                          },
                                                          decoration:
                                                              const InputDecoration(
                                                            counterText: "",
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            hintText:
                                                                "Enter Room Name",
                                                            errorStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        15),
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
                                                                    ? Colors
                                                                        .white
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
                                                            if (_CformKey
                                                                .currentState!
                                                                .validate()) {
                                                              SendingData(true,
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
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(
                                            Icons.edit,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          title: const Text("Join Room"),
                                          onTap: () {
                                            showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding:
                                                      MediaQuery.of(context)
                                                          .viewInsets,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Form(
                                                        key: _JformKey,
                                                        child: TextFormField(
                                                          controller: _NRoom,
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          maxLength: 7,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                          cursorColor:
                                                              Colors.black,
                                                          autocorrect: false,
                                                          validator: (value) {
                                                            RegExp
                                                                validateText =
                                                                RegExp(
                                                                    r'\b[\w]{7}\b');
                                                            if (!validateText
                                                                .hasMatch(_NRoom
                                                                    .text)) {
                                                              return "Enter Valid Room Key";
                                                            }
                                                            return null;
                                                          },
                                                          decoration:
                                                              const InputDecoration(
                                                            counterText: "",
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            hintText:
                                                                "Enter Room Key",
                                                            labelText:
                                                                "Room Key",
                                                            errorStyle:
                                                                TextStyle(
                                                                    fontSize:
                                                                        15),
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
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black),
                                                            ),
                                                            style:
                                                                OutlinedButton
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
                                                                    false,
                                                                    context);
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

class RoomWidget extends StatefulWidget {
  final ValueNotifier<List<RoomEach>> RoomData;
  final ValueNotifier<List<RoomEach>> ClosedRoomData;
  final String email;
  final bool flag;
  final String token;
  final GlobalKey<RefreshIndicatorState> refreshKey;

  RoomWidget(
      {Key? key,
      required this.RoomData,
      required this.ClosedRoomData,
      required this.email,
      required this.flag,
      required this.token,
      required this.refreshKey})
      : super(key: key);

  @override
  State<RoomWidget> createState() => _RoomWidgetState();
}

class _RoomWidgetState extends State<RoomWidget> {
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

  Future updateRoom(BuildContext context, int index, String roomID) async {
    if (this.mounted) {
      setState(() {
        indexLoading = index;
      });
    }
    try {
      final response = await http.post(Uri.parse(global.url + 'update/room'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            "email": crypto.encrypt(widget.email),
            "roomKey": crypto.encrypt(roomID)
          }));

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
    } on Exception catch (_) {
      await onException(context);
    }

    indexLoading = -1;
    if (this.mounted) {
      setState(() {});
    }
  }

  _MoveToNext(BuildContext context, int index) async {
    final dataFrom = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RoomExpense(
              roomKey: widget.RoomData.value[index].roomKey,
              email: widget.email,
              roomName: widget.RoomData.value[index].roomName,
              token: widget.token,
              roomLink: widget.RoomData.value[index].roomLink,
              isRoomActive: widget.RoomData.value[index].active)),
    );
    if (dataFrom) {
      await updateRoom(context, index, widget.RoomData.value[index].roomKey);
    }
  }

  Future<List<dynamic>> getMembers(BuildContext context, String roomkey) async {
    List<dynamic> membersData = [];
    try {
      final response = await http.post(
          Uri.parse(global.url + 'room/roomSplitMembers'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': widget.token
          },
          body: jsonEncode({
            'email': crypto.encrypt(widget.email),
            'roomKey': crypto.encrypt(roomkey)
          }));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        membersData = data['data'];
      }
    } on Exception catch (_) {
      await onException(context);
    }
    return membersData;
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            widget.RoomData.value[index].roomName,
                            textScaleFactor: 1.0,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 22, overflow: TextOverflow.ellipsis),
                          ),
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
                                        imageUrl: crypto
                                                    .decrypt(snapshot.data![i]
                                                        ['pic'])
                                                    .length ==
                                                0
                                            ? global.driveUrl +
                                                "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                            : crypto.decrypt(
                                                snapshot.data![i]['pic']),
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
                                            imageUrl: crypto
                                                        .decrypt(snapshot
                                                            .data![i]['pic'])
                                                        .length ==
                                                    0
                                                ? global.driveUrl +
                                                    "11tIuRVao7Si0p_xYS8XRcnvuJB_NyfI8"
                                                : crypto.decrypt(
                                                    snapshot.data![i]['pic']),
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
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return Stack(
                                  children: allImages,
                                );
                              },
                              future: getMembers(context,
                                  widget.RoomData.value[index].roomKey),
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
                                      await Share.share("Join " +
                                          widget
                                              .RoomData.value[index].roomName +
                                          "\nRoom Key: " +
                                          widget.RoomData.value[index].roomKey +
                                          "\n" +
                                          widget
                                              .RoomData.value[index].roomLink);
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
        await _MoveToNext(context, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: widget.flag ? ScrollPhysics() : null,
      padding: EdgeInsets.all(8.0),
      itemCount: widget.RoomData.value.length,
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
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width * 0.15, 0, 10.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Version: ' + crypto.decrypt(data["Version"]).split('+').first,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'What\'s new \n' +
                  crypto
                      .decrypt(data["description"])
                      .split(',')
                      .map((e) => '  * ' + e)
                      .join('\n'),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
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
            ),
          ],
        ),
      ),
    );
  }
}
