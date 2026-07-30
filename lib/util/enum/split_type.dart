enum SplitType { equal, partial, self, none }

extension SplitTypeExtension on SplitType {
  String get label {
    switch (this) {
      case SplitType.equal:
        return 'Equal';
      case SplitType.partial:
        return 'Partial';
      case SplitType.self:
        return 'Self';
      case SplitType.none:
        return '';
    }
  }

  static SplitType fromString(String? value) {
    if (value == null) {
      return SplitType.none;
    }

    switch (value.toLowerCase()) {
      case 'equal':
        return SplitType.equal;
      case 'partial':
        return SplitType.partial;
      case 'self':
        return SplitType.self;
      default:
        return SplitType.none;
    }
  }
}
