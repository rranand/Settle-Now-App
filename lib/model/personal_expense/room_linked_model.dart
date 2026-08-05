import 'package:settlenow/util/util_core.dart';

class RoomLinkedModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  TransactionType transactionType = TransactionType.room;

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
      'transaction_type': transactionType.toString(),
    };
  }

  factory RoomLinkedModel.fromMap(Map<String, dynamic> map) {
    String id = map['id'] ?? "";

    if (id.isEmpty) {
      return RoomLinkedModel.empty();
    }

    return RoomLinkedModel(
      id: id,
      roomName: map['room_name'],
      transactionType: TransactionTypeExtension.fromString(
        map['transaction_type'] ?? "",
      ),
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
