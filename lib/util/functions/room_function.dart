import 'package:decimal/decimal.dart';
import 'package:settlenow/model/model_core.dart';

List<RoomUserModel> calculateUserExpenseInfo(
  List<RoomUserModel> userArr,
  List<TransactionModel> transArr,
  List<RoomSettleModel> settleArr,
) {
  Map<String, Decimal> contributionMap = {};
  Map<String, Decimal> spentMap = {};
  Map<String, Decimal> settleMap = {};

  int n = userArr.length;

  if (settleArr.isNotEmpty) {
    for (int i = 0; i < settleArr.length; i++) {
      RoomSettleModel eachObj = settleArr[i];
      String senderUID = eachObj.sender.id;
      String receiverUID = eachObj.receiver.id;

      settleMap[senderUID] =
          (settleMap[senderUID] ?? Decimal.zero) +
          Decimal.parse(eachObj.amount.toString());
      settleMap[receiverUID] =
          (settleMap[receiverUID] ?? Decimal.zero) -
          Decimal.parse(eachObj.amount.toString());
    }
  } else {
    for (int i = 0; i < userArr.length; i++) {
      settleMap[userArr[i].user.id] = Decimal.zero;
    }
  }

  for (int i = 0; i < transArr.length; i++) {
    TransactionModel eachObj = transArr[i];
    String createdBy = eachObj.createdBy.id;

    contributionMap[createdBy] =
        (contributionMap[createdBy] ?? Decimal.zero) +
        Decimal.parse(eachObj.amount.toString());

    spentMap[createdBy] =
        (spentMap[createdBy] ?? Decimal.zero) +
        Decimal.parse(eachObj.createdBy.amount.toString());

    for (int j = 0; j < eachObj.users.length; j++) {
      String userID = eachObj.users[j].id;
      spentMap[userID] =
          (spentMap[userID] ?? Decimal.zero) +
          Decimal.parse(eachObj.users[j].amount.toString());
    }
  }

  List<RoomUserModel> data = [];

  for (int i = 0; i < n; i++) {
    String userID = userArr[i].user.id;

    RoomUserModel eachObj = RoomUserModel(
      id: userArr[i].id,
      active: userArr[i].active,
      user: userArr[i].user,
      contribution: (contributionMap[userID] ?? Decimal.zero).toDouble(),
      spent: (spentMap[userID] ?? Decimal.zero).toDouble(),
      settle: (settleMap[userID] ?? Decimal.zero).toDouble(),
    );

    data.add(eachObj);
  }

  return data;
}
