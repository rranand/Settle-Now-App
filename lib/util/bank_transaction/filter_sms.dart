library;

import 'dart:math';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'known_entities.dart';
part 'patterns.dart';
part 'noise_filtering.dart';
part 'parser.dart';
part 'confidence_score.dart';

Future<List<BankTransactionModel>> filterSMS(List<SmsMessage> messages) async {
  final transactions = <BankTransactionModel>[];

  for (final msg in messages) {
    final sender = msg.sender.toString();
    final messageBody = msg.body.toString().toLowerCase();

    if (_isNoise(messageBody, sender)) continue;

    final bankName = getBankName(sender, messageBody);
    if (bankName == Bank.unknown) continue;

    final isDebited =
        messageBody.contains("debited") ||
        messageBody.contains("withdrawn") ||
        messageBody.contains("withdrawal") ||
        messageBody.contains("spent");
    final isCredited = messageBody.contains("credited");

    if (!(isDebited || isCredited)) continue;

    final amount = getAmount(messageBody);
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) continue;

    final paymentMode = getPaymentMode(sender, messageBody);
    final referenceNo = getReferenceNo(messageBody);
    final receiver =
        paymentMode == PaymentMode.atm ? "Self" : getTransferTo(messageBody);

    final confidence = _confidenceScore(
      bank: bankName,
      referenceNo: referenceNo,
      receiver: receiver,
      paymentMode: paymentMode,
    );

    transactions.add(
      BankTransactionModel(
        id: msg.id.toString(),
        amount: parsedAmount,
        date: msg.date ?? DateTime.now(),
        transactionID: referenceNo,
        receiver: receiver,
        type:
            isDebited ? BankTransactionType.debit : BankTransactionType.credit,
        bank: bankName,
        mode: paymentMode,
        transactionConsumed: false,
        confidence: confidence,
      ),
    );
  }

  return transactions;
}
