library;

import 'dart:math';

import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'known_entities.dart';
part 'patterns.dart';

// ============================================================================
// Field extractors
// ============================================================================

String getAmount(String messageBody) {
  final match = _amountPattern.firstMatch(messageBody);
  if (match == null) return "";

  String amount = match.group(1)!.replaceAll(",", "");
  if (amount.isEmpty || amount == ".") return "";
  if (amount.startsWith(".")) amount = amount.substring(1);
  if (amount.endsWith(".")) amount = amount.substring(0, amount.length - 1);
  return amount;
}

String getReferenceNo(String messageBody) {
  for (final pattern in _refNoPatterns) {
    final ref = pattern.firstMatch(messageBody)?.namedGroup('ref');
    if (ref != null && ref.isNotEmpty) {
      return ref.toUpperCase();
    }
  }
  return "Unknown";
}

String getTransferTo(String messageBody) {
  if (messageBody.contains("credited with salary")) return "Salary";

  if (messageBody.contains("refund of")) {
    final idx = messageBody.indexOf("refund of");
    final candidate = messageBody.substring(0, max(0, idx)).trim();
    if (candidate.isNotEmpty) return capitalizeFirstLetter(candidate);
  }

  for (final pattern in _transferToPatterns) {
    final raw = pattern.firstMatch(messageBody)?.namedGroup('name');
    if (raw == null) continue;

    // Bank templates sometimes pad the *next* field with 3+ spaces instead
    // of punctuation (e.g. "Flipkart               Bengaluru     IN").
    // Treat a long space-run as a field boundary and cut there — this is
    // what makes the lazy regex above safe even when it overmatches.
    final name = raw.split(RegExp(r'\s{3,}')).first.trim();
    if (name.isNotEmpty) return capitalizeFirstLetter(name);
  }

  if (messageBody.contains("cashback")) return "Cashback";

  return "Unknown";
}

String getBankName(String sender, String messageBody) {
  final lowerSender = sender.toLowerCase();
  for (final bank in _knownBanks) {
    if (lowerSender.contains(bank.toLowerCase())) return bank;
  }
  // Fallback: real messages almost always name the bank in the body too
  // ("Team IDFC FIRST Bank", "-SBI", "ICICI Bank Acc...").
  for (final bank in _knownBanks) {
    if (messageBody.contains(bank.toLowerCase())) return bank;
  }
  return "Unknown";
}

String getPaymentMode(String sender, String messageBody) {
  final lowerSender = sender.toLowerCase();

  for (final mode in _paymentModes) {
    final lowerMode = mode.toLowerCase();

    if (mode == "Card" && messageBody.contains(lowerMode)) {
      return (messageBody.contains("lmt") || messageBody.contains("limit"))
          ? "Credit Card"
          : "Debit Card";
    }
    if (mode == "ATM") {
      if (messageBody.contains("withdrawn")) return mode;
      continue;
    }
    if (lowerSender.contains(lowerMode) || messageBody.contains(lowerMode)) {
      return mode;
    }
  }
  return "Unknown";
}

String capitalizeFirstLetter(String text) {
  text = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (text.isEmpty) return "";

  return text
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

// ============================================================================
// Noise filtering
// ============================================================================

bool _isPromotionalSender(String sender) {
  for (final promo in _promotionalSenders) {
    if (sender.contains(promo)) return true;
  }

  return false;
}

bool _isTransactionSender(String sender) =>
    _transactionSenderPattern.hasMatch(sender);

bool _isNoise(String messageBody, String sender) {
  if (!_isTransactionSender(sender)) return true;
  if (_isPromotionalSender(sender)) return true;
  if (_otpPattern.hasMatch(messageBody)) return true;
  return _noisePhrases.any((p) => messageBody.contains(p));
}

// ============================================================================
// Confidence scoring
// ============================================================================

double _confidenceScore({
  required String bank,
  required String referenceNo,
  required String receiver,
  required String paymentMode,
}) {
  double score = 0.4;
  if (bank != "Unknown") score += 0.2;
  if (referenceNo != "Unknown") score += 0.15;
  if (receiver != "Unknown") score += 0.15;
  if (paymentMode != "Unknown") score += 0.1;
  return score.clamp(0.0, 1.0);
}

// ============================================================================
// Main entry point
// ============================================================================

Future<List<dynamic>> filterSMS(List<SmsMessage> messages) async {
  final transactions = <BankTransactionModel>[];
  final bankNameFound = <String>{};
  final paymentModeFound = <String>{};

  for (final msg in messages) {
    final sender = msg.sender.toString();
    final messageBody = msg.body.toString().toLowerCase();

    if (_isNoise(messageBody, sender)) continue;

    final bankName = getBankName(sender, messageBody);
    if (bankName == "Unknown") continue;

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
    final receiver = paymentMode == "ATM" ? "Self" : getTransferTo(messageBody);

    bankNameFound.add(bankName);
    paymentModeFound.add(paymentMode);

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
        rawMessage: messageBody,
      ),
    );
  }

  return [transactions, bankNameFound.toList(), paymentModeFound.toList()];
}
