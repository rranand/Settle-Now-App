import 'package:settlenow_v2/model/room_settle_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';

List<RoomUserModel> calculateUserExpenseInfo(
  List<RoomUserModel> userArr,
  List<TransactionModel> transArr,
  List<RoomSettleModel> settleArr,
) {
  Map<String, double> contributionMap = {};
  Map<String, double> spentMap = {};
  Map<String, double> settleMap = {};

  int n = userArr.length;

  if (settleArr.isNotEmpty) {
    for (int i = 0; i < settleArr.length; i++) {
      RoomSettleModel eachObj = settleArr[i];
      String senderUID = eachObj.sender.id;
      String receiverUID = eachObj.receiver.id;

      settleMap[senderUID] = (settleMap[senderUID] ?? 0) + eachObj.amount;
      settleMap[receiverUID] = (settleMap[receiverUID] ?? 0) - eachObj.amount;
    }
  } else {
    for (int i = 0; i < userArr.length; i++) {
      settleMap[userArr[i].user.id] = userArr[i].settle;
    }
  }

  double totalCommonSplitAmount = 0;

  for (int i = 0; i < transArr.length; i++) {
    TransactionModel eachObj = transArr[i];
    String createdBy = eachObj.createdBy.id;

    contributionMap[createdBy] =
        (contributionMap[createdBy] ?? 0) + eachObj.amount;

    if (eachObj.createdBy.amount == eachObj.amount) {
      spentMap[createdBy] =
          (spentMap[createdBy] ?? 0) + eachObj.createdBy.amount;
    } else if (eachObj.users.isEmpty) {
      totalCommonSplitAmount += eachObj.amount / n;
    } else {
      spentMap[createdBy] =
          (spentMap[createdBy] ?? 0) + eachObj.createdBy.amount;

      for (int j = 0; j < eachObj.users.length; j++) {
        String userID = eachObj.users[j].id;
        spentMap[userID] = (spentMap[userID] ?? 0) + eachObj.users[j].amount;
      }
    }
  }

  List<RoomUserModel> data = [];

  for (int i = 0; i < n; i++) {
    String userID = userArr[i].user.id;
    spentMap[userID] = (spentMap[userID] ?? 0) + totalCommonSplitAmount;

    RoomUserModel eachObj = RoomUserModel(
      id: userArr[i].id,
      active: userArr[i].active,
      user: userArr[i].user,
      contribution: contributionMap[userID] ?? 0,
      spent: spentMap[userID] ?? 0,
      settle: settleMap[userID] ?? 0,
    );

    data.add(eachObj);
  }

  return data;
}
