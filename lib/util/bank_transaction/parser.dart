part of 'filter_sms.dart';

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

Bank getBankName(String sender, String messageBody) {
  final lowerSender = sender.toLowerCase();
  for (final bank in Bank.values) {
    if (lowerSender.contains(bank.label.toLowerCase())) return bank;
  }
  // Fallback: real messages almost always name the bank in the body too
  // ("Team IDFC FIRST Bank", "-SBI", "ICICI Bank Acc...").
  for (final bank in Bank.values) {
    if (messageBody.contains(bank.label.toLowerCase())) return bank;
  }

  return Bank.unknown;
}

PaymentMode getPaymentMode(String sender, String messageBody) {
  final lowerSender = sender.toLowerCase();

  for (final mode in PaymentMode.values) {
    final lowerMode = mode.label.toLowerCase();

    if (mode == PaymentMode.card && messageBody.contains(lowerMode)) {
      return (messageBody.contains("lmt") || messageBody.contains("limit"))
          ? PaymentMode.creditCard
          : PaymentMode.debitCard;
    }
    if (mode == PaymentMode.atm) {
      if (messageBody.contains("withdrawn")) return mode;
      continue;
    }
    if (lowerSender.contains(lowerMode) || messageBody.contains(lowerMode)) {
      return mode;
    }
  }
  return PaymentMode.unknown;
}

String capitalizeFirstLetter(String text) {
  text = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (text.isEmpty) return "";

  return text
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
