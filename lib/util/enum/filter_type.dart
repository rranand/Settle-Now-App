enum FilterType {
  none,
  sort,
  amount,
  category,
  createdOn,
  room,
  transactionType,
  createdBy,
  splitWith,
}

extension FilterTypeExt on FilterType {
  String get label {
    switch (this) {
      case FilterType.sort:
        return 'Sort By';
      case FilterType.amount:
        return 'Amount';
      case FilterType.category:
        return 'Category';
      case FilterType.createdOn:
        return 'Created On';
      case FilterType.room:
        return 'Room';
      case FilterType.transactionType:
        return 'Type';
      case FilterType.createdBy:
        return 'Created By';
      case FilterType.splitWith:
        return 'Split With';
      case FilterType.none:
        return '';
    }
  }
}
