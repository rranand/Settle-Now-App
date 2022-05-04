
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/screens/aboutus.dart';
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


class RoomEach {
  final String roomName;
  final int members;
  final String roomKey;
  final bool active;
  final double total;
  final double spend;
  final String date;
  final String roomLink;

  RoomEach({required this.roomName,required this.members,required this.roomKey, required this.active, required this.total, required this.spend, required this.date, required this.roomLink});

  factory RoomEach.fromJson(Map<String, dynamic> json) {
    return RoomEach(
      roomName: crypto.decrypt(json['roomName']),
      members: int.parse(crypto.decrypt(json['members'])),
      roomKey: crypto.decrypt(json['roomKey']),
      active: json['active'],
      total: double.parse(crypto.decrypt(json['total'])),
      spend: double.parse(crypto.decrypt(json['spend'])),
      date: crypto.decrypt(json['date']),
      roomLink: crypto.decrypt(json['joinLink']),
    );
  }
}

class DashBoard extends StatefulWidget {
  const DashBoard({ Key? key }) : super(key: key);

  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int dash = 0;
  double yourSpend = 0;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _search = TextEditingController();
  String _token = "";
  late SharedPreferences prefs;
  final TextEditingController _NRoom = TextEditingController();
  final List<RoomEach> RoomDataO = [];
  final List<RoomEach> RoomDataC = [];
  final List<RoomEach> SearchRoomData = [];
  late String version = "";
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final _CformKey = GlobalKey<FormState>();
  final _JformKey = GlobalKey<FormState>();
  bool searchTrigger = false;
  bool searching  = false;
  bool dateIndex = true;
  List<String> Year = [];
  List<String> Month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  List<String> Date = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31'];
  List<int> from = [];
  List<int> to = [];
  bool error = false;
  String errorText = "";
  bool DateChanged = false;
  double heightSearched = 0;
  var updateData = null;
  bool _isUpdateAvailable = false;
  List<String> roomStatus = ['All', 'Active', 'Closed'];
  int roomStatusIndex = 0;
  bool imageUploading = false;
  bool haveImg = false;
  bool open = true;
  String amtSpend = "";
  late NetworkImage profilePic;

  Future _getImageID() async {
    if (this.mounted) {
      setState(() {
        haveImg = false;
      });
    }
    try {
      final response = await http.put(
        Uri.parse(global.url+'login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': _token
        },
        body: jsonEncode({
          'email': crypto.encrypt(_email.text),
        })
      );

      if (response.statusCode == 200) {
        var imgData = jsonDecode(response.body);
        if (imgData['havePic']) {
          if (this.mounted) {
            setState(() {
              profilePic = NetworkImage('https://drive.google.com/uc?id='+crypto.decrypt(imgData["fileId"]));
              haveImg = true;
            });
          }
        }
      }
    } on Exception catch(_) {
      _showToast(context, "No Internet Connection!!!");
    }
  }

