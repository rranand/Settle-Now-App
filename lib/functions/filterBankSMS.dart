import 'dart:math';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';

import '../models/FriendEach.dart';
import '../contents.dart' as global;

String getAmount(String message) {
  List<String> patternList = ["rs.", "rs", "inr", "debited by"];
  int patternIndex = -1;
  for (int i = 0; i < patternList.length; i++) {
    if (message.contains(patternList[i])) {
      patternIndex = i;
      break;
    }
  }

  if (patternIndex == -1) {
    return "";
  }

  int index = message.indexOf(patternList[patternIndex]) +
      patternList[patternIndex].length;
  String amount = "";

  if (index < message.length) {
    if (message[index] == " ") {
      index++;
    }
  } else {
    return "";
  }

  for (int i = index; i < message.length && message[i] != " "; i++) {
    if (message[i] == ",") {
      continue;
    }
    amount += message[i];
  }

  if (amount.isEmpty) {
    return "";
  }

  if (amount[0] == ".") {
    return amount.substring(1);
  }

  if (amount.substring(amount.length - 1) == ".") {
    return amount.substring(0, amount.length - 1);
  }
  return amount;
}

String getReferenceNo(String message) {
  int patternIndex = -1;
  for (int i = 0; i < global.refNoPattern.length; i++) {
    if (message.contains(global.refNoPattern[i])) {
      patternIndex = i;
      break;
    }
  }

  if (patternIndex == -1) {
    return "Unknown";
  }

  int index = message.indexOf(global.refNoPattern[patternIndex]) +
      global.refNoPattern[patternIndex].length;

  if (index < message.length) {
    if (!message[index].contains(RegExp(r'[\w\d]{1}'))) {
      index++;
    }
  } else {
    return "Unknown";
  }

  String refNo = "";
  for (int i = index;
      i < message.length && message[i].contains(RegExp(r'[\w\d\*]{1}'));
      i++) {
    refNo += message[i];
  }

  return refNo == "" ? "Unknown" : refNo;
}

String getTransferTo(String message) {
  bool fromReg = false;
  List<RegExp> regexPatternList = [
    RegExp(r'[\d]{2}-[\w]{3}-[\d]{2} & '),
    RegExp(r'[\d]{2}-[\w]{3}-[\d]{2};'),
    RegExp(r'[\d]{2}-[\w]{3}-[\d]{2}.'),
    RegExp(r'[\d]{2}-[\w]{3}-[\d]{2},'),
    RegExp(r'[\d]{2}-[\w]{3}-[\d]{2}')
  ];

  int patternIndex = -1;
  for (int i = 0; i < global.transferTo.length; i++) {
    if (message.contains(global.transferTo[i])) {
      patternIndex = i;
      break;
    }
  }

  if (patternIndex == -1) {
    for (int i = 0; i < regexPatternList.length; i++) {
      if (message.contains(regexPatternList[i])) {
        patternIndex = i;
        break;
      }
    }

    if (patternIndex == -1) {
      return "Unknown";
    }
    fromReg = true;
  }

  int index = fromReg
      ? (message.indexOf(regexPatternList[patternIndex]) +
          (patternIndex == 0 ? 12 : (patternIndex < 4 ? 10 : 9)))
      : (message.indexOf(global.transferTo[patternIndex]) +
          global.transferTo[patternIndex].length);

  if (index < message.length) {
    if (!message[index].contains(RegExp(r'[\w\d]{1}'))) {
      index++;
    }
  } else {
    return "Unknown";
  }

  int uptoIndex = 99999999999;
  if (message.contains("debited")) {
    if (message.contains("credited.")) {
      uptoIndex = message.indexOf("credited.");
    }
  }

  if (uptoIndex == 99999999999) {
    for (int i = 0; i < global.refNoPattern.length; i++) {
      if (message.contains(global.refNoPattern[i], index + 1)) {
        uptoIndex =
            min(message.indexOf(global.refNoPattern[i], index + 1), uptoIndex);
      }
    }
  }
  String transferTo = "";
  if (uptoIndex == 99999999999) {
    for (int i = index;
        i < message.length &&
            !message[i].contains(" ") &&
            !message[i].contains(".");
        i++) {
      transferTo += message[i];
    }
  } else {
    for (int i = index;
        i < message.length &&
            (uptoIndex != 99999999999 && i < uptoIndex) &&
            !message[i].contains(RegExp(r'[\(\)\.\,]'));
        i++) {
      transferTo += message[i];
    }
  }

  return transferTo == "" ? "Unknown" : transferTo;
}

