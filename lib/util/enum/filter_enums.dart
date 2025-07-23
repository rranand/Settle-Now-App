enum SortBy { dateCreated, amount, name }

extension SortByExtension on SortBy {
  String get label {
    switch (this) {
      case SortBy.dateCreated:
        return 'Date Created';
      case SortBy.amount:
        return 'Amount';
      case SortBy.name:
        return 'Name';
    }
  }
}

enum SortRules { ascending, descending }

extension SortRulesExtension on SortRules {
  String get label {
    switch (this) {
      case SortRules.ascending:
        return 'Ascending';
      case SortRules.descending:
        return 'Descending';
    }
  }
}

enum LendenType { gave, owe, none }

extension LendenTypeExtension on LendenType {
  String get label {
    switch (this) {
      case LendenType.gave:
        return 'Gave';
      case LendenType.owe:
        return 'Owe';
      case LendenType.none:
        return 'None';
    }
  }
}