  Future? imageUpload(ImageSource imageSource) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: imageSource, imageQuality: 50,);
    Dio dio = new Dio();

    if (image != null) {
      double sz = (await image.length())/(1024*1024);
      if (sz > 10) {
        _showToast(context, "Image Size is too large");
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
          "image":await MultipartFile.fromFile(
            image.path,
            contentType: new MediaType('image', ext)
          ),
          "type": "image/"+ext,
          "email": crypto.encrypt(_email.text),
        });
        
        final response = await dio.delete(
          global.url + 'login',
          data: formData,
          options: Options(
            headers: {
              "Content-Type":"multipart/form-data",
              'Auth': _token
            }
          )
        );
        
        if (response.statusCode == 200 ) {
          await _getImageID();
          _showToast(context, "Image Uploaded Successfully");
        } else {
          _showToast(context, "Failed to Upload Image");
        }
      } on Exception catch(_) {
        _showToast(context, "Failed to Upload Image");
      }  

      if (this.mounted) {
        setState(() {
          imageUploading = false;
        });
      }
    }
  }

  Future _updateCheck() async {
    
    try {
      final response = await http.patch(
        Uri.parse(global.url + 'login'),
      );

      if (response.statusCode == 200 && version.length != 0) {
        updateData = jsonDecode(response.body);

        List<String> gVersion =  version.split('.');
        List<int> versionPartG = [int.parse(gVersion[0]), int.parse(gVersion[1]), int.parse(gVersion[2])];
        List<String> rVersion =  crypto.decrypt(updateData["Version"]).split('.');
        List<int> versionPartR = [int.parse(rVersion[0]), int.parse(rVersion[1]), int.parse(rVersion[2])];
        
        if (versionPartR[0] > versionPartG[0]) {
          _isUpdateAvailable = true;
        } else if (versionPartR[0] == versionPartG[0]) {
          if (versionPartR[1] > versionPartG[1]) {
            _isUpdateAvailable = true;
          } else if (versionPartR[1] == versionPartG[1] && versionPartR[2] > versionPartG[2]) {
            _isUpdateAvailable = true;
          }
        }
      }
      
    } on Exception catch(_) {
    }
    
    if (this.mounted) {
      setState(() {});
    }
  }

  Future _extractEmail() async {

    var date = DateTime.now();
    from = [0, date.month-1, date.day-1];
    to = [0, date.month-1, date.day-1];

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = await packageInfo.version.toString();

    for(int i=date.year; i>=2018; i--) {
      Year.add(i.toString());
    }

    if (_email.text == "") {
      prefs = await SharedPreferences.getInstance();
      if (prefs.getString("email") != null && prefs.getString("name") != null && prefs.getString("token") != null && prefs.getString("pushToken") != null) {
        _email.text = prefs.getString("email")!;
        _name.text = prefs.getString("name")!;
        _token = prefs.getString("token")!;
        
      } else {
        
        await prefs.remove("email");
        await prefs.remove("name");
        await prefs.remove("token");
        await prefs.remove("pushToken");
        await deleteToken();

        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    }
    
    try {
      final response = await http.post(
        Uri.parse(global.url+'data'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': _token
        },
        body: jsonEncode({
          'email': crypto.encrypt(_email.text),
        })
      );
      
      if (response.statusCode == 200) {
        amtSpend = crypto.decrypt(jsonDecode(response.body)['amtSpend']);
        List<dynamic> list = jsonDecode(response.body)['data'];
        RoomDataO.clear();
        RoomDataC.clear();

        for(int i=0; i<list.length; i++) {
          if (list[i]['active']) {
            yourSpend += double.parse(crypto.decrypt(list[i]['spend'])) - (double.parse(crypto.decrypt(list[i]['total']))/double.parse(crypto.decrypt(list[i]['members'])));
            RoomDataO.add(RoomEach.fromJson(list[i]));
          } else {
            RoomDataC.add(RoomEach.fromJson(list[i]));
          }
        }

        if (this.mounted) {
          setState(() {});
        }

        await _getImageID();
      } else if (jsonDecode(response.body)['maintenance'] != null && jsonDecode(response.body)['maintenance']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Maintainence()),
            (Route<dynamic> route) => false,
        );
      } else {
        await prefs.remove("email");
        await prefs.remove("name");
        await prefs.remove("token");
        await prefs.remove("pushToken");
        await deleteToken();

        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
      
    } on Exception catch(_) {
      _showToast(context, "No Internet Connection!!!");
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
        response = await http.post(
          Uri.parse(global.url+'room'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'email': crypto.encrypt(_email.text),
            'roomName': crypto.encrypt(_NRoom.text),
          })
        );
      } else {
        response = await http.put(
          Uri.parse(global.url+'room'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Auth': _token
          },
          body: jsonEncode({
            'email': crypto.encrypt(_email.text),
            'roomKey': crypto.encrypt(_NRoom.text),
          })
        );
      }
      
      _NRoom.text = "";
      var JsonData = jsonDecode(response.body);

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);

      if (response.statusCode == 200) {
        _refreshIndicatorKey.currentState?.show();
      } else {
        _showToast(context, crypto.decrypt(JsonData["Message"]));
      }
    } on Exception catch(_) {
      Navigator.pop(context);
      _showToast(context, "No Internet Connection!!!");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => _refreshIndicatorKey.currentState?.show());
    LocalNotificationService.initialize();
    
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        if (message != null) {
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
      (message) {
        if (message.notification != null) {
        }
      },
    );

    _updateCheck();
  }

  buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    );
  }

  deleteToken() async {
    buildShowDialog(context);

    try {
       final response = await http.delete(
        Uri.parse(global.url+'verify'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Auth': _token
        },
        body: jsonEncode({
          'email': crypto.encrypt(_email.text),
        })
      );

    } on Exception catch(_) {
    }
    Navigator.pop(context);
  }

  buildFilterDialog(BuildContext context) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), 
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.95,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: dateIndex?BoxDecoration(
                                border: Border.symmetric(horizontal: BorderSide(width: 2, color: Theme.of(context).primaryColor))
                              ):null,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  child: Text(
                                    "From",
                                    style: TextStyle(
                                      fontSize: 28,
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
                              decoration: dateIndex?null:BoxDecoration(
                                border: Border.symmetric(horizontal: BorderSide(width: 2, color: Theme.of(context).primaryColor))
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  child: Text(
                                    "To",
                                    style: TextStyle(
                                      fontSize: 28,
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
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.9 - 50,
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: Year.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final themeProvider = Provider.of<ThemeProvider>(context);

                              return SizedBox(
                                height: 70,
                                width: 95,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState((){
                                        if (dateIndex) {
                                          from[0] = index;
                                        } else {
                                          to[0] = index;
                                        }
                                      });
                                    },
                                    child: Card(
                                      elevation: 1.0,
                                      shadowColor: Theme.of(context).primaryColor,
                                      color: dateIndex?(index==from[0]?Theme.of(context).primaryColor:Theme.of(context).cardColor):(index==to[0]?Theme.of(context).primaryColor:Theme.of(context).cardColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: InkWell(
                                          child: Text(
                                            Year[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: dateIndex?(index==from[0]?Colors.white:Theme.of(context).textTheme.bodySmall!.color):(index==to[0]?Colors.white:Theme.of(context).textTheme.bodySmall!.color),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          )
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Month",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.9 - 50,
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
                                      setState((){
                                        if (dateIndex) {
                                          from[1] = index;
                                        } else {
                                          to[1] = index;
                                        }
                                      });
                                    },
                                    child: Card(
                                      elevation: 1.0,
                                      shadowColor: Theme.of(context).primaryColor,
                                      color: dateIndex?(index==from[1]?Theme.of(context).primaryColor:Theme.of(context).cardColor):(index==to[1]?Theme.of(context).primaryColor:Theme.of(context).cardColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: InkWell(
                                          child: Text(
                                            Month[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: dateIndex?(index==from[1]?Colors.white:Theme.of(context).textTheme.bodySmall!.color):(index==to[1]?Colors.white:Theme.of(context).textTheme.bodySmall!.color),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Day",
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.9 - 50,
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
                                      setState((){
                                        if (dateIndex) {
                                          from[2] = index;
                                        } else {
                                          to[2] = index;
                                        }
                                      });
                                    },
                                    child: Card(
                                      elevation: 1.0,
                                      color: dateIndex?(index==from[2]?Theme.of(context).primaryColor:Theme.of(context).cardColor):(index==to[2]?Theme.of(context).primaryColor:Theme.of(context).cardColor),
                                      shadowColor: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      child: Center(
                                        child: InkWell(
                                          child: Text(
                                            Date[index],
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: dateIndex?(index==from[2]?Colors.white:Theme.of(context).textTheme.bodySmall!.color):(index==to[2]?Colors.white:Theme.of(context).textTheme.bodySmall!.color),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Room Status",
                              style: TextStyle(
                                  fontSize: 24,
                                ),
                            ),
                            Container(
                              width: 75,
                              child: DropdownButton<String>(
                                alignment: AlignmentDirectional.topStart,
                                borderRadius: BorderRadius.circular(10.0),
                                itemHeight: 70,
                                elevation: 1,
                                hint: Text(
                                  roomStatus[roomStatusIndex],
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                items: roomStatus.map((String value) {
                                  return DropdownMenuItem<String>(
                                    alignment: AlignmentDirectional.center,
                                    value: roomStatus.indexOf(value).toString(),
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (index) {
                                  setState(() {
                                    roomStatusIndex = int.parse(index!);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 10,),
                        error?Text(errorText,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            :SizedBox(),
                        SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 45,
                              width: 100,
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
                            SizedBox(
                              width: 20,
                            ),
                            SizedBox(
                              height: 45,
                              width: 100,
                              child: ElevatedButton(
                                child: Text("Apply",
                                  style: TextStyle(
                                    color: Colors.white
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    DateChanged = false;
                                    errorText = "";
                                    error = false;
                                  });
                                  
                                  var validate_1 = DateTime(int.parse(Year[from[0]]), from[1]+1, from[2]+1);
                                  var validate_2 = DateTime(int.parse(Year[to[0]]), to[1]+1, to[2]+1);
                                  if (validate_1.month != from[1]+1 || from[2]+1 != validate_1.day || validate_1.year != int.parse(Year[from[0]])) {
                                    errorText = "Wrong From Date";
                                    error = true;
                                  }
              
                                  if (validate_2.month != to[1]+1 || to[2]+1 != validate_2.day || validate_2.year != int.parse(Year[to[0]])) {
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
                                        errorText = "To Date Can't Before From Date";
                                      }
                                    }
              
                                  if (validate_2.isAfter(DateTime.now())) {
                                    error = true;
                                    if (errorText.length == 0) {
                                      errorText = "To Date Can't After Current Date";
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
          }
        );
      }
    ).then((val) {
      SearchData();
    });
  }

  bool getDate(String date) {
    final dd = date.split(' ');
    int mn = 0;
    for(int i=0; i<12; i++) {
      if (Month[i].contains(dd[0])) {
        mn = i;
      }
    }
    DateTime RD = DateTime(int.parse(dd[2]), mn+1,int.parse(dd[1]));
    DateTime FROMD = DateTime(int.parse(Year[from[0]]), from[1]+1, from[2]+1);
    DateTime TOD = DateTime(int.parse(Year[to[0]]), to[1]+1, to[2]+1);

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
      });
    }
    
    SearchRoomData.clear();
    
    if (roomStatusIndex == 0) {
      for(int i=0; i<RoomDataC.length; i++) {
        if (_search.text.length > 0 && RoomDataC[i].roomName.toLowerCase().contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataC[i].date)) {
              SearchRoomData.add(RoomDataC[i]);
            }
          } else {
            SearchRoomData.add(RoomDataC[i]);
          }
        } else if (_search.text.length == 7 && RoomDataC[i].roomKey == _search.text) {
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
      for(int i=0; i<RoomDataO.length; i++) {
        if (_search.text.length > 0 && RoomDataO[i].roomName.toLowerCase().contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataO[i].date)) {
              SearchRoomData.add(RoomDataO[i]);
            }
          } else {
            SearchRoomData.add(RoomDataO[i]);
          }
        } else if (_search.text.length == 7 && RoomDataO[i].roomKey == _search.text) {
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
      for(int i=0; i<RoomDataO.length; i++) {
        if (_search.text.length > 0 && RoomDataO[i].roomName.toLowerCase().contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataO[i].date)) {
              SearchRoomData.add(RoomDataO[i]);
            }
          } else {
            SearchRoomData.add(RoomDataO[i]);
          }
        } else if (_search.text.length == 7 && RoomDataO[i].roomKey == _search.text) {
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
      for(int i=0; i<RoomDataC.length; i++) {
        if (_search.text.length > 0 && RoomDataC[i].roomName.toLowerCase().contains(_search.text.toLowerCase())) {
          if (DateChanged) {
            if (getDate(RoomDataC[i].date)) {
              SearchRoomData.add(RoomDataC[i]);
            }
          } else {
            SearchRoomData.add(RoomDataC[i]);
          }
        } else if (_search.text.length == 7 && RoomDataC[i].roomKey == _search.text) {
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
    
    if (this.mounted) {
      setState(() {
        heightSearched = 30 + SearchRoomData.length*130+(SearchRoomData.length-1)*5;
        searching = false;
      });
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

  Widget updateWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settle Now (New Update Available)",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final provider = Provider.of<ThemeProvider>(context, listen: false);
              provider.toggleTheme(!themeProvider.darkTheme);
              prefs.setBool('darkTheme', themeProvider.darkTheme);
            },
            icon: Icon(
              Icons.brightness_2,
              color: themeProvider.darkTheme?Colors.white:Colors.black87,
            )
          )
        ],
      ),
      body: updatePage(data: updateData),
    );
  }

  Widget notificationWidget(BuildContext context) {
    return SizedBox();
  }

  Widget homeWidget(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _extractEmail,
      child: (RoomDataO.isEmpty&&RoomDataC.isEmpty)?
        Scrollbar(
          radius: Radius.circular(10.0),
          thickness: 5.5,
          child: SizedBox(
            height: MediaQuery.of(context).size.height*0.8,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text("No Rooms to Join, Create One!!!",
              style: TextStyle(
                fontSize: 25,
              ),
              ),
            ),
          ),
        ) 
        :(searchTrigger? _search.text.length==0&&SearchRoomData.isEmpty?Center(
          child: Text("Search Rooms...",style: TextStyle(
              fontSize: 25,
            ),),
        ):(SearchRoomData.isEmpty? Center(
          child: searching? CircularProgressIndicator():Text("No Results Found",style: TextStyle(
              fontSize: 25,
          )))
        :Scrollbar(
          radius: Radius.circular(10.0),
          thickness: 5.5,
          child: ListView(
            shrinkWrap: true,
            physics: ScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:15.0, vertical: 10.0),
                child: Text(SearchRoomData.length.toString() + " Results Found"),
              ),
              SizedBox (
                height: heightSearched,
                child: RoomWidget(RoomData: SearchRoomData, email: _email.text, flag: true, token: _token,)
              ),
            ],
          ),
        ))
        :
        Column(
          children: [
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 40,
                    decoration: open?BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(13))
                    ):null,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          child: Text(
                            "Live",
                            style: TextStyle(
                              fontSize: 18,
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
                    decoration: open?null:BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(13))
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          child: Text(
                            "Closed",
                            style: TextStyle(
                              fontSize: 18,
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
            open?Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total : ₹ " + double.parse(amtSpend).toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 18
                    ),
                  ),
                  Text(
                    (yourSpend>=0?"Gain : ₹ ":"Loss : ₹ ") + yourSpend.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 18
                    ),
                  ),
                ],
              ),
            ):SizedBox(),
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
                height: open?(MediaQuery.of(context).size.height-250):(MediaQuery.of(context).size.height-220),
                child: open?RoomDataO.isEmpty?Scrollbar(
                radius: Radius.circular(10.0),
                thickness: 5.5,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height*0.8,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text("No Live Room Found!!!",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                    ),
                  ),
                ),
                ):Scrollbar(
                  radius: Radius.circular(10.0),
                  thickness: 5.5,
                  child: RoomWidget(RoomData: RoomDataO, email: _email.text, flag: false, token: _token)
                ):(RoomDataC.isEmpty?Scrollbar(
                  radius: Radius.circular(10.0),
                  thickness: 5.5,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.8,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text("No Closed Room Found!!!",
                      style: TextStyle(
                        fontSize: 25,
                      ),
                      ),
                    ),
                  ),
                ):Scrollbar(
                  radius: Radius.circular(10.0),
                  thickness: 5.5,
                  child: RoomWidget(RoomData: RoomDataC, email: _email.text, flag: false, token: _token,)
                )),
              ),
            )
            
          ],
        ) 
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return _isUpdateAvailable?updateWidget(context)
    :Scaffold(
      appBar: dash==0?AppBar(
        title: searchTrigger? TextField(
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          maxLines: 1,
          decoration: const InputDecoration(
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
        :Text(
          "Settle Now",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searchTrigger = !searchTrigger;
                DateChanged = false;
              });
            }, 
            icon: Icon(Icons.search, color: themeProvider.darkTheme?Colors.white:Colors.black,))
        ],
      ):AppBar(
        title:Text(
          "Settle Now",
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: dash==0?homeWidget(context):notificationWidget(context),
        bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: dash,
        onTap: (index) => setState(() {
          dash = index;
        }),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 25,),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, size: 25,),
            label: "Notification",
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            _name.text.length==0? Center(child: CircularProgressIndicator(),) :UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).drawerTheme.backgroundColor
              ),
              margin: EdgeInsets.all(0),
              currentAccountPicture: Stack(
                children: [
                  haveImg?CircleAvatar(
                    radius: 45,
                    backgroundImage: profilePic,
                    child: imageUploading?Center(child: CircularProgressIndicator()):null,
                  )
                  :CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage('assets/Images/unknown.jpeg'),
                    child: imageUploading?Center(child: CircularProgressIndicator()):null,
                  ),
                  Positioned(
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
                                    leading: Icon(Icons.camera),
                                    title: Text('Camera'),
                                    onTap: () {
                                      imageUpload(ImageSource.camera);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.image),
                                    title: Text('Gallery'),
                                    onTap: () {
                                      imageUpload(ImageSource.gallery);
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
                    )
                  )
                ],
              ),
              accountName: Text(
                _name.text,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white
                )
              ), 
              accountEmail: Text(
                _email.text,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white
                )
              ),
            ),
            ListTile(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => Profile(email: _email.text, token: _token,)),
              ),
              leading: Icon(Icons.person, color: Colors.white),
              title: Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
            ),
            ListTile(
              onTap: () {
                var now = DateTime.now();
                String date = (now.month-1).toString() + now.year.toString();
                
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Expenses(email: _email.text, date: date, token: _token,)),
                );
              },
              leading: Icon(Icons.account_balance_outlined, color: Colors.white,),
              title: Text(
                  "Personal Expenses",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => LendCredit(email: _email.text, token: _token,)),
                );
              },
              leading: Icon(Icons.credit_card, color: Colors.white,),
              title: Text(
                  "Len-Den",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
            ),
            ListTile(
              leading: Icon(Icons.border_color, color: Colors.white),
              title: Text(
                "Theme",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white
                ),
              ),
              trailing: IconButton(
                onPressed: () {
                  final provider = Provider.of<ThemeProvider>(context, listen: false);
                  provider.toggleTheme(!themeProvider.darkTheme);
                  prefs.setBool('darkTheme', themeProvider.darkTheme);
                },
                icon: Icon(
                  Icons.brightness_2,
                  color: themeProvider.darkTheme?Colors.black87:Colors.white,
                )
              ),
            ),
            ListTile(
              onTap: () async {
                await Share.share("Download Settle Now\nhttps://settlenow.herokuapp.com");
              },
              leading: Icon(Icons.share, color: Colors.white),
              title: Text(
                  "Share",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
            ),
            ListTile(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AboutUs()),
              ),
              leading: Icon(Icons.book_outlined, color: Colors.white),
              title: Text(
                  "About Us",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
            ),
            ListTile(
              onTap: () async {
                await prefs.remove('name');
                await prefs.remove('email');
                await prefs.remove('token');
                await prefs.remove('pushToken');
                await deleteToken();
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (Route<dynamic> route) => false,
                );
              },
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text(
                  "Log Out",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white
                  ),
                ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Version "+version, 
                    textAlign: TextAlign.center, 
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white
                      ),
                    ),
                  InkWell(
                    onTap: () async {
                      launch(
                        "https://settlenow.herokuapp.com/privacy-policy",
                        forceWebView: true,
                        enableJavaScript: true,
                      );
                    },
                    child: Text(
                      "Privacy Policy", 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white
                        ),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: dash==0?(searchTrigger?
      FloatingActionButton(
        onPressed: () {
          buildFilterDialog(context);
        },
        child: Icon(Icons.filter_alt_outlined, color: Colors.white,),
      )
      :FloatingActionButton(
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
                          leading: Icon(Icons.add, color: Theme.of(context).primaryColor,),
                          title: const Text("Create Room"),
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Form(
                                        key: _CformKey,
                                        child: TextFormField(
                                          controller: _NRoom,
                                          keyboardType: TextInputType.text,
                                          maxLength: 70,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 18),
                                          cursorColor: Colors.black,
                                          autocorrect: false,
                                          validator: (value) {
                                            RegExp validateText = RegExp(r'\b[\w]{4,}\b');
                                            if (!validateText.hasMatch(_NRoom.text)) {
                                              return "Enter Valid Room Name";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(8.0),
                                            hintText: "Enter Room Name",
                                            errorStyle: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        width: 100,
                                        child: ElevatedButton(
                                          child: const Text("Create", style: TextStyle(color: Colors.white),),
                                          onPressed: () {
                                            if (_CformKey.currentState!.validate()) {
                                              SendingData(true, context);
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
                          leading: Icon(Icons.edit, color: Theme.of(context).primaryColor,),
                          title: const Text("Join Room"),
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Form(
                                        key: _JformKey,
                                        child: TextFormField(
                                          controller: _NRoom,
                                          keyboardType: TextInputType.text,
                                          maxLength: 7,
                                          maxLines: 1,
                                          style: const TextStyle(fontSize: 18),
                                          cursorColor: Colors.black,
                                          autocorrect: false,
                                          validator: (value) {
                                            RegExp validateText = RegExp(r'\b[\w]{7}\b');
                                            if (!validateText.hasMatch(_NRoom.text)) {
                                              return "Enter Valid Room Key";
                                            }
                                            return null;
                                          },
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(8.0),
                                            hintText: "Enter Room Key",
                                            labelText: "Room Key",
                                            errorStyle: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        width: 100,
                                        child: ElevatedButton(
                                          child: const Text("Join", style: TextStyle(color: Colors.white),),
                                          onPressed: () {
                                            if (_JformKey.currentState!.validate()) {
                                              SendingData(false, context);
                                            }
                                          }
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
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add, color: Colors.white,),
      )):null,
    );
  }
}

class RoomWidget extends StatelessWidget {
  final List<dynamic> RoomData;
  final String email;
  final bool flag;
  final String token;

  final Shader linearGradient = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 243, 33, 112), Color.fromARGB(255, 255, 235, 7), Color.fromARGB(255,33, 150, 243), Color.fromARGB(255, 255, 0, 235)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  final Shader linearGradient_2 = LinearGradient(
      colors: <Color>[Color.fromARGB(255, 0, 219, 222), Color.fromARGB(255, 252, 0, 255)],
    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  RoomWidget({ Key? key, required this.RoomData, required this.email, required this.flag, required this.token }) : super(key: key);

  _MoveToNext(BuildContext context, int index) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => RoomExpense(roomKey: RoomData[index].roomKey, email: email, roomName: RoomData[index].roomName, token: token, roomLink: RoomData[index].roomLink)),
    );
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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: flag?ScrollPhysics():null,
      padding: EdgeInsets.all(8.0),
      itemCount: RoomData.length, 
      separatorBuilder: (context, index) => SizedBox(height: 5,),
      itemBuilder: (BuildContext context, int index){
        final themeProvider = Provider.of<ThemeProvider>(context);
        return InkWell(
          child: SizedBox(
            child: Card(
              elevation: 2.0,
              clipBehavior: Clip.antiAlias,
              shadowColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column (
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        RoomData[index].roomName, 
                        style: TextStyle(
                          fontSize: 24,
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
                                "Members: " + RoomData[index].members.toString(),
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor
                                ),
                              ),
                              Text(
                                "Created: " + RoomData[index].date,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  await Share.share("Join "+ RoomData[index].roomName + "\nRoom Key: " + RoomData[index].roomKey + "\n" + RoomData[index].roomLink);
                                },
                                onLongPress: () async {
                                  Clipboard.setData(ClipboardData(text: RoomData[index].roomKey));
                                  _showToast(context, "Join Key Copied");
                                },
                                child: Text(
                                  "Room Key: " + RoomData[index].roomKey,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Spend: ₹ " + RoomData[index].total.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor
                                ),
                              ),
                              Text(
                                "Your Spend: ₹ " + RoomData[index].spend.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor
                                ),
                              ),
                              
                              Text(
                                "Average Spend: ₹ " + double.parse((RoomData[index].total/RoomData[index].members).toString()).toStringAsFixed(1),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ]
                  )
                ),
              ),
            ),
          onTap: () {
            _MoveToNext(context, index);
          },
        );
      },
    );
  }
}

class updatePage extends StatelessWidget {
  var data = null;
  updatePage({ Key? key, required this.data }) : super(key: key);

  _launchURL(BuildContext context) async {
    launch(crypto.decrypt(data["link"]));
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Version: '+ crypto.decrypt(data["Version"]),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text('Description: '+ crypto.decrypt(data["description"]),
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
                    child: ElevatedButton(
                      child: const Text('Download'),
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