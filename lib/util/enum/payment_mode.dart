enum PaymentMode {
  upi,
  card,
  atm,
  neft,
  imps,
  rtgs,
  netBanking,
  creditCard,
  debitCard,
  unknown,
}

extension PaymentModeExt on PaymentMode {
  String get label {
    switch (this) {
      case PaymentMode.upi:
        return 'UPI';
      case PaymentMode.card:
        return 'Card';
      case PaymentMode.atm:
        return 'ATM';
      case PaymentMode.neft:
        return 'NEFT';
      case PaymentMode.imps:
        return 'IMPS';
      case PaymentMode.rtgs:
        return 'RTGS';
      case PaymentMode.netBanking:
        return 'Net Banking';
      case PaymentMode.creditCard:
        return 'Credit Card';
      case PaymentMode.debitCard:
        return 'Debit Card';
      case PaymentMode.unknown:
        return 'Unknown';
    }
  }
}
