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
  bool transactionConsumed;
  double confidence;

  BankTransactionModel.empty({this.hasData = false})
    : id = "",
      amount = 0.0,
      date = DateTime.now(),
      transactionID = "",
      receiver = "",
      type = BankTransactionType.debit,
      bank = Bank.unknown,
      mode = PaymentMode.unknown,
      transactionConsumed = false,
      confidence = 0.0;

  BankTransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.transactionID,
    required this.receiver,
    required this.type,
    required this.bank,
    required this.mode,
    required this.transactionConsumed,
    required this.confidence,
  });

  @override
  toString() {
    return "ID: $id, Amount: $amount, Date: $date, Transaction ID: $transactionID, Receiver: $receiver, Type: ${type.label}, Bank: ${bank.label}, Mode: ${mode.label}, Transaction Consumed: $transactionConsumed, Confidence: $confidence";
  }
}
