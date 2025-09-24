enum FormatSelection { amountDescription, descriptionAmount }

extension FormatSelectionExtension on FormatSelection {
  String get label {
    switch (this) {
      case FormatSelection.amountDescription:
        return 'Amount - Description';
      case FormatSelection.descriptionAmount:
        return 'Description - Amount';
    }
  }
}
