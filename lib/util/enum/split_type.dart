enum SplitType { equal, partial, self }

extension SplitTypeExtension on SplitType {
  String get label {
    switch (this) {
      case SplitType.partial:
        return 'Partial';
      case SplitType.self:
        return 'Self';
      default:
        return 'Equal';
    }
  }

  static SplitType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'partial':
        return SplitType.partial;
      case 'self':
        return SplitType.self;
      default:
        return SplitType.equal;
    }
  }
}
