part of 'filter_sms.dart';

// ============================================================================
// Reference data — self-contained, no global.* dependency.
// Validated against a real SMS corpus; extend as new bank formats appear.
// ============================================================================

final RegExp _otpPattern = RegExp(
  r'\b(otp|one time password|do not share|verification code|valid for \d+\s*(min|minute))\b',
  caseSensitive: false,
);

final RegExp _transactionSenderPattern = RegExp(
  r'-(T|S)$',
  caseSensitive: false,
);

final RegExp _amountPattern = RegExp(
  r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
  caseSensitive: false,
);

// ---- Reference number: ordered, most-specific first --------------------
final List<RegExp> _refNoPatterns = [
  RegExp(r'\bupi\s*ref\s*no[:\.]?\s*(?<ref>[\w\*]+)', caseSensitive: false),
  RegExp(r'\bupi\s*ref[:\.]?\s*(?<ref>[\w\*]+)', caseSensitive: false),
  RegExp(r'\bupi\s*:\s*(?<ref>[\w\*]+)', caseSensitive: false),
  RegExp(r'\brrn\s*[:#]?\s*(?<ref>[\w\*]+)', caseSensitive: false),
  RegExp(r'\bref\s*(?:no|#)\s*[:\.]?\s*(?<ref>[\w\*]+)', caseSensitive: false),
  RegExp(r'\bref\s*[:\-]\s*(?<ref>[\w\*]+)', caseSensitive: false),
  RegExp(
    r'\breference\s+number\s*[:\.]?\s*(?<ref>[\w\*]+)',
    caseSensitive: false,
  ),
  RegExp(r'\butr\s+(?<ref>[\w]+)', caseSensitive: false),
  RegExp(
    r'\btxn\s*(?:id|ref|no)\s*[:#\.]?\s*(?<ref>[\w\*]+)',
    caseSensitive: false,
  ),
  RegExp(
    r'\btransaction\s*(?:id|ref)\s*[:#\.]?\s*(?<ref>[\w\*]+)',
    caseSensitive: false,
  ),
  // Fallback — ICICI "Info" codes glued directly to the reference, e.g.
  // "InfoBIL*INFT*FI13.Avl Bal". Kept last: it's the least specific.
  RegExp(r'\binfo\s*[:\.]?\s*(?<ref>[\w\*]+)', caseSensitive: false),
];

// ---- Receiver / counterparty: ordered, most-specific first --------------
final List<RegExp> _transferToPatterns = [
  // IDFC debit template: "...on 01/09/26; ROHIT ANAND credited. RRN..."
  RegExp(r';\s*(?<name>[^.]+?)\s+credited\b', caseSensitive: false),

  // Kiwi template: "@upi_chandu kumar 06-09-2026 06:37:31 PM..."
  RegExp(r'@upi_(?<name>[^.]+?)\s+\d{2}-\d{2}-\d{4}\b', caseSensitive: false),

  // IMPS credit with masked mobile + name before parenthesis:
  // "...mobile 9xxxxxx437-Rohit Anan (IMPS Ref# ...)"
  RegExp(r'[\dx]{6,}-(?<name>[^.]+?)\s*\(', caseSensitive: false),

  // Card spend, merchant before a second date: "...ending 6788 at Flipkart on 29/07/26."
  RegExp(r'\bat\s+(?<name>[^.]+?)\s+on\s+\d', caseSensitive: false),

  // Card spend, merchant before "Avl Lmt/Limit": "...at POLICYBAZAAR. Avl Lmt:"
  RegExp(r'\bat\s+(?<name>[^.]+?)\.\s*avl\b', caseSensitive: false),

  // Card spend, merchant after second "on": "...on 16-Jul-26 on AMAZON WEB SERV. Avl Limit:"
  RegExp(r'\bon\s+(?<name>[^.]+?)\.\s*avl\b', caseSensitive: false),

  // Card spend, merchant after second "on": "...on 16-Jul-26 AMAZON WEB SERV.Avl Limit:"
  RegExp(
    r'\b\d{2}-[a-z]{3}-\d{2}\s+(?<name>[^.]+?)\.avl\b',
    caseSensitive: false,
  ),

  // NEFT credit tied specifically to a UTR, to avoid colliding with
  // "debited by Rs." elsewhere in the same message.
  RegExp(
    r'\butr\s+[a-z0-9]+\s+by\s+(?<name>[a-z][a-z\s]*?)(?=,|\.|$)',
    caseSensitive: false,
  ),

  // Generic UPI/SBI transfer: "...transfer from SANJAY KUMAR SINHA Ref No..."
  RegExp(
    r'\bfrom\s+(?<name>[a-z][a-z\s]*?)(?=\s*(?:on\s+\d|ref|\.|,|;|$))',
    caseSensitive: false,
  ),

  RegExp(
    r'\btrf\s+to\s+(?<name>[a-z][a-z\s]*?)(?=\s*(?:on\s+\d|ref|\.|,|;|$))',
    caseSensitive: false,
  ),
];
