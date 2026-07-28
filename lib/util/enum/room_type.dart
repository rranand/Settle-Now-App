enum RoomType { room, quicksplit, lenden, none }

extension RoomTypeExtension on RoomType {
  String get label {
    switch (this) {
      case RoomType.room:
        return 'Room';
      case RoomType.quicksplit:
        return 'Quicksplit';
      case RoomType.lenden:
        return 'Lenden';
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
      default:
        return RoomType.none;
    }
  }
}
