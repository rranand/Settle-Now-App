import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/functions/gradient.dart';
import 'package:settlenow/functions/sharedPrefParse.dart';
import 'package:settlenow/models/FriendEach.dart';
import 'package:settlenow/models/PaymendData.dart';
import 'package:settlenow/models/RoomEach.dart';
import 'package:settlenow/others/crypto.dart';
import 'package:settlenow/others/internetConnectivity.dart';
import 'package:settlenow/routes/route_constant.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../contents.dart' as global;
import '../models/ChartData.dart';
import '../others/themes.dart';
import 'package:share_plus/share_plus.dart';

class RoomExpense extends StatefulWidget {
  final String roomKey;

  const RoomExpense({Key? key, required this.roomKey}) : super(key: key);

  @override
  _RoomExpenseState createState() => _RoomExpenseState();
}

class _RoomExpenseState extends State<RoomExpense>
    with SingleTickerProviderStateMixin {
  String _email = "";
  String _token = "";

  String roomLink = "";
  bool isRoomActive = false;
  String objID = "";
  List<RoomMemberEach> roomMembers = [];
  String createdOn = "";
  final roomName = TextEditingController();
  List<dynamic> allExpenseList = [];
  List<dynamic> TransList = [];
  List<FriendEach> friendData = [];
  List<PaymentDataEach> allTransactionData = [];
  bool expenseSplitWithExistingMembers = false;
  bool splitManually = false;
  int dash = 0;
  bool locked = false;
  final TextEditingController _amt = TextEditingController();
  final TextEditingController _searchFriend = TextEditingController();
  final TextEditingController _purpose = TextEditingController();
  DateTime expenseDate = DateTime.now();
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyRooms =
      new GlobalKey<RefreshIndicatorState>();
  bool isClear = false;
  bool loaded = false;
  bool loadFriendData = false;
  double heightExpense = 0;
  String paymentTotalALL = "";
  bool loadingPaymentData = false;
  GlobalKey<FormState> _formKeyRooms = GlobalKey<FormState>();
  String yourExpense = "";
  List<ChartData> dataMap = [];
  List<ChartData> dataMapByUser = [];
  List<Map> getContactsFromDB = [];

  String expenseTitle = "All Expense";
  List<String> membersListName = [];
  List<String> membersListEmail = [];
  int roomClosedCount = 0;
  List<String> activeMembersEmail = [];
  int membersListIndex = -1;
  int membersListIndexS = -1;
  int membersListIndexR = -1;
  int selfIndex = -1;
  bool defaultPage = true;
  double paymentTotal = 0;
  bool loadingFilteredPaymentData = false;
  bool noSplit = false;
  List<PaymentDataEach> paymentData = [];
  List<FriendEach> friendDataSearched = [];
  bool showAllTransactionData = true;
  ScrollController _scrollController = ScrollController();
  List<String> addExpenseTo = [];
  List<dynamic> expenseCategory = [];
  List<List<dynamic>> subCategory = [];
  int roomExpenseCategoryIndex = 0;
  int roomsubExpenseCategoryIndex = 0;
  double totalAmount = 0;
  bool isClosedany = false;
  final TextEditingController _paytoMemberAmt = TextEditingController();
  final TextEditingController _amountPaid = TextEditingController();
  int scrollToExpense = -1;
  bool firstTimeLoad = true;
  Map<String, Map<String, dynamic>> manualSplitMembers = {};
  Map<String, double> manualSplitAmount = {};
  Set<int> filtercategoryIndex = Set();
  List<dynamic> filterResult = [];
  bool showExpenseYouAreIn = false;
  bool showFilterResult = false;
  bool filterDialog = false;
  RangeValues _currentAmountValues = const RangeValues(0, 100);
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormFieldState> _updatePayToMemberAmount =
      GlobalKey<FormFieldState>();
  double maxSpentAmount = 10000;
  int curMemberIndex = -1;
  DateTimeRange dateRange = DateTimeRange(
      start: new DateTime(DateTime.now().year, DateTime.now().month - 6),
      end: DateTime.now());
  List<TextEditingController> _amountRangeValues = [
    new TextEditingController(text: "0"),
    new TextEditingController(text: "100000")
  ];
  bool searchTrigger = false;
  TextEditingController _searchText = TextEditingController();

  List<String> graphs = ["Expense By Category", "Expense By User"];
  int indexGraph = 0;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  _updatePayToMember(BuildContext context, String objID, String deleteFlag,
      String amount, PaymentDataEach payDataOG) async {
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': crypto.encrypt(widget.roomKey),
        'amt': crypto.encrypt(amount),
        'objID': crypto.encrypt(objID),
        'deleteFlag': crypto.encrypt(deleteFlag),
      };

      final response = await createHTTPreq(
          'data/updatePayMember', http.put, _token, jsonInputData, context);

      if (response.statusCode == 200) {
        double oldAmt = payDataOG.amount;
        int otherUserIndex =
            manualSplitMembers[payDataOG.receiverEmail]!["index"];
        if (deleteFlag == "1") {
          allTransactionData.remove(payDataOG);
          roomMembers[selfIndex].current -= oldAmt;
          roomMembers[otherUserIndex].current += oldAmt;
        } else {
          double newAmt = double.parse(amount);
          payDataOG.amount = newAmt;
          double remainingAmt_1 = roomMembers[selfIndex].current;
          double remainingAmt_2 = roomMembers[otherUserIndex].current;
          roomMembers[selfIndex].current = remainingAmt_1 - oldAmt + newAmt;
          roomMembers[otherUserIndex].current =
              remainingAmt_2 + oldAmt - newAmt;
        }
      }
      var updateMessage = jsonDecode(response.body);
      showToast(context, crypto.decrypt(updateMessage["Message"]),
          response.statusCode == 200 ? Icons.check : Icons.close);
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->_updatePayToMember"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<void> initChart() async {
    if (dataMap.isEmpty) {
      Map<String, double> tempMap = {};
      for (int i = 0; i < expenseCategory.length; i++) {
        tempMap[expenseCategory[i]] = 0;
      }
      totalAmount = 0;
      dataMap.clear();
      for (int i = 0; i < TransList.length; i++) {
        if (tempMap.containsKey(crypto.decrypt(TransList[i]["Type"]))) {
          tempMap[crypto.decrypt(TransList[i]["Type"])] =
              tempMap[crypto.decrypt(TransList[i]["Type"])]! +
                  double.parse(crypto.decrypt(TransList[i]["Amount"]));
        }
      }
      for (int i = 0; i < expenseCategory.length; i++) {
        totalAmount += tempMap[expenseCategory[i]]!;
        dataMap.add(
            ChartData.byType(expenseCategory[i], tempMap[expenseCategory[i]]!));
      }
    }
  }

  Future<void> _getPaymentData() async {
    loadingPaymentData = false;
    if (this.mounted) {
      setState(() {});
    }
    try {
      Map<String, String> jsonInputData = {
        'roomKey': crypto.encrypt(widget.roomKey),
        'email': crypto.encrypt(_email),
      };

      final response = await createHTTPreq(
          'transaction/all', http.delete, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        allTransactionData.clear();
        List<dynamic> tempPaymentData = data['data'];
        for (int i = 0; i < tempPaymentData.length; i++) {
          allTransactionData.add(PaymentDataEach.fromJson(tempPaymentData[i]));
        }
        paymentTotalALL = crypto.decrypt(data['total']);
        loadingPaymentData = true;
      } else {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->_getPaymentData"]);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Future _initialisation() async {
    if (this.mounted) {
      setState(() {
        manualSplitMembers.clear();
        roomClosedCount = 0;
        activeMembersEmail.clear();
        isClosedany = false;
        roomMembers.clear();
        expenseCategory.clear();
        subCategory.clear();
        membersListName.clear();
        membersListEmail.clear();
        dataMapByUser.clear();
        dataMap.clear();
      });
    }

    try {
      Map<String, String> jsonInputData = {
        'roomKey': crypto.encrypt(widget.roomKey),
        'email': crypto.encrypt(_email),
      };

      final response = await createHTTPreq(
          'data', http.patch, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        roomName.setText(crypto.decrypt(data['roomName']));
        roomLink = crypto.decrypt(data['roomLink']);
        isRoomActive = crypto.decrypt(data['isRoomActive']) == "true";
        objID = crypto.decrypt(data['objID']);

        Map<dynamic, dynamic> categoryMap = data['expenseCategory'];
        categoryMap.forEach((key, value) {
          expenseCategory.add(key);
          subCategory.add(value);
        });

        isClear = data['data'][0]["done"];
        createdOn = formatDateTime(crypto.decrypt(data['data'][0]["date"]));

        bool isInGain = false;
        int initIndexGain = -1;
        int initIndexLoss = -1;
        List<dynamic> tempData = data['data'];

        for (int i = 1; i < tempData.length; i++) {
          RoomMemberEach eachMember = RoomMemberEach.fromJson(tempData[i]);
          roomMembers.add(eachMember);

          isClosedany = isClosedany || eachMember.done;
          if (eachMember.done) {
            expenseSplitWithExistingMembers = true;
            roomClosedCount++;
          } else if (eachMember.email != _email &&
              !eachMember.done &&
              eachMember.current.abs() > 0.1) {
            if (initIndexGain == -1 && eachMember.current > 0) {
              initIndexGain = i - 1;
            }
            if (initIndexLoss == -1 && eachMember.current < 0) {
              initIndexLoss = i - 1;
            }
            activeMembersEmail.add(eachMember.email);
          }
          if (!eachMember.done) {
            manualSplitMembers[eachMember.email] = {
              "Name": eachMember.name,
              "Email": eachMember.email,
              "Pic": eachMember.pic,
              "index": i - 1
            };
          }

          membersListName.add(eachMember.name);
          membersListEmail.add(eachMember.email);
          dataMapByUser.add(ChartData.byUser(eachMember.name, eachMember.email,
              eachMember.pic, eachMember.yourExpense));
          if (eachMember.email == _email) {
            selfIndex = i - 1;
            yourExpense = eachMember.yourExpense.toStringAsFixed(2);
            if (eachMember.current > 0) {
              isInGain = true;
            }
            if (eachMember.done) {
              locked = true;
            }
          }
        }
        if (isInGain) {
          membersListIndex = initIndexLoss;
        } else {
          membersListIndex = initIndexGain;
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
      } else if (response.statusCode == 422) {
        if (crypto.decrypt(data["Message"]) == "Room Not Found") {
          context.push(AppRouteConstants.errorPageRouteName);
        }
      } else {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->_initialisation"]);
    }
  }

  Future<void> getFriendData() async {
    if (!isRoomActive) {
      return null;
    }

    try {
      if (this.mounted) {
        setState(() {
          loadFriendData = false;
          friendData.clear();
        });
      }
      Map<String, String> jsonInputData = {
        'roomKey': crypto.encrypt(widget.roomKey),
        'email': crypto.encrypt(_email),
      };

      final response = await createHTTPreq(
          'friend', http.patch, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        List<dynamic> tempData = data['data'];
        for (int i = 0; i < tempData.length; i++) {
          friendData.add(FriendEach.fromJson(tempData[i]));
        }
        loadFriendData = true;
      } else {
        showToast(context, crypto.decrypt(data["Message"]), Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->getFriendData"]);
    }

    friendData = getUnionOfContacts(getContactsFromDB, friendData);
    if (this.mounted) {
      setState(() {});
    }
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

  Future<void> _extractExpenseData() async {
    if (this.mounted) {
      setState(() {
        scrollToExpense = -1;
        heightExpense = 0;
        loaded = false;
        allExpenseList.clear();
        TransList.clear();
      });
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': crypto.encrypt(widget.roomKey),
      };

      final response = await createHTTPreq(
          'transaction', http.post, _token, jsonInputData, context);

      var TransData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        loaded = true;
        if (TransData != null) {
          allExpenseList = jsonDecode(response.body)['data'];
          TransList = jsonDecode(response.body)['data'];
          if (firstTimeLoad) {
            scrollToExpense = TransList.indexWhere(
                (element) => crypto.decrypt(element['id']) == objID);
            maxSpentAmount = 100;
            allExpenseList.forEach((ele) {
              maxSpentAmount = max(
                  maxSpentAmount, double.parse(crypto.decrypt(ele['Amount'])));
            });
            maxSpentAmount = maxSpentAmount.ceilToDouble();
            String amtInStr = maxSpentAmount.toInt().toString();
            int firstD = int.parse(amtInStr[0]) + 1;
            maxSpentAmount =
                double.parse(firstD.toString() + '0' * (amtInStr.length - 1));
            _currentAmountValues = RangeValues(0, maxSpentAmount);
            _amountRangeValues[1].setText(maxSpentAmount.toInt().toString());
          }
        }
      } else {
        showToast(context, crypto.decrypt(TransData["Message"]), Icons.close);
      }
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->_extractExpenseData"]);
    }
    firstTimeLoad = false;
    heightExpense =
        30 + allExpenseList.length * 125 + (allExpenseList.length - 1) * 5;

    if (this.mounted) {
      setState(() {});
    }
  }

  AddExpenseManual(BuildContext context) async {
    var Tdata = null;
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': crypto.encrypt(widget.roomKey),
        'purpose': crypto.encrypt(_purpose.text),
        'date': crypto
            .encrypt(DateFormat("MMM dd yyyy h:mm a").format(expenseDate)),
        'type': crypto.encrypt(expenseCategory[roomExpenseCategoryIndex]),
        'subType': crypto.encrypt(roomsubExpenseCategoryIndex != -1 &&
                subCategory[roomExpenseCategoryIndex].length > 0
            ? subCategory[roomExpenseCategoryIndex][roomsubExpenseCategoryIndex]
            : "None"),
        'split': crypto.encrypt(manualSplitAmount.toString())
      };

      final response = await createHTTPreq(
          'manualSplit', http.post, _token, jsonInputData, context);

      _amt.text = "";
      _purpose.text = "";
      Tdata = jsonDecode(response.body);

      for (int i = 0; i < 3 && context.canPop(); i++) {
        if (this.mounted) {
          context.pop();
        }
      }

      if (splitManually && this.mounted) {
        context.pop();
      }

      if (response.statusCode == 422) {
        showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
      } else {
        _initialisation();
        TransList.insert(0, Tdata["data"]);
        allExpenseList.insert(0, Tdata["data"]);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->AddExpenseManual"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  updateRoomName(BuildContext context, String newRoomName) async {
    var Tdata = null;
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomID': crypto.encrypt(objID),
        'roomName': crypto.encrypt(newRoomName),
      };

      final response = await createHTTPreq(
          'updateRoomName/room', http.post, _token, jsonInputData, context);

      Tdata = jsonDecode(response.body);

      for (int i = 0; i < 2 && context.canPop(); i++) {
        if (this.mounted) {
          context.pop();
        }
      }

      showToast(context, crypto.decrypt(Tdata["Message"]),
          response.statusCode == 200 ? Icons.check : Icons.close);

      if (response.statusCode == 200) {
        roomName.setText(newRoomName);
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->updateRoomName"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  AddExpense(BuildContext context) async {
    if (_formKeyRooms.currentState!.validate()) {
      var Tdata = null;
      if (this.mounted) {
        buildShowDialog(context);
      }
      try {
        Map<String, String> jsonInputData = {
          'email': crypto.encrypt(_email),
          'roomKey': crypto.encrypt(widget.roomKey),
          'purpose': crypto.encrypt(_purpose.text),
          'date': crypto
              .encrypt(DateFormat("MMM dd yyyy h:mm a").format(expenseDate)),
          'amt': crypto.encrypt(_amt.text),
          'type': crypto.encrypt(expenseCategory[roomExpenseCategoryIndex]),
          'subType': crypto.encrypt(roomsubExpenseCategoryIndex != -1 &&
                  subCategory[roomExpenseCategoryIndex].length > 0
              ? subCategory[roomExpenseCategoryIndex]
                  [roomsubExpenseCategoryIndex]
              : "None"),
          "members": crypto.encrypt(((addExpenseTo.isEmpty &&
                  (isClosedany || expenseSplitWithExistingMembers))
              ? activeMembersEmail.toString()
              : addExpenseTo.toString()))
        };

        final response = await createHTTPreq(
            'data', http.delete, _token, jsonInputData, context);

        _amt.text = "";
        _purpose.text = "";
        Tdata = jsonDecode(response.body);
        for (int i = 0; i < 3 && context.canPop(); i++) {
          if (this.mounted) {
            context.pop();
          }
        }

        if (response.statusCode == 422) {
          showToast(context, crypto.decrypt(Tdata["Message"]), Icons.close);
        } else {
          TransList.insert(0, Tdata["data"]);
          allExpenseList.insert(0, Tdata["data"]);
          _initialisation();
        }
      } on Exception catch (err, stackTrace) {
        if (this.mounted) {
          context.pop();
        }
        if (this.mounted) {
          onException(err, stackTrace,
              reason: "Unknwon Error", info: ["Rooms->AddExpense"]);
        }
      }
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  PayToMember(BuildContext context, String amountPaid, bool closeRoom,
      bool fromCloseWidget) async {
    if (_formKeyRooms.currentState!.validate()) {
      var Tdata = null;
      if (this.mounted) {
        buildShowDialog(context);
      }

      try {
        Map<String, String> jsonInputData = {
          'emailS': crypto.encrypt(_email),
          'emailR': crypto.encrypt(membersListEmail[membersListIndex]),
          'roomKey': crypto.encrypt(widget.roomKey),
          'closeRoom': crypto.encrypt(closeRoom.toString()),
          'amt': crypto.encrypt(amountPaid),
        };

        final response = await createHTTPreq(
            'data', http.put, _token, jsonInputData, context);
        Tdata = jsonDecode(response.body);
        _amountPaid.text = "";
        for (int i = 0;
            i < (fromCloseWidget ? 4 : 3) && context.canPop();
            i++) {
          if (this.mounted) {
            context.pop();
          }
        }
        if (response.statusCode == 200) {
          allTransactionData.insert(0, PaymentDataEach.fromJson(Tdata['data']));
          roomMembers[selfIndex].current += double.parse(amountPaid);
          roomMembers[membersListIndex].current -= double.parse(amountPaid);

          membersListIndex = -1;
          bool isInGain = roomMembers[selfIndex].current > 0;
          for (int i = 0; i < roomMembers.length; i++) {
            bool isMemberIngain = roomMembers[i].current > 0;
            if (!(selfIndex == i ||
                roomMembers[i].done ||
                isMemberIngain == isInGain ||
                roomMembers[i].current.abs() < 0.1)) {
              membersListIndex = i;
              break;
            }
          }
        }
        showToast(context, crypto.decrypt(Tdata["Message"]),
            response.statusCode == 200 ? Icons.check : Icons.close);
      } on Exception catch (err, stackTrace) {
        for (int i = 0;
            i < (fromCloseWidget ? 2 : 1) && context.canPop();
            i++) {
          if (this.mounted) {
            context.pop();
          }
        }
        if (this.mounted) {
          onException(err, stackTrace,
              reason: "Unknwon Error", info: ["Rooms->PayToMember"]);
        }
      }
      if (this.mounted) {
        setState(() {});
      }
    }
  }

  retrievePaymentData() async {
    try {
      if (this.mounted) {
        setState(() {
          paymentData.clear();
          showAllTransactionData = false;
          loadingFilteredPaymentData = true;
          paymentTotal = 0;
        });
      }
      String senderEmail =
          membersListIndexS == -1 ? "" : membersListEmail[membersListIndexS];
      String recevierEmail =
          membersListIndexR == -1 ? "" : membersListEmail[membersListIndexR];

      allTransactionData.forEach((ele) {
        if (ele.amount > 0 &&
            (ele.senderEmail == senderEmail || senderEmail == "") &&
            (ele.receiverEmail == recevierEmail || recevierEmail == "")) {
          paymentData.add(ele);
          paymentTotal += ele.amount.abs();
        }
        if (ele.amount < 0 &&
            (ele.senderEmail == recevierEmail || recevierEmail == "") &&
            (ele.receiverEmail == senderEmail || senderEmail == "")) {
          paymentData.add(ele);
          paymentTotal += ele.amount.abs();
        }
        ;
      });
      loadingFilteredPaymentData = false;
      if (this.mounted) {
        setState(() {});
      }
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->retrievePaymentData"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  CloseRoom(BuildContext context) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      var CloseData = null;
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(_email),
        'roomKey': crypto.encrypt(widget.roomKey),
      };

      final response = await createHTTPreq(
          'room', http.delete, _token, jsonInputData, context);
      CloseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        roomMembers[selfIndex].done = true;
        roomClosedCount++;
        isClosedany = true;
        locked = true;
        manualSplitMembers.remove(_email);
        isClear = true;
        isRoomActive = !CloseData["isRoomClosed"];
      }
      for (int i = 0; i < 2 && context.canPop(); i++) {
        if (this.mounted) {
          context.pop();
        }
      }
      showToast(context, crypto.decrypt(CloseData["Message"]),
          response.statusCode == 200 ? Icons.check : Icons.close);
    } on Exception catch (err, stackTrace) {
      if (this.mounted) {
        context.pop();
      }
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->CloseRoom"]);
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  closeRoomWidget(BuildContext context) {
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
                                await CloseRoom(context);
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

  Future<void> executeParallel() async {
    var tokenData = await getStringPref('token');

    if (tokenData != null) {
      Map<String, dynamic> jsonOutData = parseJWT(tokenData.toString());
      if (this.mounted) {
        setState(() {
          _email = jsonOutData["email"]!;
          _token = jsonOutData["token"]!;
        });
      }
      Map<String, dynamic> jsonInputData = {
        'email': crypto.encrypt(_email),
        "url": crypto
            .encrypt(AppRouteConstants.roomRouteName + "/" + widget.roomKey),
        "creationDate": crypto.encrypt(DateTime.now().toString())
      };
      pushAnalytics(context, jsonInputData, _token);
      if (!kIsWeb) {
        getContactsFromDB = await getContactsFromLocal();
      }
      _initialisation();
      if (isRoomActive) {
        getFriendData();
      }
      _extractExpenseData();
      _getPaymentData();
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

  @override
  void initState() {
    super.initState();
    executeParallel();
  }

  Widget addFriendWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Invite Member",
                      style: TextStyle(fontSize: 22),
                    ),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () async {
                              if (this.mounted) {
                                setState(() {
                                  loadFriendData = false;
                                });
                                await getFriendData();
                                setState(() {
                                  loadFriendData = true;
                                });
                              }
                            },
                            icon: Icon(
                              Icons.refresh_outlined,
                              size: 26,
                            )),
                        kIsWeb
                            ? SizedBox()
                            : IconButton(
                                onPressed: () async {
                                  await Share.share("Join " +
                                      roomName.text +
                                      "\nRoom Key: " +
                                      widget.roomKey +
                                      "\n" +
                                      roomLink);
                                },
                                icon: Icon(
                                  Icons.send,
                                  size: 26,
                                )),
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                loadFriendData
                    ? friendData.isEmpty
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height - 310,
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
                                  if (this.mounted) {
                                    setState(() {
                                      _searchFriend.text = s;
                                      _searchFriend.selection =
                                          TextSelection.collapsed(
                                              offset:
                                                  _searchFriend.text.length);
                                    });
                                  }
                                  SearchFriend();
                                },
                              ),
                              SizedBox(
                                height: 13,
                              ),
                              SingleChildScrollView(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 335,
                                  child: _searchFriend.text.isEmpty
                                      ? friendListWidget(context, friendData)
                                      : (friendDataSearched.isEmpty
                                          ? Center(
                                              child: Text(
                                                "No User Found",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            )
                                          : friendListWidget(
                                              context, friendDataSearched)),
                                ),
                              ),
                            ],
                          )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height - 310,
                        child: Shimmer.fromColors(
                            baseColor: Theme.of(context).cardColor,
                            highlightColor: Theme.of(context).primaryColor,
                            child: Column(
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
                                    if (this.mounted) {
                                      setState(() {
                                        _searchFriend.text = s;
                                        _searchFriend.selection =
                                            TextSelection.collapsed(
                                                offset:
                                                    _searchFriend.text.length);
                                      });
                                    }
                                    SearchFriend();
                                  },
                                ),
                                SizedBox(
                                  height: 13,
                                ),
                                SingleChildScrollView(
                                  child: SizedBox(
                                      height: 500,
                                      child: ListView.separated(
                                          separatorBuilder: (context, index) =>
                                              SizedBox(
                                                height: 5,
                                              ),
                                          shrinkWrap: true,
                                          itemCount: 16,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 75,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.white,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Container(
                                                            width: 45,
                                                            height: 45,
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: DecorationImage(
                                                                  image: AssetImage(
                                                                      'assets/Images/unknown.jpeg'),
                                                                  fit: BoxFit
                                                                      .cover),
                                                            )),
                                                        Container(
                                                          width: 200,
                                                          height: 15.0,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        Icon(Icons.person_add)
                                                      ]),
                                                ),
                                              ),
                                            );
                                          })),
                                ),
                              ],
                            )))
              ],
            )));
  }

  sendJoinRequest(String email, bool isFromContact, int index) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'roomKey': crypto.encrypt(widget.roomKey),
        'email': crypto.encrypt(_email),
        'fEmail': crypto.encrypt(email),
        'isFromContact': crypto.encrypt(isFromContact.toString())
      };

      final response = await createHTTPreq(
          'friend', http.post, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        friendData[index].fromContact = false;
        friendData[index].status = "S";
        friendData[index].requestID = crypto.decrypt(data['requestID']);
      }

      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->sendJoinRequest"]);
    }
    if (this.mounted) {
      context.pop();
    }
  }

  cancelJoinRequest(String email, String requestID, int index) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'roomKey': crypto.encrypt(widget.roomKey),
        'email': crypto.encrypt(email),
        'confirm': crypto.encrypt("0"),
        'id': crypto.encrypt(requestID)
      };

      final response = await createHTTPreq(
          'friend', http.put, _token, jsonInputData, context);

      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        friendData[index].status = "NJ";
        friendData[index].requestID = "";
      }
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->cancelJoinRequest"]);
    }
    if (this.mounted) {
      context.pop();
    }
  }

  closeRoomRequest() async {
    try {
      Map<String, String> jsonInputData = {
        'roomKey': crypto.encrypt(widget.roomKey),
        'email': crypto.encrypt(_email)
      };

      final response = await createHTTPreq(
          'transaction', http.put, _token, jsonInputData, context);

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]), Icons.check);
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->closeRoomRequest"]);
    }
  }

  Widget friendListWidget(BuildContext context, List<FriendEach> data) {
    return StatefulBuilder(builder: (context, setState) {
      return Scrollbar(
        radius: Radius.circular(10.0),
        thickness: 5.5,
        child: ListView.separated(
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
                                httpHeaders: {
                                  'Access-Control-Allow-Origin': '*'
                                },
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
                                        image: AssetImage(
                                            'assets/Images/unknown.jpeg'),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 45.0,
                                  height: 45.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 250,
                                child: InkWell(
                                  onTap: () {
                                    showToast(context, data[index].name,
                                        Icons.person);
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
                                    if (data[index].status == "NJ") {
                                      await sendJoinRequest(data[index].email,
                                          data[index].fromContact, index);
                                    } else {
                                      await cancelJoinRequest(data[index].email,
                                          data[index].requestID, index);
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
            }),
      );
    });
  }

  Widget memberCard(BuildContext context, int index) {
    return SizedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
        child: InkWell(
          onTap: () async {
            expenseTitle = roomMembers[index].name + "\'s Expense";
            curMemberIndex = index;
            getFilterResult();
            if (this.mounted) {
              setState(() {});
            }
          },
          child: Stack(
            children: [
              Card(
                elevation: 1.0,
                shadowColor: Theme.of(context).primaryColor,
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: roomMembers[index].done
                    ? RoundedRectangleBorder(
                        side: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(15.0),
                      )
                    : RoundedRectangleBorder(
                        side: BorderSide(
                            color:
                                Theme.of(context).primaryColor.withAlpha(90)),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CachedNetworkImage(
                          httpHeaders: {'Access-Control-Allow-Origin': '*'},
                          imageUrl: roomMembers[index].pic.length == 0
                              ? addCorsinImage(global.unknown_avatar_id)
                              : addCorsinImage(roomMembers[index].pic),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) =>
                                  CircularProgressIndicator(
                                      value: downloadProgress.progress),
                          errorWidget: (context, url, error) => Container(
                            width: 65.0,
                            height: 65.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/Images/unknown.jpeg'),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 65.0,
                            height: 65.0,
                            decoration: BoxDecoration(
                              border: roomMembers[index].own
                                  ? Border.all(
                                      color: Theme.of(context).primaryColor,
                                      width: 3.4)
                                  : null,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                child: Text(
                                  roomMembers[index].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    foreground: kIsWeb
                                        ? null
                                        : (Paint()..shader = linearGradient_1),
                                  ),
                                ),
                                onTap: () => showToast(context,
                                    roomMembers[index].name, Icons.check),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                "Contribution : ₹ " +
                                    commaSeperator((roomMembers[index].expense +
                                            roomMembers[index]
                                                .totalSplitExpense)
                                        .toStringAsFixed(2)),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  foreground: kIsWeb
                                      ? null
                                      : (Paint()..shader = linearGradient_2),
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                  "Spent : ₹ " +
                                      commaSeperator(roomMembers[index]
                                          .yourExpense
                                          .toStringAsFixed(2)),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    foreground: kIsWeb
                                        ? null
                                        : (Paint()..shader = linearGradient_2),
                                  )),
                              SizedBox(
                                height: 3,
                              ),
                              roomMembers[index].done ||
                                      roomMembers[index].current.abs() < 0.1
                                  ? SizedBox()
                                  : (double.parse(roomMembers[index]
                                              .current
                                              .toStringAsFixed(2)) >
                                          0
                                      ? Text(
                                          "Gain : ₹ " +
                                              commaSeperator(roomMembers[index]
                                                  .current
                                                  .toStringAsFixed(2)),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.green,
                                          ),
                                        )
                                      : double.parse(roomMembers[index]
                                                  .current
                                                  .toStringAsFixed(2)) <
                                              0
                                          ? Text(
                                              "Owe : ₹ " +
                                                  commaSeperator(
                                                      roomMembers[index]
                                                          .current
                                                          .toStringAsFixed(2)),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.red,
                                              ),
                                            )
                                          : SizedBox()),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Positioned(
                  right: 12.0,
                  bottom: 12.0,
                  child: (roomMembers[index].done && isRoomActive)
                      ? Icon(
                          Icons.lock_outline,
                          size: 26,
                        )
                      : SizedBox())
            ],
          ),
        ),
      ),
    );
  }

  bool findElement(List<String> arr, String ele) {
    for (int i = 0; i < arr.length; i++) {
      if (arr[i] == ele) {
        return true;
      }
    }

    return false;
  }

  Widget memberExpenseCard(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: Theme.of(context).bottomSheetTheme.modalBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: membersListIndex == index
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                httpHeaders: {'Access-Control-Allow-Origin': '*'},
                imageUrl: roomMembers[index].pic.length == 0
                    ? addCorsinImage(global.unknown_avatar_id)
                    : addCorsinImage(roomMembers[index].pic),
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
              SizedBox(width: 8),
              Text(
                roomMembers[index].name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget homeWidget() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return roomMembers.isEmpty
        ? ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).cardColor,
                    highlightColor: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text("Room Key"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          ListTile(
                            title: Text("You Spent"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          ListTile(
                            title: Text("Members"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          ListTile(
                            title: Text("Spent On"),
                            trailing: Container(
                              width: 150,
                              height: 15.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Member",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 140,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: 4,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index == 0) {
                                          return SizedBox();
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              height: 170,
                                              width: 260,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Container(
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
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          width: 150,
                                                          height: 18.0,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          width: 130,
                                                          height: 16,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          width: 130,
                                                          height: 16,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          width: 130,
                                                          height: 16,
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              20))),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        expenseTitle,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 135,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 200,
                                                  height: 20.0,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 150,
                                                  height: 15.0,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 120,
                                                  height: 15.0,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 170,
                                                  height: 15.0,
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
                                                  height: 8,
                                                ),
                                                Container(
                                                  width: 100,
                                                  height: 15.0,
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
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 50,
                                              height: 30.0,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20))),
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    )),
              )
            ],
          )
        : RefreshIndicator(
            color: Theme.of(context).primaryColor,
            key: _refreshIndicatorKeyRooms,
            onRefresh: executeParallel,
            child: NestedScrollView(
              floatHeaderSlivers: true,
              controller: _scrollController,
              headerSliverBuilder: (context, value) {
                return [
                  SliverToBoxAdapter(
                    child: InkWell(
                      onTap: () async {
                        Clipboard.setData(ClipboardData(text: widget.roomKey));
                        showToast(
                            context, "Join Key Copied", Icons.copy_outlined);
                      },
                      child: ListTile(
                        title: Text("Room Key"),
                        trailing: Text(widget.roomKey,
                            style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: const Text("You Spent"),
                      trailing: Text("₹ " + commaSeperator(yourExpense),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: const Text("Members"),
                      trailing: Text(roomMembers.length.toString(),
                          style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ListTile(
                      title: const Text("Created On"),
                      trailing: Text(createdOn, style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: !isClear
                        ? Padding(
                            padding: EdgeInsets.all(15.0),
                            child: SizedBox(
                              height: 45,
                              child: OutlinedButton(
                                child: Text(
                                  "Close Room",
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
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        closeRoomWidget(context),
                                  );
                                },
                              ),
                            ),
                          )
                        : SizedBox(),
                  ),
                  SliverToBoxAdapter(child: const Divider()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Member",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height:
                                membersListEmail.length - roomClosedCount == 0
                                    ? 120
                                    : 145,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: roomMembers.length,
                              itemBuilder: (BuildContext context, int index) {
                                return memberCard(context, index);
                              },
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: expenseTitle == "All Expense" ? 3 : 0,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$expenseTitle (${TransList.length})",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              expenseTitle == "All Expense"
                                  ? SizedBox()
                                  : IconButton(
                                      onPressed: () async {
                                        TransList.clear();
                                        expenseTitle = "All Expense";
                                        curMemberIndex = -1;
                                        TransList.addAll(allExpenseList);

                                        if (showFilterResult) {
                                          getFilterResult();
                                        }

                                        if (this.mounted) {
                                          setState(() {});
                                        }
                                      },
                                      icon: Icon(
                                        Icons.restart_alt_outlined,
                                        size: 32,
                                      ))
                            ],
                          ),
                          SizedBox(
                            height: expenseTitle == "All Expense" ? 13 : 0,
                          )
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: allExpenseList.isEmpty
                  ? Center(
                      child: loaded
                          ? Text(
                              "No Expense Found",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            )
                          : CircularProgressIndicator.adaptive())
                  : (TransList.isEmpty
                      ? Center(
                          child: Text(
                          "No Expense Found",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ))
                      : ExpenseData(
                          TransList: TransList,
                          RoomKey: widget.roomKey,
                          Email: _email,
                          Token: _token,
                          refreshMemberTrans: _initialisation,
                          locked: locked,
                          expenseCategory: expenseCategory,
                          subCategory: subCategory,
                          index: scrollToExpense,
                          scrollController: _scrollController,
                        )),
            ),
          );
  }

  Widget _buildUpdateDialog(BuildContext context, PaymentDataEach data) {
    return StatefulBuilder(builder: (context, setState) {
      bool isNegative = data.amount < 0;
      _paytoMemberAmt.text = data.amount.abs().toStringAsFixed(2);
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                          child: Text(
                            "Change Amount Paid",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          key: _updatePayToMemberAmount,
                          controller: _paytoMemberAmt,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 18),
                          autocorrect: false,
                          validator: (value) {
                            RegExp validateNumber =
                                RegExp(r'^\d+(\.\d{1,2})?$');
                            if (!validateNumber
                                .hasMatch(_paytoMemberAmt.text)) {
                              return "Enter Valid Amount";
                            }
                            double parsedAmt =
                                double.parse(_paytoMemberAmt.text);
                            if (parsedAmt == 0) {
                              return "Amount can't be zero";
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
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 43,
                              width: MediaQuery.of(context).size.width * 0.3,
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
                                    if (_updatePayToMemberAmount.currentState!
                                        .validate()) {
                                      buildShowDialog(context);
                                      await _updatePayToMember(
                                          context,
                                          data.objID,
                                          "0",
                                          (isNegative ? "-" : "") +
                                              _paytoMemberAmt.text,
                                          data);
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                      if (this.mounted) {
                                        context.pop();
                                      }
                                    }
                                  }),
                            ),
                            SizedBox(
                              height: 43,
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: OutlinedButton(
                                  child: Text(
                                    "Delete",
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
                                    buildShowDialog(context);
                                    await _updatePayToMember(
                                        context,
                                        data.objID,
                                        "1",
                                        (isNegative ? "-" : "") +
                                            _paytoMemberAmt.text,
                                        data);
                                    if (this.mounted) {
                                      context.pop();
                                    }
                                    if (this.mounted) {
                                      context.pop();
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ))),
          ));
    });
  }

  Widget _loadingPaymentDataShimmer(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height - 380,
        child: Shimmer.fromColors(
            baseColor: Theme.of(context).cardColor,
            highlightColor: Theme.of(context).primaryColor,
            child: ListView.builder(
              itemCount: 16,
              itemBuilder: (_, __) => Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 20.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: 180,
                          height: 20.0,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  Widget _showPaymentData(
      BuildContext context, PaymentDataEach eachPayment, int index) {
    bool isNegative = eachPayment.amount < 0;
    return InkWell(
      onTap: () async {
        if (!isClear && eachPayment.senderEmail == _email) {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                _buildUpdateDialog(context, eachPayment),
          );
        }
      },
      child: Card(
        elevation: 1.0,
        shadowColor: Theme.of(context).primaryColor,
        color: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).primaryColor.withAlpha(80)),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.80,
                child: isNegative
                    ? Text(
                        (eachPayment.receiverEmail == _email
                                ? "You"
                                : (parseFirstName(eachPayment.receiver) +
                                    " has")) +
                            " paid " +
                            (eachPayment.senderEmail == _email ? "you " : "") +
                            "₹ " +
                            commaSeperator(
                                    eachPayment.amount.toStringAsFixed(2))
                                .replaceFirst("-", "") +
                            (eachPayment.senderEmail == _email
                                ? ""
                                : (" to " +
                                    parseFirstName(eachPayment.sender))) +
                            " on " +
                            eachPayment.creationDate,
                        style: const TextStyle(
                          overflow: TextOverflow.clip,
                          fontSize: 18,
                        ),
                      )
                    : Text(
                        (eachPayment.senderEmail == _email
                                ? "You"
                                : (parseFirstName(eachPayment.sender) +
                                    " has")) +
                            " paid " +
                            (eachPayment.receiverEmail == _email
                                ? "you "
                                : "") +
                            "₹ " +
                            commaSeperator(
                                    eachPayment.amount.toStringAsFixed(2))
                                .replaceFirst("-", "") +
                            (eachPayment.receiverEmail == _email
                                ? ""
                                : (" to " +
                                    parseFirstName(eachPayment.receiver))) +
                            " on " +
                            eachPayment.creationDate,
                        style: const TextStyle(
                          overflow: TextOverflow.clip,
                          fontSize: 18,
                        ),
                      ),
              ),
              Positioned(
                right: 6,
                child: !isClear && eachPayment.senderEmail == _email
                    ? Icon(
                        Icons.edit,
                        size: 24,
                      )
                    : SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentDataWidget() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Text(
                "From",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 65,
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: roomMembers.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return InkWell(
                          onTap: () {
                            if (this.mounted) {
                              setState(() {
                                membersListIndexS = index - 1;
                              });
                            }
                          },
                          child: Card(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: index - 1 == membersListIndexS
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).cardColor),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: SizedBox(
                                width: 60,
                                height: 40,
                                child: Center(
                                  child: Text(
                                    "All",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              )));
                    } else {
                      return InkWell(
                        child: Card(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: membersListIndexS != -1 &&
                                        membersListEmail[index - 1] ==
                                            membersListEmail[membersListIndexS]
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CachedNetworkImage(
                                  httpHeaders: {
                                    'Access-Control-Allow-Origin': '*'
                                  },
                                  imageUrl: roomMembers[index].pic.length == 0
                                      ? addCorsinImage(global.unknown_avatar_id)
                                      : addCorsinImage(roomMembers[index].pic),
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 50.0,
                                    height: 50.0,
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
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                Text(
                                  roomMembers[index].name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          if (this.mounted) {
                            setState(() {
                              membersListIndexS = index - 1;
                            });
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "To",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                width: 5,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 45,
                  height: 65,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: roomMembers.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return InkWell(
                              onTap: () {
                                if (this.mounted) {
                                  setState(() {
                                    membersListIndexR = index - 1;
                                  });
                                }
                              },
                              child: Card(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: index - 1 == membersListIndexR
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).cardColor),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: SizedBox(
                                    width: 60,
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        "All",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )));
                        } else {
                          return InkWell(
                            child: Card(
                              elevation: 1.4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: membersListIndexR != -1 &&
                                            membersListEmail[index - 1] ==
                                                membersListEmail[
                                                    membersListIndexR]
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).cardColor),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    CachedNetworkImage(
                                      httpHeaders: {
                                        'Access-Control-Allow-Origin': '*'
                                      },
                                      imageUrl:
                                          roomMembers[index].pic.length == 0
                                              ? addCorsinImage(
                                                  global.unknown_avatar_id)
                                              : addCorsinImage(
                                                  roomMembers[index].pic),
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        width: 50.0,
                                        height: 50.0,
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
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      roomMembers[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            onTap: () {
                              if (this.mounted) {
                                setState(() {
                                  membersListIndexR = index - 1;
                                });
                              }
                            },
                          );
                        }
                      })),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 100,
            height: 40,
            child: OutlinedButton(
              child: Text(
                "Search",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: themeProvider.isDarkTheme
                        ? Colors.white
                        : Colors.black),
              ),
              onPressed: () async {
                await retrievePaymentData();
              },
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Scrollbar(
            radius: Radius.circular(10.0),
            thickness: 5.5,
            child: showAllTransactionData
                ? (loadingPaymentData
                    ? (allTransactionData.isEmpty
                        ? Center(
                            child: Text(
                              "No Results Found!",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Total Amount Paid: ₹ " +
                                    commaSeperator(double.parse(paymentTotalALL)
                                        .toStringAsFixed(2)),
                              ),
                              SingleChildScrollView(
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height - 420,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.separated(
                                        separatorBuilder: (context, index) =>
                                            SizedBox(
                                              height: 5,
                                            ),
                                        shrinkWrap: true,
                                        physics: ScrollPhysics(),
                                        itemCount: allTransactionData.length,
                                        itemBuilder: (BuildContext context,
                                            int payIndex) {
                                          return _showPaymentData(
                                              context,
                                              allTransactionData[payIndex],
                                              payIndex);
                                        }),
                                  ),
                                ),
                              ),
                            ],
                          ))
                    : _loadingPaymentDataShimmer(context))
                : (loadingFilteredPaymentData
                    ? _loadingPaymentDataShimmer(context)
                    : (paymentData.isEmpty
                        ? Center(
                            child: Text(
                              "No Results Found!",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Text(
                                  "Total Amount Paid: ₹ " +
                                      commaSeperator(
                                          paymentTotal.toStringAsFixed(2)),
                                ),
                                SingleChildScrollView(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height -
                                        420,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: ListView.separated(
                                          separatorBuilder: (context, index) =>
                                              SizedBox(
                                                height: 5,
                                              ),
                                          shrinkWrap: true,
                                          physics: ScrollPhysics(),
                                          itemCount: paymentData.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return _showPaymentData(context,
                                                paymentData[index], index);
                                          }),
                                    ),
                                  ),
                                ),
                              ]))),
          )
        ],
      ),
    );
  }

  Widget expenseByCategory() {
    return Center(
      child: dataMap.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 3.3,
              ),
            )
          : SizedBox(
              height: 50 * expenseCategory.length * 1.0,
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(isVisible: false),
                      primaryYAxis: NumericAxis(isVisible: false),
                      tooltipBehavior: TooltipBehavior(
                          enable: true,
                          header: "",
                          format: "point.x : ₹ point.y"),
                      plotAreaBorderWidth: 0,
                      series: <BarSeries<ChartData, String>>[
                        BarSeries<ChartData, String>(
                            dataSource: dataMap,
                            borderRadius: BorderRadius.circular(20),
                            xValueMapper: (ChartData data, _) => data.type,
                            yValueMapper: (ChartData data, _) =>
                                data.amount as num,
                            isVisibleInLegend: true,
                            width: 0.3,
                            pointColorMapper: (ChartData data, _) =>
                                global.colorsList[_],
                            dataLabelMapper: (datum, index) =>
                                datum.type +
                                "\n₹ " +
                                datum.amount.toStringAsFixed(2),
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true))
                      ])),
            ),
    );
  }

  Widget expenseByUser() {
    return Center(
      child: dataMapByUser.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 3.3,
              ),
            )
          : SizedBox(
              height: 53 * membersListEmail.length * 1.0,
              child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(isVisible: false),
                      primaryYAxis: NumericAxis(isVisible: false),
                      tooltipBehavior: TooltipBehavior(
                          enable: true,
                          header: "",
                          format: "point.x : ₹ point.y"),
                      plotAreaBorderWidth: 0,
                      series: <BarSeries<ChartData, String>>[
                        BarSeries<ChartData, String>(
                          dataSource: dataMapByUser,
                          borderRadius: BorderRadius.circular(20),
                          width: 0.3,
                          xValueMapper: (ChartData data, _) => data.name,
                          yValueMapper: (ChartData data, _) => data.amount,
                          isVisibleInLegend: true,
                          pointColorMapper: (ChartData data, _) =>
                              global.colorsList[_],
                          dataLabelMapper: (datum, index) =>
                              datum.name +
                              "\n₹ " +
                              datum.amount.toStringAsFixed(2),
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        )
                      ])),
            ),
    );
  }

  Widget expenseGraphByIndex() {
    if (indexGraph == 0) {
      return expenseByCategory();
    } else {
      return expenseByUser();
    }
  }

  Widget showChart() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: loaded
          ? SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SingleChildScrollView(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 45,
                          child: ListView.separated(
                              separatorBuilder: (context, index) => SizedBox(
                                    width: 8,
                                  ),
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              itemCount: graphs.length,
                              itemBuilder: (BuildContext context, int index) {
                                return SizedBox(
                                  height: 40,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(13.0),
                                      ),
                                      side: BorderSide(
                                          color: indexGraph == index
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey.shade700),
                                    ),
                                    onPressed: () {
                                      if (this.mounted) {
                                        setState(() {
                                          indexGraph = index;
                                        });
                                      }
                                    },
                                    child: Text(
                                      graphs[index],
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: themeProvider.isDarkTheme
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                      expenseGraphByIndex()
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
    );
  }

  Widget chooseFromBottomNavigator(int dash) {
    if (!locked) {
      if (dash == 0) {
        return homeWidget();
      } else if (dash == 1) {
        return addFriendWidget();
      } else if (dash == 2) {
        initChart();
        return showChart();
      } else {
        return paymentDataWidget();
      }
    } else {
      if (dash == 0) {
        return homeWidget();
      } else if (dash == 1) {
        initChart();
        return showChart();
      } else {
        return paymentDataWidget();
      }
    }
  }

  splitManuallyWidget(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    GlobalKey<FormState> _manualSplitKeysplitManuallyWidget =
        GlobalKey<FormState>();
    List<TextEditingController> amountController = [];
    for (int i = 0; i < manualSplitAmount.length; i++) {
      amountController.add(TextEditingController(text: "0"));
    }
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
                              key: _manualSplitKeysplitManuallyWidget,
                              child: SizedBox(
                                height: min(75.0 * manualSplitAmount.length,
                                    MediaQuery.of(context).size.height * 0.8),
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: manualSplitAmount.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    String key = "";
                                    if (addExpenseTo.isEmpty) {
                                      if (index == activeMembersEmail.length) {
                                        key = _email;
                                      } else {
                                        key = activeMembersEmail[index];
                                      }
                                    } else {
                                      if (index == addExpenseTo.length) {
                                        key = _email;
                                      } else {
                                        key = addExpenseTo[index];
                                      }
                                    }
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
                                                imageUrl: addCorsinImage(
                                                    manualSplitMembers[key]![
                                                                    'Pic']
                                                                .length ==
                                                            0
                                                        ? global
                                                            .unknown_avatar_id
                                                        : manualSplitMembers[
                                                            key]!['Pic']),
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
                                                    manualSplitMembers[key]![
                                                        'Name'],
                                                    Icons.person_outlined),
                                                child: SizedBox(
                                                  width: 130,
                                                  child: Text(
                                                    manualSplitMembers[key]![
                                                        'Name'],
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    counterText: "",
                                                    errorStyle: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                  validator: (value) {
                                                    if (key == _email) {
                                                      if (amountController[
                                                                  index]
                                                              .text ==
                                                          "0") {
                                                        manualSplitAmount[
                                                            key] = double.parse(
                                                                amountController[
                                                                        index]
                                                                    .text) *
                                                            100 /
                                                            100;
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
                                                      manualSplitAmount[
                                                          key] = double.parse(
                                                              amountController[
                                                                      index]
                                                                  .text) *
                                                          100 /
                                                          100;
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
                                          if (_manualSplitKeysplitManuallyWidget
                                              .currentState!
                                              .validate()) {
                                            AddExpenseManual(context);
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

  updateRoomNameDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    GlobalKey<FormState> _roomUpdateKeyRooms = GlobalKey<FormState>();
    final _roomNameController = TextEditingController();
    _roomNameController.setText(roomName.text);

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
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          Form(
                            key: _roomUpdateKeyRooms,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _roomNameController,
                                  keyboardType: TextInputType.text,
                                  maxLength: 70,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 18),
                                  autocorrect: false,
                                  validator: (value) {
                                    RegExp validateText =
                                        RegExp(r'\b[\w]{4,}\b');
                                    if (!validateText
                                        .hasMatch(_roomNameController.text)) {
                                      return "Enter Valid Room Name";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    counterText: "",
                                    contentPadding: EdgeInsets.all(8.0),
                                    hintText: "Enter Room Name",
                                    errorStyle: TextStyle(fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      height: 43,
                                      width: 130,
                                      child: OutlinedButton(
                                          child: Text(
                                            "Cancel",
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
                                                color: Colors.redAccent),
                                          ),
                                          onPressed: () {
                                            if (this.mounted) {
                                              context.pop();
                                            }
                                          }),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 43,
                                      width: 130,
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
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                          onPressed: () async {
                                            if (_roomUpdateKeyRooms
                                                .currentState!
                                                .validate()) {
                                              await updateRoomName(context,
                                                  _roomNameController.text);
                                            }
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ]))));
          });
        });
  }

  void pickDateRange() async {
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
      }
    }
  }

  getFilterResult() {
    List<dynamic> dataToBeFiltered = [];
    DateFormat dateFormat = DateFormat(global.dateTimeFormat);

    if (expenseTitle == "All Expense") {
      dataToBeFiltered = [...allExpenseList];
    } else {
      TransList.clear();
      allExpenseList.forEach((element) {
        if (roomMembers[curMemberIndex].email ==
            crypto.decrypt(element['Email'])) {
          TransList.add(element);
        }
      });
      dataToBeFiltered = [...TransList];
    }

    double leftAmount = _currentAmountValues.start.round().toDouble();
    double rightAmount = _currentAmountValues.end.round().toDouble();
    TransList.clear();

    if (showFilterResult) {
      dataToBeFiltered.forEach((element) {
        DateTime transDate = dateFormat.parse(
            crypto.decrypt(element['Date']).substring(0, 12) + "00:00:00");
        double amt = double.parse(crypto.decrypt(element['Amount']));
        if ((_searchText.text.length > 0 &&
                (crypto
                        .decrypt(element['Purpose'])
                        .toLowerCase()
                        .contains(_searchText.text.toLowerCase()) ||
                    crypto
                        .decrypt(element["Amount"])
                        .toLowerCase()
                        .contains(_searchText.text.toLowerCase()))) ||
            _searchText.text.length == 0) {
          if ((dateRange.start.isAtSameMomentAs(transDate) ||
                  dateRange.start.isBefore(transDate)) &&
              (dateRange.end.isAtSameMomentAs(transDate) ||
                  dateRange.end.isAfter(transDate)) &&
              amt >= leftAmount &&
              amt <= rightAmount) {
            if (filtercategoryIndex.isEmpty ||
                filtercategoryIndex.contains(
                    expenseCategory.indexOf(crypto.decrypt(element['Type'])))) {
              if (showExpenseYouAreIn) {
                List<dynamic> partialExpense = element["members"];
                if (partialExpense.isEmpty) {
                  TransList.add(element);
                } else {
                  for (int i = 0; i < partialExpense.length; i++) {
                    if (crypto.decrypt(partialExpense[i]['Email']) == _email) {
                      TransList.add(element);
                      break;
                    }
                  }
                }
              } else {
                TransList.add(element);
              }
            }
          }
        }
      });
    } else if (_searchText.text.isNotEmpty) {
      dataToBeFiltered.forEach((element) {
        if (crypto
                .decrypt(element['Purpose'])
                .toLowerCase()
                .contains(_searchText.text.toLowerCase()) ||
            crypto
                .decrypt(element["Amount"])
                .toLowerCase()
                .contains(_searchText.text.toLowerCase())) {
          TransList.add(element);
        }
      });
    } else {
      TransList = [...dataToBeFiltered];
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  Widget _askToCloseRoom(BuildContext context, String amount) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Do you want to close room?",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(
                      height: 20,
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
                                  side: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                ),
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: themeProvider.isDarkTheme
                                          ? Colors.white
                                          : Colors.black),
                                ),
                                onPressed: () async {
                                  await PayToMember(
                                      context, amount, true, true);
                                }),
                          ),
                          SizedBox(
                            height: 43,
                            width: 100,
                            child: OutlinedButton(
                                child: Text(
                                  "No",
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
                                  await PayToMember(
                                      context, amount, false, true);
                                }),
                          ),
                        ]),
                  ]),
            )),
      );
    });
  }

  Widget _buildSettleExpenseDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isInGain = roomMembers[selfIndex].current > 0;
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Settle Expense",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Form(
                  key: _formKeyRooms,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: roomMembers.length,
                          itemBuilder: (BuildContext context, int index) {
                            bool isMemberIngain =
                                roomMembers[index].current > 0;
                            if (membersListEmail[index] == _email ||
                                roomMembers[index].done ||
                                isMemberIngain == isInGain ||
                                roomMembers[index].current.abs() < 0.1) {
                              return SizedBox();
                            } else {
                              return InkWell(
                                child: memberExpenseCard(context, index),
                                onTap: () {
                                  if (this.mounted) {
                                    setState(
                                      () {
                                        membersListIndex = index;
                                      },
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          isInGain
                              ? ("Member can pay you ₹ " +
                                  commaSeperator(min(
                                          roomMembers[selfIndex].current,
                                          -roomMembers[membersListIndex]
                                              .current)
                                      .toStringAsFixed(2)))
                              : ("You can pay ₹ " +
                                  commaSeperator(min(
                                          -roomMembers[selfIndex].current,
                                          roomMembers[membersListIndex].current)
                                      .toStringAsFixed(2))),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _amountPaid,
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 18),
                        autocorrect: false,
                        onSaved: (str) {
                          String isAmountFull = (!isInGain
                                  ? min(-roomMembers[selfIndex].current,
                                      roomMembers[membersListIndex].current)
                                  : min(roomMembers[selfIndex].current,
                                      -roomMembers[membersListIndex].current))
                              .toStringAsFixed(2);
                          if (double.parse(isAmountFull) -
                                  double.parse(_amountPaid.text) <
                              0.1) {
                            _amountPaid.text = isAmountFull;
                            showToast(
                                context,
                                (isInGain ? "Paid" : "Paying") +
                                    " Full Amount ₹ " +
                                    _amountPaid.text,
                                Icons.payment);
                          }
                        },
                        validator: (value) {
                          RegExp validateNumber = RegExp(r'^\d+(\.\d{1,2})?$');
                          if (!validateNumber.hasMatch(_amountPaid.text)) {
                            return "Enter Valid Amount";
                          }
                          double parsedAmt = double.parse(_amountPaid.text);
                          if (parsedAmt == 0) {
                            return "Amount can't be zero";
                          }
                          if (isInGain) {
                            if (roomMembers[selfIndex].current < parsedAmt ||
                                parsedAmt >
                                    -roomMembers[membersListIndex].current) {
                              return "Amount paid exceeds the amount owed";
                            }
                          } else {
                            if (-roomMembers[selfIndex].current < parsedAmt ||
                                parsedAmt >
                                    roomMembers[membersListIndex].current) {
                              return "Amount paid is greater than what you owe";
                            }
                          }

                          return null;
                        },
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(8.0),
                          counterText: "",
                          hintText: "Enter Amount",
                          labelText: "Amount",
                          errorStyle: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.32,
                      child: OutlinedButton(
                        child: Text(
                          "Add",
                          style: TextStyle(
                              fontSize: 18,
                              color: themeProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        onPressed: () async {
                          _formKeyRooms.currentState!.save();
                          if (_formKeyRooms.currentState!.validate()) {
                            String isAmountFull = (!isInGain
                                    ? min(-roomMembers[selfIndex].current,
                                        roomMembers[membersListIndex].current)
                                    : min(roomMembers[selfIndex].current,
                                        -roomMembers[membersListIndex].current))
                                .toStringAsFixed(2);
                            if (double.parse(isAmountFull) -
                                        double.parse(_amountPaid.text) <
                                    0.1 &&
                                roomMembers[selfIndex].current *
                                            (!isInGain ? -1 : 1) -
                                        double.parse(_amountPaid.text) <
                                    0.1) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return _askToCloseRoom(
                                        context,
                                        (isInGain ? "-" : "") +
                                            _amountPaid.text);
                                  });
                            } else {
                              await PayToMember(
                                  context,
                                  (isInGain ? "-" : "") + _amountPaid.text,
                                  false,
                                  false);
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          side:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.32,
                      child: OutlinedButton(
                        child: Text(
                          "Close",
                          style: TextStyle(
                              fontSize: 18,
                              color: themeProvider.isDarkTheme
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        onPressed: () async {
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          side: BorderSide(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final internetConnProvider =
        Provider.of<InternetconnectivityProvider>(context, listen: false);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
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
                      _searchText.setText(s);
                    });
                    getFilterResult();
                  },
                )
              : Text(roomName.text),
          actions: loaded && dash == 0
              ? [
                  ...(!searchTrigger
                      ? [
                          isClear
                              ? SizedBox()
                              : InkWell(
                                  onTap: () async {
                                    await updateRoomNameDialog(context);
                                  },
                                  child: Icon(Icons.edit_outlined),
                                ),
                          SizedBox(
                            width: 16,
                          ),
                          isRoomActive
                              ? InkWell(
                                  onTap: () async {
                                    await Share.share("Join " +
                                        roomName.text +
                                        "\nRoom Key: " +
                                        widget.roomKey +
                                        "\n" +
                                        roomLink);
                                  },
                                  child: Icon(Icons.share_outlined),
                                )
                              : SizedBox(),
                          SizedBox(
                            width: 12,
                          ),
                        ]
                      : []),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        searchTrigger = !searchTrigger;
                      });
                      if (!searchTrigger) {
                        _searchText.setText("");
                        getFilterResult();
                      }
                    },
                    child: Icon(
                      Icons.search,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  InkWell(
                    onTap: () async {
                      filterDialog = _scaffoldKey.currentState!.isEndDrawerOpen;
                      filterDialog = !filterDialog;

                      if (filterDialog) {
                        _scaffoldKey.currentState!.openEndDrawer();
                      } else {
                        _scaffoldKey.currentState!.closeEndDrawer();
                      }
                    },
                    child: Icon(showFilterResult
                        ? Icons.filter_alt_off
                        : Icons.filter_alt_outlined),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                ]
              : (((dash == 2 && locked) || (dash == 3 && !locked))
                  ? (showAllTransactionData
                      ? []
                      : [
                          InkWell(
                              onTap: () {
                                if (this.mounted) {
                                  setState(() {
                                    showAllTransactionData = true;
                                    paymentData.clear();
                                    membersListIndexR = -1;
                                    membersListIndexS = -1;
                                  });
                                }
                              },
                              child: Icon(Icons.refresh_outlined))
                        ])
                  : []),
        ),
        endDrawer: dash > 0
            ? null
            : Scrollbar(
                child: Drawer(
                  backgroundColor: themeProvider.isDarkTheme
                      ? Theme.of(context).scaffoldBackgroundColor
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amount",
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RangeSlider(
                              values: _currentAmountValues,
                              overlayColor: WidgetStateProperty.all(
                                  Theme.of(context).primaryColor),
                              max: maxSpentAmount,
                              divisions: 8,
                              labels: RangeLabels(
                                _currentAmountValues.start.round().toString(),
                                _currentAmountValues.end.round().toString(),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _currentAmountValues = values;
                                  _amountRangeValues[0].setText(
                                      values.start.round().toInt().toString());
                                  _amountRangeValues[1].setText(
                                      values.end.round().toInt().toString());
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: TextFormField(
                                    controller: _amountRangeValues[0],
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      contentPadding: EdgeInsets.all(8.0),
                                      prefixText: "₹ ",
                                    ),
                                    onChanged: (String s) {
                                      if (this.mounted) {
                                        setState(() {
                                          if (s.length > 0) {
                                            _currentAmountValues = RangeValues(
                                                min(double.parse(s),
                                                    _currentAmountValues.end),
                                                _currentAmountValues.end);
                                            if (double.parse(s) >
                                                _currentAmountValues.end) {
                                              showToast(
                                                  context,
                                                  "Amount should be not greater than end value",
                                                  Icons.warning_outlined);
                                            }
                                          }
                                          _amountRangeValues[0].text = s;
                                          _amountRangeValues[0].selection =
                                              TextSelection.collapsed(
                                                  offset: _amountRangeValues[0]
                                                      .text
                                                      .length);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Text("-", style: TextStyle(fontSize: 16)),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: TextFormField(
                                    controller: _amountRangeValues[1],
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      contentPadding: EdgeInsets.all(8.0),
                                      prefixText: "₹ ",
                                    ),
                                    onChanged: (String s) {
                                      if (this.mounted) {
                                        setState(() {
                                          if (s.length > 0) {
                                            _currentAmountValues = RangeValues(
                                                _currentAmountValues.start,
                                                max(
                                                    double.parse(s),
                                                    _currentAmountValues
                                                        .start));
                                            if (double.parse(s) >
                                                _currentAmountValues.end) {
                                              showToast(
                                                  context,
                                                  "Amount should be not less than start value",
                                                  Icons.warning_outlined);
                                            }
                                          }
                                          _amountRangeValues[1].text = s;
                                          _amountRangeValues[1].selection =
                                              TextSelection.collapsed(
                                                  offset: _amountRangeValues[1]
                                                      .text
                                                      .length);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(),
                        SizedBox(
                          height: 8,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Show Expenses You Are In",
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showExpenseYouAreIn = true;

                                    if (this.mounted) {
                                      setState(() {});
                                    }
                                  },
                                  child: Card(
                                    color: themeProvider.isDarkTheme
                                        ? Theme.of(context)
                                            .scaffoldBackgroundColor
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: showExpenseYouAreIn
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).cardColor),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("Yes"),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    showExpenseYouAreIn = false;

                                    if (this.mounted) {
                                      setState(() {});
                                    }
                                  },
                                  child: Card(
                                    color: themeProvider.isDarkTheme
                                        ? Theme.of(context)
                                            .scaffoldBackgroundColor
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: !showExpenseYouAreIn
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).cardColor),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text("No"),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Divider(),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Date",
                              style: TextStyle(
                                  fontSize: 21, fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                                onPressed: pickDateRange,
                                icon: Icon(Icons.date_range)),
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: pickDateRange,
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
                                    onTap: pickDateRange,
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
                          height: 8,
                        ),
                        Divider(),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Filter by Category",
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 53 *
                              (expenseCategory.length / 2 +
                                  expenseCategory.length % 2),
                          child: MasonryGridView.count(
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            itemCount: expenseCategory.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  if (filtercategoryIndex.contains(index)) {
                                    filtercategoryIndex.remove(index);
                                  } else {
                                    filtercategoryIndex.add(index);
                                  }

                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Card(
                                  color: themeProvider.isDarkTheme
                                      ? Theme.of(context)
                                          .scaffoldBackgroundColor
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color:
                                            filtercategoryIndex.contains(index)
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).cardColor),
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(expenseCategory[index]),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 45,
                          child: OutlinedButton(
                            child: Text(
                              "Apply",
                              style: TextStyle(
                                color: themeProvider.isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () {
                              showFilterResult = true;
                              getFilterResult();
                              _scaffoldKey.currentState!.closeEndDrawer();
                              if (this.mounted) {
                                setState(() {});
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          height: 45,
                          child: OutlinedButton(
                            child: Text(
                              "Clear Filter",
                              style: TextStyle(
                                color: themeProvider.isDarkTheme
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13.0),
                              ),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () {
                              filtercategoryIndex.clear();
                              _amountRangeValues[0].text = "0";
                              _amountRangeValues[1].text =
                                  maxSpentAmount.toInt().toString();
                              _currentAmountValues =
                                  RangeValues(0, maxSpentAmount);
                              showExpenseYouAreIn = false;
                              showFilterResult = false;
                              dateRange = DateTimeRange(
                                  start: new DateTime(DateTime.now().year,
                                      DateTime.now().month - 6),
                                  end: DateTime.now());
                              TransList = [...allExpenseList];
                              getFilterResult();
                              if (this.mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        body: PopScope(
            canPop: false,
            onPopInvoked: ((didPop) {
              if (didPop) {
                return;
              }
              Map<String, dynamic> objectToBeReturned = {};
              objectToBeReturned["contribution"] =
                  roomMembers[selfIndex].expense +
                      roomMembers[selfIndex].totalSplitExpense;
              objectToBeReturned["isClosed"] = isRoomActive;
              objectToBeReturned["isDone"] = roomMembers[selfIndex].done;
              objectToBeReturned["spent"] = roomMembers[selfIndex].yourExpense;
              objectToBeReturned["member"] = roomMembers.length;
              objectToBeReturned["roomName"] = roomName.text;
              context.pop(objectToBeReturned);
            }),
            child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: chooseFromBottomNavigator(dash))),
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
                onTap: (index) => setState(() {
                      dash = index;
                    }),
                items: (!locked
                    ? [
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.home,
                            size: 27,
                          ),
                          label: "",
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.person_add,
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
                            Icons.transfer_within_a_station_rounded,
                            size: 27,
                          ),
                          label: "",
                        )
                      ]
                    : [
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.home,
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
                            Icons.transfer_within_a_station_rounded,
                            size: 27,
                          ),
                          label: "",
                        )
                      ])),
        floatingActionButton: dash == 0
            ? (isRoomActive
                ? FloatingActionButton(
                    onPressed: () {
                      expenseDate = DateTime.now();
                      showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    child: Padding(
                                      padding:
                                          MediaQuery.of(context).viewInsets,
                                      child: SizedBox(
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
                                                            .width *
                                                        0.9))
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                        height: isClear
                                            ? 60
                                            : ((locked ||
                                                    membersListName.length <=
                                                        1 ||
                                                    membersListIndex == -1)
                                                ? 120
                                                : 170),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  Icons.close,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                                title: const Text(
                                                    "Close Room Request"),
                                                onTap: () async {
                                                  if (this.mounted) {
                                                    buildShowDialog(context);
                                                  }
                                                  await closeRoomRequest();
                                                  if (this.mounted) {
                                                    context.pop();
                                                  }
                                                  if (this.mounted) {
                                                    context.pop();
                                                  }
                                                },
                                              ),
                                              !isClear &&
                                                      membersListName.length >
                                                          1 &&
                                                      membersListIndex != -1
                                                  ? ListTile(
                                                      leading: Icon(
                                                        Icons.money,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      title: const Text(
                                                          "Settle Expense"),
                                                      onTap: () {
                                                        showModalBottomSheet(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return _buildSettleExpenseDialog(
                                                                  context);
                                                            });
                                                      })
                                                  : SizedBox(),
                                              !(isClear || locked)
                                                  ? ListTile(
                                                      leading: Icon(
                                                        Icons.add,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      title: const Text(
                                                          "Add Expense"),
                                                      onTap: () {
                                                        showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                return Dialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12.0)),
                                                                  child:
                                                                      Container(
                                                                    width: kIsWeb
                                                                        ? max(
                                                                            MediaQuery.of(context).size.width *
                                                                                0.5,
                                                                            min(
                                                                                400,
                                                                                MediaQuery.of(context).size.width *
                                                                                    0.9))
                                                                        : MediaQuery.of(context).size.width *
                                                                            0.9,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            18.0),
                                                                        child: Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              Text(
                                                                                "Add Expense",
                                                                                style: TextStyle(fontSize: 22),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5,
                                                                              ),
                                                                              Form(
                                                                                key: _formKeyRooms,
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
                                                                                              RegExp validateNumber = RegExp(r'^\d+(\.\d{1,2})?$');
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
                                                                                                  color: Theme.of(context).dialogBackgroundColor,
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    side: BorderSide(color: roomExpenseCategoryIndex == index ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
                                                                                                    borderRadius: BorderRadius.circular(10.0),
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
                                                                                                        roomExpenseCategoryIndex = index;
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
                                                                                    SizedBox(
                                                                                      height: 7,
                                                                                    ),
                                                                                    subCategory[roomExpenseCategoryIndex].length > 0
                                                                                        ? SizedBox(
                                                                                            width: MediaQuery.of(context).size.width * 0.96,
                                                                                            height: 70,
                                                                                            child: ListView.builder(
                                                                                              scrollDirection: Axis.horizontal,
                                                                                              itemCount: subCategory[roomExpenseCategoryIndex].length,
                                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                                return SizedBox(
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                                    child: InkWell(
                                                                                                      child: Card(
                                                                                                        color: Theme.of(context).dialogBackgroundColor,
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                          side: BorderSide(color: (index == roomsubExpenseCategoryIndex ? Theme.of(context).primaryColor : Theme.of(context).cardColor)),
                                                                                                          borderRadius: BorderRadius.circular(10.0),
                                                                                                        ),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.all(12.0),
                                                                                                          child: Center(
                                                                                                            child: InkWell(
                                                                                                              child: Text(
                                                                                                                subCategory[roomExpenseCategoryIndex][index],
                                                                                                                style: TextStyle(
                                                                                                                  fontSize: 16,
                                                                                                                  fontWeight: FontWeight.w500,
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
                                                                                                              roomsubExpenseCategoryIndex = index;
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
                                                                                    noSplit
                                                                                        ? SizedBox()
                                                                                        : SizedBox(
                                                                                            height: 80,
                                                                                            child: ListView.builder(
                                                                                              scrollDirection: Axis.horizontal,
                                                                                              itemCount: roomMembers.length + 1,
                                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                                if (index == 0) {
                                                                                                  return InkWell(
                                                                                                    child: SizedBox(
                                                                                                      width: 85,
                                                                                                      child: Padding(
                                                                                                          padding: EdgeInsets.all(8.0),
                                                                                                          child: Card(
                                                                                                              color: Theme.of(context).dialogBackgroundColor,
                                                                                                              shape: RoundedRectangleBorder(
                                                                                                                side: BorderSide(color: addExpenseTo.isEmpty ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
                                                                                                                borderRadius: BorderRadius.circular(15.0),
                                                                                                              ),
                                                                                                              child: Padding(
                                                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                                                  child: Center(
                                                                                                                    child: Text(
                                                                                                                      "ALL",
                                                                                                                      style: TextStyle(
                                                                                                                        fontSize: 14,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  )))),
                                                                                                    ),
                                                                                                    onTap: () {
                                                                                                      addExpenseTo.clear();
                                                                                                      if (this.mounted) {
                                                                                                        setState(() {});
                                                                                                      }
                                                                                                    },
                                                                                                  );
                                                                                                } else if (roomMembers[index - 1].done || membersListEmail[index - 1] == _email) {
                                                                                                  return SizedBox();
                                                                                                } else {
                                                                                                  return InkWell(
                                                                                                    child: Padding(
                                                                                                      padding: EdgeInsets.all(8.0),
                                                                                                      child: Card(
                                                                                                        color: Theme.of(context).dialogBackgroundColor,
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                          side: BorderSide(color: findElement(addExpenseTo, roomMembers[index - 1].email) ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
                                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                                        ),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.all(5.0),
                                                                                                          child: Row(
                                                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                                                            children: [
                                                                                                              CachedNetworkImage(
                                                                                                                httpHeaders: {
                                                                                                                  'Access-Control-Allow-Origin': '*'
                                                                                                                },
                                                                                                                imageUrl: addCorsinImage(roomMembers[index - 1].pic.length == 0 ? global.unknown_avatar_id : roomMembers[index - 1].pic),
                                                                                                                progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                                                                                                                errorWidget: (context, url, error) => Container(
                                                                                                                  width: 50.0,
                                                                                                                  height: 50.0,
                                                                                                                  decoration: BoxDecoration(
                                                                                                                    shape: BoxShape.circle,
                                                                                                                    image: DecorationImage(image: AssetImage('assets/Images/unknown.jpeg'), fit: BoxFit.cover),
                                                                                                                  ),
                                                                                                                ),
                                                                                                                imageBuilder: (context, imageProvider) => Container(
                                                                                                                  width: 50.0,
                                                                                                                  height: 50.0,
                                                                                                                  decoration: BoxDecoration(
                                                                                                                    shape: BoxShape.circle,
                                                                                                                    image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ),
                                                                                                              Text(
                                                                                                                roomMembers[index - 1].name,
                                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                                style: TextStyle(
                                                                                                                  fontSize: 18,
                                                                                                                  fontWeight: FontWeight.w500,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    onTap: () {
                                                                                                      if (findElement(addExpenseTo, roomMembers[index - 1].email)) {
                                                                                                        addExpenseTo.remove(roomMembers[index - 1].email);
                                                                                                      } else {
                                                                                                        addExpenseTo.add(roomMembers[index - 1].email);

                                                                                                        if (addExpenseTo.length == roomMembers.length - roomClosedCount - 1) {
                                                                                                          addExpenseTo.clear();
                                                                                                        }
                                                                                                      }
                                                                                                      if (this.mounted) {
                                                                                                        setState(() {});
                                                                                                      }
                                                                                                    },
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                            ),
                                                                                          ),
                                                                                    (addExpenseTo.isEmpty && !isClosedany)
                                                                                        ? SizedBox(
                                                                                            height: 7,
                                                                                          )
                                                                                        : SizedBox(),
                                                                                    (addExpenseTo.isEmpty && !isClosedany && !splitManually && !noSplit)
                                                                                        ? Padding(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Text(
                                                                                                  "For New Members",
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 18,
                                                                                                  ),
                                                                                                ),
                                                                                                InkWell(
                                                                                                  onTap: () {
                                                                                                    if (this.mounted) {
                                                                                                      setState(() {
                                                                                                        expenseSplitWithExistingMembers = !expenseSplitWithExistingMembers;
                                                                                                      });
                                                                                                    }
                                                                                                  },
                                                                                                  child: Icon(
                                                                                                    expenseSplitWithExistingMembers ? Icons.toggle_off : Icons.toggle_on,
                                                                                                    size: 40,
                                                                                                    color: expenseSplitWithExistingMembers ? null : Theme.of(context).primaryColor,
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          )
                                                                                        : SizedBox(),
                                                                                    SizedBox(
                                                                                      height: 7,
                                                                                    ),
                                                                                    splitManually
                                                                                        ? SizedBox()
                                                                                        : Padding(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Text(
                                                                                                  "No Split",
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 18,
                                                                                                  ),
                                                                                                ),
                                                                                                InkWell(
                                                                                                  onTap: () {
                                                                                                    if (this.mounted) {
                                                                                                      setState(() {
                                                                                                        noSplit = !noSplit;
                                                                                                        if (noSplit) {
                                                                                                          splitManually = false;
                                                                                                        }
                                                                                                      });
                                                                                                    }
                                                                                                  },
                                                                                                  child: Icon(
                                                                                                    noSplit ? Icons.toggle_on : Icons.toggle_off,
                                                                                                    size: 40,
                                                                                                    color: noSplit ? Theme.of(context).primaryColor : null,
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                    SizedBox(
                                                                                      height: 7,
                                                                                    ),
                                                                                    noSplit
                                                                                        ? SizedBox()
                                                                                        : Padding(
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                                                        if (splitManually) {
                                                                                                          noSplit = false;
                                                                                                        }
                                                                                                      });
                                                                                                    }
                                                                                                  },
                                                                                                  child: Icon(
                                                                                                    splitManually ? Icons.toggle_on : Icons.toggle_off,
                                                                                                    size: 40,
                                                                                                    color: splitManually ? Theme.of(context).primaryColor : null,
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                    SizedBox(
                                                                                      height: 7,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: MediaQuery.of(context).size.width * 0.8,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(10.0),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Text(
                                                                                              DateFormat(global.dateTimeFormat_new).format(expenseDate),
                                                                                              style: TextStyle(fontSize: 18),
                                                                                            ),
                                                                                            InkWell(
                                                                                              onTap: () async {
                                                                                                DateTime? dateTime = await showOmniDateTimePicker(
                                                                                                  context: context,
                                                                                                  is24HourMode: false,
                                                                                                  isShowSeconds: false,
                                                                                                  initialDate: expenseDate,
                                                                                                  firstDate: DateTime(2018),
                                                                                                  lastDate: DateTime.now(),
                                                                                                  borderRadius: BorderRadius.circular(16.0),
                                                                                                );

                                                                                                if (this.mounted && dateTime != null) {
                                                                                                  setState(() {
                                                                                                    expenseDate = dateTime;
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
                                                                                                child: Text(
                                                                                                  splitManually ? "Next" : "Add",
                                                                                                  style: TextStyle(fontSize: 16, color: themeProvider.isDarkTheme ? Colors.white : Colors.black),
                                                                                                ),
                                                                                                style: OutlinedButton.styleFrom(
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(10.0),
                                                                                                  ),
                                                                                                  side: BorderSide(color: Theme.of(context).primaryColor),
                                                                                                ),
                                                                                                onPressed: () {
                                                                                                  if (noSplit) {
                                                                                                    if (_formKeyRooms.currentState!.validate()) {
                                                                                                      manualSplitAmount.clear();
                                                                                                      manualSplitAmount[_email] = (double.parse(_amt.text) * 100) / 100;
                                                                                                      AddExpenseManual(context);
                                                                                                    }
                                                                                                  } else if (splitManually) {
                                                                                                    RegExp validateText = RegExp(r'\b[\w]+\b');
                                                                                                    if (!validateText.hasMatch(_purpose.text)) {
                                                                                                      showToast(context, "Enter Valid Purpose", Icons.warning_outlined);
                                                                                                    } else {
                                                                                                      manualSplitAmount.clear();
                                                                                                      if (addExpenseTo.isEmpty) {
                                                                                                        manualSplitMembers.forEach((k, v) {
                                                                                                          manualSplitAmount[k] = 0;
                                                                                                        });
                                                                                                      } else {
                                                                                                        addExpenseTo.forEach((element) {
                                                                                                          manualSplitAmount[element] = 0;
                                                                                                        });
                                                                                                      }

                                                                                                      manualSplitAmount[_email] = 0;
                                                                                                      splitManuallyWidget(context);
                                                                                                    }
                                                                                                  } else {
                                                                                                    AddExpense(context);
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
                                                      })
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ));
                              },
                            );
                          });
                    },
                    child: Icon(
                      Icons.edit,
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
                  )
                : null)
            : null);
  }
}

class ExpenseData extends StatefulWidget {
  final List<dynamic> TransList;
  final String RoomKey;
  final String Email;
  final String Token;
  final bool locked;
  final List<dynamic> expenseCategory;
  final List<List<dynamic>> subCategory;
  final Function refreshMemberTrans;
  final int index;
  final ScrollController scrollController;
  ExpenseData(
      {Key? key,
      required this.TransList,
      required this.RoomKey,
      required this.Email,
      required this.Token,
      required this.refreshMemberTrans,
      required this.locked,
      required this.expenseCategory,
      required this.subCategory,
      required this.index,
      required this.scrollController})
      : super(key: key);

  @override
  State<ExpenseData> createState() => _ExpenseDataState();
}

class _ExpenseDataState extends State<ExpenseData> {
  final TextEditingController _purpose = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  int roomExpenseCategoryIndex = -1;
  int roomSubExpenseCategoryIndex = -1;
  GlobalKey<FormState> _updateExpenseRoom = GlobalKey<FormState>();
  AutoScrollController controller = AutoScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.minScrollExtent == controller.position.pixels) {
        widget.scrollController.animateTo(
            MediaQuery.of(context).size.height * 0.2,
            duration: Duration(seconds: 1),
            curve: Curves.fastOutSlowIn);
      }
    });

    if (widget.index != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.scrollToIndex(widget.index,
            preferPosition: AutoScrollPosition.begin);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  updateExpenseManual(List<dynamic> memberExpense, String id, String type,
      int typeCat, int subType, int index) async {
    try {
      Map<String, String> splitMember = {};
      double updatedTotalAmount = 0;

      for (int i = 0; i < memberExpense.length; i++) {
        updatedTotalAmount += double.parse(crypto.decrypt(
            memberExpense[i]['amt'].toString().replaceFirst(".0", "")));
        splitMember[crypto.decrypt(memberExpense[i]['Email'])] = crypto
            .decrypt(memberExpense[i]['amt'].toString().replaceFirst(".0", ""));
      }

      String subCategory = "";

      if (subType != -1 &&
          widget.expenseCategory.length > typeCat &&
          widget.expenseCategory[typeCat].toString().length > 0) {
        subCategory = crypto.encrypt(widget.subCategory[typeCat][subType]);
      } else {
        subCategory = crypto.encrypt("None");
      }

      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.Email),
        'roomKey': crypto.encrypt(widget.RoomKey),
        'purpose': crypto.encrypt(_purpose.text),
        'id': crypto.encrypt(id),
        'split': crypto.encrypt(splitMember.toString()),
        'type': crypto.encrypt(type),
        'typeCat': crypto.encrypt(widget.expenseCategory[typeCat]),
        'subType': subCategory,
      };
      final response = await createHTTPreq(
          'manualSplit', http.put, widget.Token, jsonInputData, context);

      var updateMessage = jsonDecode(response.body);
      showToast(context, crypto.decrypt(updateMessage["Message"]),
          response.statusCode == 200 ? Icons.check : Icons.close);
      if (response.statusCode == 200) {
        widget.refreshMemberTrans();
        if (type == "0") {
          widget.TransList[index]["members"] = memberExpense;
          widget.TransList[index]["Amount"] =
              crypto.encrypt(updatedTotalAmount.toStringAsFixed(2));
          widget.TransList[index]["Purpose"] = jsonInputData['purpose'];
          widget.TransList[index]["Type"] = jsonInputData['typeCat'];
          widget.TransList[index]["subType"] = jsonInputData['subType'];
          widget.TransList[index]["isEdited"] = true;
          widget.TransList[index]["lastModDate"] = crypto.encrypt(
              DateFormat(global.dateTimeFormat).format(DateTime.now()));
        } else {
          widget.TransList.removeAt(index);
        }
      }
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->updateExpenseManual"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Widget splitManuallyWidget(
      BuildContext context,
      List<dynamic> memberExpenseOG,
      String purpose,
      String id,
      int roomExpenseCategory,
      int roomsubExpenseCategory,
      int index) {
    List<dynamic> memberExpense = memberExpenseOG.toList();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    GlobalKey<FormState> _manualSplitKeysplitManuallyWidget =
        GlobalKey<FormState>();
    _purpose.text = purpose;
    List<TextEditingController> amountController = [];
    for (int i = 0; i < memberExpense.length; i++) {
      amountController.add(
          TextEditingController(text: crypto.decrypt(memberExpense[i]['amt'])));
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
                        key: _manualSplitKeysplitManuallyWidget,
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
                                                if (widget
                                                        .subCategory[
                                                            roomExpenseCategory]
                                                        .length >
                                                    0) {
                                                  roomsubExpenseCategory = 0;
                                                } else {
                                                  roomsubExpenseCategory = -1;
                                                }
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
                                                          .decrypt(
                                                              memberExpense[
                                                                      index]![
                                                                  'pic'])
                                                          .length ==
                                                      0
                                                  ? global.unknown_avatar_id
                                                  : crypto.decrypt(
                                                      memberExpense[index]![
                                                          'pic'])),
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
                                                  crypto.decrypt(memberExpense[
                                                      index]!['Name']),
                                                  Icons.person_outlined),
                                              child: SizedBox(
                                                width: 130,
                                                child: Text(
                                                  crypto.decrypt(memberExpense[
                                                      index]!['Name']),
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
                                                              ['Email']) ==
                                                      widget.Email) {
                                                    if (amountController[index]
                                                                .text ==
                                                            "0" ||
                                                        amountController[index]
                                                                .text ==
                                                            "0.0") {
                                                      memberExpense[index]
                                                              ['amt'] =
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
                                                            [
                                                            'amt'] =
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
                              height: 45,
                              width: 120,
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
                              height: 45,
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
                                    if (_manualSplitKeysplitManuallyWidget
                                        .currentState!
                                        .validate()) {
                                      if (this.mounted) {
                                        buildShowDialog(context);
                                      }
                                      await updateExpenseManual(
                                          memberExpense,
                                          id,
                                          "0",
                                          roomExpenseCategory,
                                          roomsubExpenseCategory,
                                          index);
                                      for (int i = 0;
                                          i < 3 && context.canPop();
                                          i++) {
                                        if (this.mounted) {
                                          context.pop();
                                        }
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

  _updateTransaction(
      BuildContext context,
      String purpose,
      String id,
      String amount,
      String flag,
      String split,
      int roomExpenseTypeIndex,
      int roomSubExpenseTypeIndex,
      int index) async {
    try {
      Map<String, String> jsonInputData = {
        'email': crypto.encrypt(widget.Email),
        'roomKey': crypto.encrypt(widget.RoomKey),
        'purpose': crypto.encrypt(purpose),
        'amount': crypto.encrypt(amount),
        'id': crypto.encrypt(id),
        'flag': crypto.encrypt(flag),
        'split': crypto.encrypt(split),
        'type': crypto.encrypt(widget.expenseCategory[roomExpenseTypeIndex]),
        'subType': crypto.encrypt((roomSubExpenseTypeIndex != -1 &&
                widget.subCategory[roomExpenseTypeIndex].length > 0
            ? widget.subCategory[roomExpenseTypeIndex][roomSubExpenseTypeIndex]
            : "None"))
      };

      final response = await createHTTPreq(
          'transaction', http.patch, widget.Token, jsonInputData, context);

      var updateMessage = jsonDecode(response.body);
      showToast(context, crypto.decrypt(updateMessage["Message"]),
          response.statusCode == 200 ? Icons.check : Icons.close);
      if (response.statusCode == 200) {
        widget.refreshMemberTrans();
        if (flag == "0") {
          widget.TransList[index]["Purpose"] = jsonInputData['purpose'];
          widget.TransList[index]["Amount"] = jsonInputData['amount'];
          widget.TransList[index]["Type"] = jsonInputData['type'];
          widget.TransList[index]["subType"] = jsonInputData['subType'];
          widget.TransList[index]["isEdited"] = true;
          widget.TransList[index]["lastModDate"] = crypto.encrypt(
              DateFormat(global.dateTimeFormat).format(DateTime.now()));
        } else {
          widget.TransList.removeAt(index);
        }
      }
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->_updateTransaction"]);
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  Widget _buildUpdateDialog(
      BuildContext context,
      String id,
      String purpose,
      String amount,
      String split,
      String category,
      String subCategory,
      int index) {
    roomExpenseCategoryIndex = widget.expenseCategory.indexOf(category);
    roomSubExpenseCategoryIndex =
        widget.subCategory[roomExpenseCategoryIndex].indexOf(subCategory);
    _purpose.text = purpose;
    _amount.text = amount;
    return StatefulBuilder(builder: (context, setState2) {
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
                    child: Form(
                      key: _updateExpenseRoom,
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
                              RegExp validateNumber =
                                  RegExp(r'^\d+(\.\d{1,2})?$');
                              if (!validateNumber.hasMatch(_amount.text)) {
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
                          SizedBox(
                            height: 10,
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
                                              color: roomExpenseCategoryIndex ==
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
                                        roomExpenseCategoryIndex = index;
                                        roomSubExpenseCategoryIndex = 0;
                                        if (this.mounted) {
                                          setState(() {});
                                          setState2(() {});
                                        }
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          widget.subCategory[roomExpenseCategoryIndex].length >
                                  0
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.96,
                                  height: 70,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget
                                        .subCategory[roomExpenseCategoryIndex]
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
                                                            roomSubExpenseCategoryIndex
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .cardColor)),
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Center(
                                                  child: InkWell(
                                                    child: Text(
                                                      widget.subCategory[
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
                                              roomSubExpenseCategoryIndex =
                                                  index;
                                              if (this.mounted) {
                                                setState(() {});
                                                setState2(() {});
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
                            height: 10,
                          ),
                          SizedBox(
                            height: 43,
                            width: MediaQuery.of(context).size.width * 0.9,
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
                                  if (_updateExpenseRoom.currentState!
                                      .validate()) {
                                    if (this.mounted) {
                                      buildShowDialog(context);
                                    }
                                    await _updateTransaction(
                                        context,
                                        _purpose.text,
                                        id,
                                        _amount.text,
                                        "0",
                                        split,
                                        roomExpenseCategoryIndex,
                                        roomSubExpenseCategoryIndex,
                                        index);
                                    if (this.mounted) {
                                      context.pop();
                                    }
                                    if (this.mounted) {
                                      context.pop();
                                    }
                                    if (this.mounted) {
                                      context.pop();
                                    }
                                  }
                                }),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 43,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: OutlinedButton(
                                child: Text(
                                  "Cancel",
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
                                  side: BorderSide(color: Colors.redAccent),
                                ),
                                onPressed: () {
                                  if (this.mounted) {
                                    context.pop();
                                  }
                                }),
                          ),
                        ],
                      ),
                    ))),
          ));
    });
  }

  addToPersonalExpense(String objId, String split) async {
    if (this.mounted) {
      buildShowDialog(context);
    }
    try {
      Map<String, String> jsonInputData = {
        'roomKey': crypto.encrypt(widget.RoomKey),
        'email': crypto.encrypt(widget.Email),
        'id': crypto.encrypt(objId),
        'split': crypto.encrypt(split)
      };

      final response = await createHTTPreq('transaction/personalExpense',
          http.post, widget.Token, jsonInputData, context);

      var data = jsonDecode(response.body);
      showToast(context, crypto.decrypt(data["Message"]),
          response.statusCode == 200 ? Icons.check : Icons.close);
    } on Exception catch (err, stackTrace) {
      onException(err, stackTrace,
          reason: "Unknwon Error", info: ["Rooms->addToPersonalExpense"]);
    }
    if (this.mounted) {
      context.pop();
    }
  }

  bool userInPartialExpense(List<dynamic> partialExpense, String email) {
    for (int i = 0; i < partialExpense.length; i++) {
      if (crypto.decrypt(partialExpense[i]['Email']) == email) {
        return true;
      }
    }

    return false;
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
      bool manualSplit,
      int index) {
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
                    widget.Email == email && !locked
                        ? Row(
                            children: [
                              IconButton(
                                  onPressed: () async {
                                    if (this.mounted) {
                                      buildShowDialog(context);
                                    }
                                    if (manualSplit) {
                                      await updateExpenseManual(
                                          partialExpense,
                                          id,
                                          "1",
                                          widget.expenseCategory.indexOf(type),
                                          widget.subCategory[widget
                                                  .expenseCategory
                                                  .indexOf(type)]
                                              .indexOf(subType),
                                          index);
                                    } else {
                                      await _updateTransaction(
                                          context,
                                          _purpose.text,
                                          id,
                                          _amount.text,
                                          "1",
                                          partialExpense.isEmpty ? "0" : "1",
                                          widget.expenseCategory.indexOf(type),
                                          widget.subCategory[widget
                                                  .expenseCategory
                                                  .indexOf(type)]
                                              .indexOf(subType),
                                          index);
                                    }

                                    if (this.mounted) {
                                      context.pop();
                                    }
                                    if (this.mounted) {
                                      context.pop();
                                    }
                                  },
                                  icon: Icon(Icons.delete)),
                              IconButton(
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (BuildContext context) =>
                                              manualSplit
                                                  ? splitManuallyWidget(
                                                      context,
                                                      partialExpense,
                                                      purpose,
                                                      id,
                                                      widget.expenseCategory
                                                          .indexOf(type),
                                                      widget.subCategory[widget
                                                              .expenseCategory
                                                              .indexOf(type)]
                                                          .indexOf(subType),
                                                      index)
                                                  : _buildUpdateDialog(
                                                      context,
                                                      id,
                                                      purpose,
                                                      amount,
                                                      partialExpense.isEmpty
                                                          ? "0"
                                                          : "1",
                                                      type,
                                                      subType,
                                                      index),
                                    );
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
                          type + (subType.length > 0 ? ' (${subType})' : ""),
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
                        "Modified: " + formatDateTime(lastModDate),
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
                        height: 85,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: partialExpense.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CachedNetworkImage(
                                        httpHeaders: {
                                          'Access-Control-Allow-Origin': '*'
                                        },
                                        imageUrl: addCorsinImage(crypto
                                                    .decrypt(
                                                        partialExpense[index]
                                                            ['pic'])
                                                    .length ==
                                                0
                                            ? global.unknown_avatar_id
                                            : crypto.decrypt(
                                                partialExpense[index]['pic'])),
                                        progressIndicatorBuilder: (context, url,
                                                downloadProgress) =>
                                            CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
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
                                      Text(
                                        crypto.decrypt(
                                            partialExpense[index]['Name']),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  manualSplit
                                      ? Text(
                                          "₹ " +
                                              crypto.decrypt(
                                                  partialExpense[index]['amt']),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                SizedBox(
                  height: 25,
                ),
                partialExpense.isEmpty ||
                        userInPartialExpense(partialExpense, widget.Email)
                    ? SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width * 0.95 - 25,
                        child: OutlinedButton(
                          onPressed: () async {
                            if (this.mounted) {
                              buildShowDialog(context);
                            }
                            await addToPersonalExpense(
                                id,
                                partialExpense.isEmpty
                                    ? "0"
                                    : (manualSplit ? "2" : "1"));
                            for (int i = 0; i < 2 && context.canPop(); i++) {
                              if (this.mounted) {
                                context.pop();
                              }
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
                            "Add To Personal Expense",
                            style: TextStyle(
                                fontSize: 16,
                                color: themeProvider.isDarkTheme
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      )
                    : SizedBox(),
                partialExpense.isEmpty ||
                        userInPartialExpense(partialExpense, widget.Email)
                    ? SizedBox(
                        height: 12,
                      )
                    : SizedBox(),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      child: ListView.separated(
          separatorBuilder: (context, index) => SizedBox(
                height: 3,
              ),
          shrinkWrap: true,
          controller: controller,
          physics: ScrollPhysics(),
          itemCount: widget.TransList.length,
          itemBuilder: (BuildContext context, int index) {
            List<dynamic> partialExpense = widget.TransList[index]["members"];
            List<dynamic> isInSplitAmount = partialExpense
                .where((element) =>
                    crypto.decrypt(element['Email']) == widget.Email)
                .toList();

            return AutoScrollTag(
              controller: controller,
              index: index,
              key: ValueKey(index),
              child: InkWell(
                onTap: () {
                  _purpose.text =
                      crypto.decrypt(widget.TransList[index]["Purpose"]);
                  _amount.text =
                      crypto.decrypt(widget.TransList[index]["Amount"]);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => _buildPopupDialog(
                          context,
                          crypto.decrypt(widget.TransList[index]["Name"]),
                          formatDateTime(
                              crypto.decrypt(widget.TransList[index]["Date"])),
                          crypto.decrypt(widget.TransList[index]["Email"]),
                          crypto.decrypt(widget.TransList[index]["id"]),
                          crypto.decrypt(widget.TransList[index]["Purpose"]),
                          crypto.decrypt(widget.TransList[index]["Amount"]),
                          widget.locked,
                          partialExpense,
                          crypto.decrypt(widget.TransList[index]["Type"]),
                          crypto.decrypt(widget.TransList[index]["subType"]),
                          widget.TransList[index]["isEdited"],
                          crypto
                              .decrypt(widget.TransList[index]["lastModDate"]),
                          widget.TransList[index]["isManualSplit"],
                          index));
                },
                child: SizedBox(
                    height: 185,
                    child: Card(
                      elevation: 1.0,
                      shadowColor: Theme.of(context).primaryColor,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: index == widget.index
                                ? Colors.redAccent
                                : Theme.of(context).primaryColor.withAlpha(80)),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 0, 8),
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
                                          crypto.decrypt(widget.TransList[index]
                                              ["Purpose"]),
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
                                            crypto.decrypt(widget
                                                .TransList[index]["Name"]),
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
                                          child: Text(
                                            "Split In: " +
                                                (partialExpense.isEmpty
                                                    ? "All"
                                                    : "Partial"),
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
                                                crypto.decrypt(
                                                        widget.TransList[index]
                                                            ["Type"]) +
                                                    (crypto
                                                                .decrypt(widget
                                                                        .TransList[index]
                                                                    ["subType"])
                                                                .length >
                                                            0
                                                        ? " (" +
                                                            crypto.decrypt(widget
                                                                    .TransList[index]
                                                                ["subType"]) +
                                                            ")"
                                                        : ""),
                                                Icons.check_outlined),
                                            child: Text(
                                              "Category: " +
                                                  crypto.decrypt(widget
                                                          .TransList[index][
                                                      "Type"]) +
                                                  (crypto
                                                              .decrypt(
                                                                  widget.TransList[
                                                                          index]
                                                                      [
                                                                      "subType"])
                                                              .length >
                                                          0
                                                      ? " (" +
                                                          crypto.decrypt(
                                                              widget.TransList[
                                                                      index]
                                                                  ["subType"]) +
                                                          ")"
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
                                            formatDateTime(crypto.decrypt(widget
                                                .TransList[index]["Date"])),
                                            style: const TextStyle(
                                              fontSize: 17,
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: widget.TransList[index]
                                        ["isEdited"]
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: [
                                  widget.TransList[index]["isEdited"]
                                      ? Container(
                                          width: 55,
                                          height: 30,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,
                                              border: Border.all(
                                                color: themeProvider.isDarkTheme
                                                    ? (index == widget.index
                                                        ? Colors.redAccent
                                                        : Theme.of(context)
                                                            .primaryColor)
                                                    : Colors.white,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(12))),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text("Edited",
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white)),
                                          ))
                                      : SizedBox(),
                                  widget.TransList[index]["isEdited"]
                                      ? SizedBox(
                                          height: 30,
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
                                                commaSeperator(crypto.decrypt(
                                                    widget.TransList[index]
                                                        ["Amount"])),
                                            style: const TextStyle(
                                              fontSize: 19,
                                            ),
                                          ),
                                          widget.TransList[index]
                                                      ["isManualSplit"] &&
                                                  partialExpense.length > 1 &&
                                                  isInSplitAmount.isNotEmpty
                                              ? Text(
                                                  "(₹ " +
                                                      crypto.decrypt(
                                                          isInSplitAmount[0]
                                                              ['amt']) +
                                                      ")",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                )
                                              : SizedBox()
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
