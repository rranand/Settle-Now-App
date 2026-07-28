enum RoomStatus { open, closed, partiallyClosed, none }

extension RoomStatusExtension on RoomStatus {
  String get label {
    switch (this) {
      case RoomStatus.open:
        return 'Open';
      case RoomStatus.closed:
        return 'Closed';
      case RoomStatus.partiallyClosed:
        return 'Partially Closed';
      default:
        return 'Unknown';
    }
  }

  static RoomStatus fromString(String? value) {
    if (value == null) {
      return RoomStatus.none;
    }

    switch (value.toLowerCase()) {
      case 'open':
        return RoomStatus.open;
      case 'partially closed':
        return RoomStatus.partiallyClosed;
      case 'closed':
        return RoomStatus.closed;
      default:
        return RoomStatus.none;
    }
  }
}
