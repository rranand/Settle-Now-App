import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';

import '../models/FriendEach.dart';

String getAmount(String message, String pattern) {
  if (!message.contains(pattern)) {
    return "";
  }
  int index = message.indexOf(pattern) + pattern.length;
  String amount = "";

  if (message[index] == " ") {
    index++;
  }

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
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateFormat dateFormat_new = DateFormat("MMM dd yyyy h:mm a");

  for (int i = 0; i < _messages.length; i++) {
    String messageBody = _messages[i].body.toString().toLowerCase();
    DateTime dateTime = dateFormat.parse(_messages[i].date.toString());
    String timeStrap = dateFormat_new.format(dateTime);

    if (messageBody.contains("requested") || messageBody.contains("due on")) {
      continue;
    }

    if (_messages[i]
        .sender
        .toString()
        .toLowerCase()
        .contains(bankName.toLowerCase())) {
      bool isUPI = _messages[i].sender.toString().contains("UPI") ||
          messageBody.contains("upi");
      bool isIMPS = _messages[i].sender.toString().contains("IMPS") ||
          messageBody.contains("imps");
      bool isNEFT = _messages[i].sender.toString().contains("NEFT") ||
          messageBody.contains("neft");
      if (messageBody.contains("debited")) {
        String amount = getAmount(messageBody, "rs");
        if (amount.isEmpty) {
          amount = getAmount(messageBody, "debited by");
        }

        String transactionID = "Unknown";
        int refNo = -1;
        String receiver = "";

        try {
          double.parse(amount);
        } on FormatException {
          continue;
        }

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
        } else if (messageBody.contains("refno")) {
          refNo = messageBody.indexOf("refno");
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
        } else if (messageBody.contains("ref no")) {
          refNo = messageBody.indexOf("ref no");
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
        } else if (messageBody.contains("trf to")) {
          int index = messageBody.indexOf("trf to") + "trf to".length;
          for (int i = index; i < refNo; i++) {
            receiver += messageBody[i];
          }
        } else {
          receiver = "Unknown";
        }

        Transactions.add(TransactionEach(
            amount: amount,
            date: timeStrap,
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
          try {
            double.parse(amount);
          } on FormatException {
            continue;
          }

          Transactions.add(TransactionEach(
              amount: amount,
              date: timeStrap,
              transactionID: transactionID,
              receiver: capitalizeFirstLetter(receiver),
              type: "Debit",
              bank: bankName,
              mode: "Debit Card"));
        }
      } else if (messageBody.contains("credited")) {
        String amount = "";
        if (messageBody.contains("inr ")) {
          amount = getAmount(messageBody, "inr ");
        } else {
          amount = getAmount(messageBody, "rs");
        }
        try {
          double.parse(amount);
        } on FormatException {
          continue;
        }
        String transactionID = "Unknown";

        if (messageBody.contains("ref no")) {
          int index = messageBody.indexOf("ref no") + "ref no".length;
          if (messageBody[index] == " ") {
            index++;
          }
          transactionID = "";

          for (int j = index;
              j < messageBody.length && messageBody[j] != ")";
              j++) {
            transactionID += messageBody[j];
          }
        }

        Transactions.add(TransactionEach(
            amount: amount,
            date: timeStrap,
            transactionID: transactionID,
            receiver: "Self",
            type: "Credit",
            bank: bankName,
            mode: isUPI
                ? "UPI"
                : (isIMPS ? "IMPS" : (isNEFT ? "NEFT" : "Unknown"))));
      } else if (messageBody.contains("withdrawn")) {
        String amount = getAmount(messageBody, "rs");
        try {
          double.parse(amount);
        } on FormatException {
          continue;
        }
        String transactionID = getAmount(messageBody, "transaction number ");
        Transactions.add(TransactionEach(
            amount: amount,
            date: timeStrap,
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

Future<List<TransactionEach>> filterICICISMS(List<SmsMessage> _messages) async {
  String bankName = "ICICI";
  List<TransactionEach> Transactions = [];
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateFormat dateFormat_new = DateFormat("MMM dd yyyy h:mm a");

  for (int i = 0; i < _messages.length; i++) {
    String messageBody = _messages[i].body.toString().toLowerCase();
    DateTime dateTime = dateFormat.parse(_messages[i].date.toString());
    String timeStrap = dateFormat_new.format(dateTime);

    if (messageBody.contains("requested") || messageBody.contains("due on")) {
      continue;
    }

    if (_messages[i].sender.toString().contains(bankName)) {
      bool isUPI = _messages[i].sender.toString().contains("UPI") ||
          messageBody.contains("upi");
      bool isIMPS = _messages[i].sender.toString().contains("IMPS") ||
          messageBody.contains("imps");
      bool isNEFT = _messages[i].sender.toString().contains("NEFT") ||
          messageBody.contains("neft");

      if (messageBody.contains("debited")) {
        String amount = "";
        if (messageBody.contains("rs ")) {
          amount = getAmount(messageBody, "rs ");
        } else if (messageBody.contains("inr ")) {
          amount = getAmount(messageBody, "inr ");
        } else if (messageBody.contains("rs")) {
          amount = getAmount(messageBody, "rs");
        } else if (messageBody.contains("inr")) {
          amount = getAmount(messageBody, "inr");
        }

        try {
          double.parse(amount);
        } on FormatException {
          continue;
        }

        String transactionID = "Unknown";
        int refNo = -1;
        String receiver = "";

        if (messageBody.contains("ref. no.")) {
          refNo = messageBody.indexOf("ref. no.");
          int index = refNo + "ref. no.".length;

          if (messageBody[index] == " ") {
            index++;
          }
          index += 3;
          transactionID = "";

          for (int j = index;
              j < messageBody.length && messageBody[j] != "-";
              j++) {
            transactionID += messageBody[j];
          }

          if (messageBody.contains("linked")) {
            int index = messageBody.indexOf("linked") + "linked".length;
            for (int ind = index;
                ind < messageBody.length && messageBody[ind] != ".";
                ind++) {
              receiver += messageBody[ind];
            }
          } else {
            receiver = "Unknown";
          }
        } else if (messageBody.contains("upi:")) {
          refNo = messageBody.indexOf("upi:");
          int index = refNo + "upi:".length;
          transactionID = "";

          for (int j = index;
              j < messageBody.length && messageBody[j] != ".";
              j++) {
            transactionID += messageBody[j];
          }

          if (messageBody.contains(RegExp(r'[\d]{2}-[\w]{3}-[\d]{2}'))) {
            int index =
                messageBody.indexOf(RegExp(r'[\d]{2}-[\w]{3}-[\d]{2}')) + 11;
            for (int ind = index;
                ind < messageBody.length && messageBody[ind] != ".";
                ind++) {
              receiver += messageBody[ind];
            }
            List<String> temp = receiver.split(" ");
            if (temp.isNotEmpty && temp[temp.length - 1] == "credited") {
              receiver = "";
              temp.forEach((element) {
                if (element != "credited") {
                  receiver += element + " ";
                }
              });
            }
          } else {
            receiver = "Unknown";
          }
        } else if (messageBody.contains("imps:")) {
          refNo = messageBody.indexOf("imps:");
          int index = refNo + "imps:".length;
          transactionID = "";

          for (int j = index;
              j < messageBody.length && messageBody[j] != ".";
              j++) {
            transactionID += messageBody[j];
          }

          receiver = "Unknown";
        } else {
          receiver = "Unknown";
        }

        if (receiver == "Unknown") {
          if (messageBody.contains("info: ")) {
            int index = messageBody.indexOf("info: ") + "info: ".length;
            receiver = "";

            for (int j = index;
                j < messageBody.length && messageBody[j] != ".";
                j++) {
              receiver += messageBody[j];
            }
          } else if (messageBody.contains(RegExp(r'[\d]{2}-[\w]{3}-[\d]{2}'))) {
            receiver = "";
            int index =
                messageBody.indexOf(RegExp(r'[\d]{2}-[\w]{3}-[\d]{2}')) + 11;
            for (int ind = index;
                ind < messageBody.length && messageBody[ind] != ".";
                ind++) {
              receiver += messageBody[ind];
            }
            List<String> temp = receiver.split(" ");
            if (temp.isNotEmpty && temp[temp.length - 1] == "credited") {
              receiver = "";
              temp.forEach((element) {
                if (element != "credited") {
                  receiver += element + " ";
                }
              });
            }
          } else {
            receiver = "Unknown";
          }
        }

        Transactions.add(TransactionEach(
            amount: amount,
            date: timeStrap,
            transactionID: transactionID,
            receiver: capitalizeFirstLetter(receiver),
            type: "Debit",
            bank: bankName,
            mode: isUPI
                ? "UPI"
                : (isIMPS ? "IMPS" : (isNEFT ? "NEFT" : "Unknown"))));
      } else if (messageBody.contains(RegExp('spent on icici bank card'))) {
        String amount = getAmount(messageBody, "inr ");
        String transactionID = "Unknown";
        String receiver = "";

        for (int ind = messageBody.indexOf("at") + 3;
            ind < messageBody.length && messageBody[ind] != ".";
            ind++) {
          receiver += messageBody[ind];
        }

        try {
          double.parse(amount);
        } on FormatException {
          continue;
        }

        Transactions.add(TransactionEach(
            amount: amount,
            date: timeStrap,
            transactionID: transactionID,
            receiver: capitalizeFirstLetter(receiver),
            type: "Debit",
            bank: bankName,
            mode: "Credit Card"));
      } else if (messageBody.contains("credited")) {
        String amount = "";
        if (messageBody.contains("inr ")) {
          amount = getAmount(messageBody, "inr ");
        } else {
          amount = getAmount(messageBody, "rs ");
        }

        String receiver = "";

        if (messageBody.contains("from ")) {
          for (int ind = messageBody.indexOf("from ") + 5;
              ind < messageBody.length && messageBody[ind] != ".";
              ind++) {
            receiver += messageBody[ind];
            if (receiver.length > 2 &&
                receiver[receiver.length - 1] == "s" &&
                receiver[receiver.length - 2] == "a" &&
                receiver[receiver.length - 3] == "h") {
              receiver = receiver.substring(0, receiver.length - 4);
              break;
            }
          }
        } else if (messageBody.contains("info:")) {
          int index = messageBody.indexOf("info:") + "info:".length;
          if (messageBody[index] == " ") {
            index++;
          }
          for (int j = index;
              j < messageBody.length &&
                  messageBody[j] != "." &&
                  messageBody[j] != " ";
              j++) {
            receiver += messageBody[j];
          }
        } else {
          receiver = "Unknown";
        }

        try {
          double.parse(amount);
        } on FormatException {
          continue;
        }

        String transactionID = "Unknown";
        if (isUPI) {
          transactionID = "";
          int index = messageBody.indexOf("upi:") + "upi:".length;
          for (int j = index;
              j < messageBody.length && messageBody[j] != "-";
              j++) {
            transactionID += messageBody[j];
          }
        }
        Transactions.add(TransactionEach(
            amount: amount,
            date: timeStrap,
            transactionID: transactionID,
            receiver: capitalizeFirstLetter(receiver),
            type: "Credit",
            bank: bankName,
            mode: isUPI
                ? "UPI"
                : (isIMPS ? "IMPS" : (isNEFT ? "NEFT" : "Unknown"))));
      } else if (messageBody.contains("withdrawn")) {
        String amount = getAmount(messageBody, "rs");
        try {
          double.parse(amount);
        } on FormatException {
          continue;
        }
        String transactionID = getAmount(messageBody, "transaction number ");
        Transactions.add(TransactionEach(
            amount: amount,
            date: timeStrap,
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
