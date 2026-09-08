enum Bank {
  hdfc,
  icici,
  sbi,
  axis,
  kotak,
  pnb,
  canara,
  unionBank,
  bankOfBaroda,
  indusInd,
  idfcFirst,
  idfc,
  rbl,
  yesBank,
  federalBank,
  bankOfIndia,
  idbi,
  unknown,
}

extension BankExt on Bank {
  String get label {
    switch (this) {
      case Bank.hdfc:
        return 'HDFC';
      case Bank.icici:
        return 'ICICI';
      case Bank.sbi:
        return 'SBI';
      case Bank.axis:
        return 'Axis';
      case Bank.kotak:
        return 'Kotak';
      case Bank.pnb:
        return 'PNB';
      case Bank.canara:
        return 'Canara';
      case Bank.unionBank:
        return 'Union Bank';
      case Bank.bankOfBaroda:
        return 'Bank of Baroda';
      case Bank.indusInd:
        return 'IndusInd';
      case Bank.idfcFirst:
        return 'IDFC FIRST';
      case Bank.idfc:
        return 'IDFC';
      case Bank.rbl:
        return 'RBL';
      case Bank.yesBank:
        return 'Yes Bank';
      case Bank.federalBank:
        return 'Federal Bank';
      case Bank.bankOfIndia:
        return 'Bank of India';
      case Bank.idbi:
        return 'IDBI';
      case Bank.unknown:
        return 'Unknown';
    }
  }
}
