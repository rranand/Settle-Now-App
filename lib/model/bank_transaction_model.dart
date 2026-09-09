import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class BankTransactionModel {
  bool hasData = true;
  String id;
  double amount;
  DateTime date;
  String transactionID;
  String receiver;
  BankTransactionType type;
  Bank bank;
  PaymentMode mode;
  BankTransactionConsumedModel? transactionConsumed;
  double confidence;
  String rawMessage;

  BankTransactionModel.empty({this.hasData = false})
    : id = "",
      amount = 0.0,
      date = DateTime.now(),
      transactionID = "",
      receiver = "",
      type = BankTransactionType.debit,
      bank = Bank.unknown,
      mode = PaymentMode.unknown,
      transactionConsumed = null,
      confidence = 0.0,
      rawMessage = "";

  BankTransactionModel({
    required this.amount,
    required this.date,
    required this.transactionID,
    required this.receiver,
    required this.type,
    required this.bank,
    required this.mode,
    required this.transactionConsumed,
    required this.confidence,
    required this.rawMessage,
  }) : id = _generateId(
         amount: amount,
         date: date,
         transactionID: transactionID,
         receiver: receiver,
         type: type,
         bank: bank,
         mode: mode,
       );

  static String _generateId({
    required double amount,
    required DateTime date,
    required String transactionID,
    required String receiver,
    required BankTransactionType type,
    required Bank bank,
    required PaymentMode mode,
  }) {
    final canonical = [
      amount.toStringAsFixed(2),
      date.toIso8601String(),
      transactionID.trim().toLowerCase(),
      receiver.trim().toLowerCase(),
      type.name,
      bank.name,
      mode.name,
    ].join('|');

    final digest = sha256.convert(utf8.encode(canonical));
    return digest.toString().substring(
      0,
      16,
    ); // 64 bits — plenty at personal-app scale
  }

  @override
  toString() {
    return "ID: $id, Amount: $amount, Date: $date, Transaction ID: $transactionID, Receiver: $receiver, Type: ${type.label}, Bank: ${bank.label}, Mode: ${mode.label}, Transaction Consumed: $transactionConsumed, Confidence: $confidence";
  }
}
