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

