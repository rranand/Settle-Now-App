enum SortBy { dateCreated, amount, name, category }

extension SortByExtension on SortBy {
  String get label {
    switch (this) {
      case SortBy.category:
        return 'Category';
      case SortBy.dateCreated:
        return 'Date Created';
      case SortBy.amount:
        return 'Amount';
      case SortBy.name:
        return 'Name';
    }
  }
}

enum SortRules { mostRecent, leastRecent }

extension SortRulesExtension on SortRules {
  String get label {
    switch (this) {
      case SortRules.mostRecent:
        return 'Most Recent';
      case SortRules.leastRecent:
        return 'Least Recent';
    }
  }
}
