part of 'filter_sms.dart';

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
