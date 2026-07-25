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
