import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

import '../models/FriendEach.dart';

String getAmount(String message, String pattern) {
  int index = message.indexOf(pattern) + pattern.length;
  String amount = "";

  for (int i = index; i < message.length && message[i] != " "; i++) {
    if (message[i] == ",") {
      continue;
    }
    amount += message[i];
  }
  if (amount[0] == ".") {
    return amount.substring(1);
  }

  if (amount.substring(amount.length - 1) == ".") {
    return amount.substring(0, amount.length - 1);
  }
  return amount;
}

String capitalizeFirstLetter(String text) {
  text = text.trim();
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

Future<List<TransactionEach>> filterSBISMS(List<SmsMessage> _messages) async {
  String bankName = "SBI";
  List<TransactionEach> Transactions = [];

  for (int i = 0; i < _messages.length; i++) {
    String messageBody = _messages[i].body.toString().toLowerCase();
    int dateIndex = _messages[i].date.toString().indexOf(".");

    if (_messages[i].sender.toString().contains(bankName)) {
      bool isUPI = _messages[i].sender.toString().contains("UPI");
      bool isIMPS = _messages[i].sender.toString().contains("IMPS");
      bool isNEFT = _messages[i].sender.toString().contains("NEFT");

      if (messageBody.contains("debited")) {
        String amount = getAmount(messageBody, "rs");
        String transactionID = "Unknown";
        int refNo = -1;
        String receiver = "";

        if (messageBody.contains("ref")) {
          refNo = messageBody.indexOf("ref");
          int index = refNo + 3;

          if (messageBody[index] == " ") {
            index++;
          }
          index += 3;
          transactionID = "";

          for (int j = index;
              j < messageBody.length &&
                  messageBody[j] != "." &&
                  messageBody[j] != " ";
              j++) {
            transactionID += messageBody[j];
          }
        }

        if (messageBody.contains("transfer to")) {
          int index = messageBody.indexOf("transfer to") + "transfer to".length;
          for (int i = index; i < refNo; i++) {
            receiver += messageBody[i];
          }
        } else {
          receiver = "Unknown";
        }

        Transactions.add(TransactionEach(
            amount: amount,
            date: _messages[i].date.toString().substring(0, dateIndex),
            transactionID: transactionID,
            receiver: capitalizeFirstLetter(receiver),
            type: "Debit",
            bank: bankName,
            mode: isUPI
                ? "UPI"
                : (isIMPS ? "IMPS" : (isNEFT ? "NEFT" : "Unknown"))));
      } else if (messageBody.contains(RegExp('sbi ([A-Za-z]){3}it card'))) {
        if (messageBody.contains("transaction number")) {
          String amount = getAmount(messageBody, "rs");
          String transactionID = getAmount(messageBody, "transaction number ");
          String receiver = getAmount(messageBody, "done at ");

          Transactions.add(TransactionEach(
              amount: amount,
              date: _messages[i].date.toString().substring(0, dateIndex),
              transactionID: transactionID,
              receiver: capitalizeFirstLetter(receiver),
              type: "Debit",
              bank: bankName,
              mode: isUPI
                  ? "UPI"
                  : (isIMPS ? "IMPS" : (isNEFT ? "NEFT" : "Unknown"))));
        }
      } else if (messageBody.contains("credited")) {
        String amount = "";
        if (messageBody.contains("inr ")) {
          amount = getAmount(messageBody, "inr ");
        } else {
          amount = getAmount(messageBody, "rs");
        }
        String transactionID = "Unknown";
        Transactions.add(TransactionEach(
            amount: amount,
            date: _messages[i].date.toString().substring(0, dateIndex),
            transactionID: transactionID,
            receiver: "Self",
            type: "Credit",
            bank: bankName,
            mode: "Unknown"));
      } else if (messageBody.contains("withdrawn")) {
        String amount = getAmount(messageBody, "rs");
        String transactionID = getAmount(messageBody, "transaction number ");
        Transactions.add(TransactionEach(
            amount: amount,
            date: _messages[i].date.toString().substring(0, dateIndex),
            transactionID: transactionID,
            receiver: "Self",
            type: "Debit",
            bank: bankName,
            mode: "ATM"));
      }
    }
  }
  return Transactions;
}
