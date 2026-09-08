part of 'filter_sms.dart';

const List<String> _knownBanks = [
  "HDFC",
  "ICICI",
  "SBI",
  "Axis",
  "Kotak",
  "PNB",
  "Canara",
  "Union Bank",
  "Bank of Baroda",
  "IndusInd",
  "IDFC FIRST",
  "IDFC",
  "RBL",
  "Yes Bank",
  "Federal Bank",
  "Bank of India",
  "IDBI",
];

const List<String> _paymentModes = [
  "UPI",
  "Card",
  "ATM",
  "NEFT",
  "IMPS",
  "RTGS",
  "Net Banking",
];

// Phrases that mean "not a completed transaction" — reminders, declines,
// mandates, etc. Verified against real recurring/declined messages.
const List<String> _noisePhrases = [
  "dishonored",
  "created",
  "received on",
  "due of",
  "raised by",
  "mandate",
  "requested",
  "due on",
  "due by",
  "withdrawal initiated",
  "declined",
  "standing instruction",
  "to be debited",
  "will be returned",
];

const List<String> _promotionalSenders = ["POLBAZ"];
