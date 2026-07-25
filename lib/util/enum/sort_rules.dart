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
