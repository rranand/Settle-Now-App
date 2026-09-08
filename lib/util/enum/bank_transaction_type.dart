enum BankTransactionType { debit, credit, unknown }

extension BankTransactionTypeExt on BankTransactionType {
  String get label {
    switch (this) {
      case BankTransactionType.debit:
        return 'Debit';
      case BankTransactionType.credit:
        return 'Credit';
      case BankTransactionType.unknown:
        return 'Unknown';
    }
  }
}
