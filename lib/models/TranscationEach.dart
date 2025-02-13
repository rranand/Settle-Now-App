class TransactionEach {
  String id;
  String amount;
  String date;
  String transactionID;
  String receiver;
  String type;
  String bank;
  String mode;
  bool transactionConsumed;

  TransactionEach(
      {required this.id,
      required this.amount,
      required this.date,
      required this.transactionID,
      required this.receiver,
      required this.type,
      required this.bank,
      required this.mode,
      required this.transactionConsumed});
}
