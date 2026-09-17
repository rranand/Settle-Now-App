enum RoomType { room, quicksplit, lenden, personal, none }

extension RoomTypeExtension on RoomType {
  String get label {
    switch (this) {
      case RoomType.room:
        return 'Room';
      case RoomType.quicksplit:
        return 'Quicksplit';
      case RoomType.lenden:
        return 'Lenden';
      case RoomType.personal:
        return 'Personal';
      case RoomType.none:
        return '';
    }
  }

  static RoomType fromString(String? value) {
    if (value == null) {
      return RoomType.none;
    }

    switch (value.toLowerCase()) {
      case 'room':
        return RoomType.room;
      case 'quicksplit':
        return RoomType.quicksplit;
      case 'lenden':
        return RoomType.lenden;
      case 'personal':
        return RoomType.personal;
      default:
        return RoomType.none;
    }
  }
}
