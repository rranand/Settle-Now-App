class RoomLinkedModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String transactionType = "";

  RoomLinkedModel({
    required this.id,
    required this.roomName,
    required this.transactionType,
  });

  RoomLinkedModel.empty({this.hasData = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'room_name': roomName,
      'transaction_type': transactionType,
    };
  }

  factory RoomLinkedModel.fromMap(Map<String, dynamic> map) {
    return RoomLinkedModel(
      id: map['id'],
      roomName: map['room_name'],
      transactionType: map['transaction_type'],
    );
  }

  @override
  String toString() {
    return 'RoomLinkedModel(id: $id, RoomName: $roomName, TransactionType: $transactionType)';
  }

  @override
  bool operator ==(covariant RoomLinkedModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.roomName == roomName &&
        other.transactionType == transactionType;
  }

  @override
  int get hashCode =>
      hasData.hashCode ^
      id.hashCode ^
      roomName.hashCode ^
      transactionType.hashCode;
}
