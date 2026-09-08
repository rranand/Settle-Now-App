part of 'filter_sms.dart';

double _confidenceScore({
  required Bank bank,
  required String referenceNo,
  required String receiver,
  required PaymentMode paymentMode,
}) {
  double score = 0.4;
  if (bank != Bank.unknown) score += 0.2;
  if (referenceNo != "Unknown") score += 0.15;
  if (receiver != "Unknown") score += 0.15;
  if (paymentMode != PaymentMode.unknown) score += 0.1;
  return score.clamp(0.0, 1.0);
}
