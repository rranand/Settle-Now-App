import 'package:settlenow/util/util_core.dart';

class BankTransactionConsumedModel {
  final String id;
  final RoomType roomType;
  final String roomId;
  final String? transactionId;

  BankTransactionConsumedModel({
    required this.id,
    required this.roomType,
    required this.roomId,
    required this.transactionId,
  });

  factory BankTransactionConsumedModel.fromMap(Map<String, dynamic> map) {
    return BankTransactionConsumedModel(
      id: map['id'] as String,
      roomType: RoomType.values.firstWhere(
        (e) => e.toString() == 'RoomType.${map['room_type']}',
        orElse: () => RoomType.none,
      ),
      roomId: map['room_id'] as String,
      transactionId: map['transaction_id'] as String?,
    );
  }
}
