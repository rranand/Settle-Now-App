enum RoomStatus { open, closed, partiallyClosed }

extension RoomStatusExtension on RoomStatus {
  String get label {
    switch (this) {
      case RoomStatus.open:
        return 'Open';
      case RoomStatus.closed:
        return 'Closed';
      case RoomStatus.partiallyClosed:
        return 'Partially Closed';
    }
  }
}