String getBankName(String message) {
  for (int i = 0; i < global.allBanks.length; i++) {
    if (message.contains(global.allBanks[i].toLowerCase())) {
      return global.allBanks[i];
    }
  }

  return "Unknown";
}

String getPaymentMode(String message, String messageBody) {
  List<String> patternList = ["UPI", "IMPS", "NEFT", "ATM"];

  for (int i = 0; i < patternList.length; i++) {
    if (patternList[i] == "ATM") {
      if (messageBody.contains("withdrawn")) {
        return patternList[i];
      }
    } else if (message.contains(patternList[i].toLowerCase())) {
      return patternList[i];
    } else if (messageBody.contains(patternList[i].toLowerCase())) {
      return patternList[i];
    }
  }

  if (messageBody.contains('credit card')) {
    return "Credit Card";
  } else if (messageBody.contains('debit card')) {
    return "Debit Card";
  }

  return "Unknown";
}

String capitalizeFirstLetter(String text) {
  text = text.trim();
  if (text.isEmpty) {
    return "";
  }
  String result = text[0].toUpperCase();

  for (int i = 1; i < text.length; i++) {
    if (text[i] == " ") {
      result += " ";
      result += text[i + 1].toUpperCase();
      i++;
    } else {
      result += text[i];
    }
  }

  return result;
}

Future<List<TransactionEach>> filterSMS(List<SmsMessage> _messages) async {
  List<TransactionEach> Transactions = [];
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateFormat dateFormat_new = DateFormat("MMM dd yyyy h:mm a");

  for (int i = 0; i < _messages.length; i++) {
    String messageBody = _messages[i].body.toString().toLowerCase();
    DateTime dateTime = dateFormat.parse(_messages[i].date.toString());
    String timeStrap = dateFormat_new.format(dateTime);

    if (messageBody.contains("dishonored") ||
        messageBody.contains("created") ||
        messageBody.contains("received on") ||
        messageBody.contains("due of") ||
        messageBody.contains("rasied by") ||
        messageBody.contains("mandate") ||
        messageBody.contains("requested") ||
        messageBody.contains("due on")) {
      continue;
    }

    String bankName = getBankName(_messages[i].sender.toString().toLowerCase());

    if (bankName == "Unknown") {
      continue;
    }
    bool isDebited =
        messageBody.contains("debited") || messageBody.contains("withdrawn");
    bool isCredited = messageBody.contains("credited");

    if (!(isDebited || isCredited)) {
      continue;
    }
    String paymentMode = getPaymentMode(
        _messages[i].sender.toString().toLowerCase(), messageBody);

    String amount = getAmount(messageBody);
    try {
      double.parse(amount);
    } on FormatException {
      continue;
    }
    String transactionID = getReferenceNo(messageBody);
    String receiver = getTransferTo(messageBody);

    Transactions.add(TransactionEach(
        amount: amount,
        date: timeStrap,
        transactionID: transactionID,
        receiver:
            paymentMode == "ATM" ? "Self" : capitalizeFirstLetter(receiver),
        type: isDebited ? "Debit" : (isCredited ? "Credit" : "Debit"),
        bank: bankName,
        mode: paymentMode));
  }
  return Transactions;
}
