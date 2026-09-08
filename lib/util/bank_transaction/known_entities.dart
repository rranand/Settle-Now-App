part of 'filter_sms.dart';

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
