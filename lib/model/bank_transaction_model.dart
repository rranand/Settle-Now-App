enum BankTransactionType { debit, credit }

class BankTransactionModel {
  String id;
  double amount;
  DateTime date;
  String transactionID;
  String receiver;
  BankTransactionType type;
  String bank;
  String mode;
  bool transactionConsumed;
  double confidence;
  String rawMessage;

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
    required this.rawMessage,
  });

  @override
  toString() {
    return "ID: $id, Amount: $amount, Date: $date, Transaction ID: $transactionID, Receiver: $receiver, Type: $type, Bank: $bank, Mode: $mode, Transaction Consumed: $transactionConsumed, Confidence: $confidence";
  }
}
