import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomSettleModel {
  bool hasData = true;
  String id = "";
  BaseUserModel receiver = BaseUserModel.empty();
  BaseUserModel sender = BaseUserModel.empty();
  double amount = 0;
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();
  int activityCount;

  RoomSettleModel({
    required this.id,
    required this.receiver,
    required this.sender,
    required this.amount,
    required this.createdOn,
    required this.modifiedOn,
    required this.activityCount,
  });

  RoomSettleModel.empty({this.hasData = false}) : activityCount = 0;

  RoomSettleModel copyWith({
    String? id,
    UserModel? receiver,
    UserModel? sender,
    double? amount,
    DateTime? createdOn,
    DateTime? modifiedOn,
    int? activityCount,
  }) {
    return RoomSettleModel(
      id: id ?? this.id,
      receiver: receiver ?? this.receiver,
      sender: sender ?? this.sender,
      amount: amount ?? this.amount,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      activityCount: activityCount ?? this.activityCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'receiver': receiver.toMap(),
      'sender': sender.toMap(),
      'amount': amount,
      'created_on': createdOn.toString(),
      'modified_on': modifiedOn.toString(),
    };
  }

  factory RoomSettleModel.fromMap(Map<String, dynamic> map) {
    final receiver = UserResolver.instance.resolve(map['receiver'] ?? "");
    final sender = UserResolver.instance.resolve(map['sender'] ?? "");

    return RoomSettleModel(
      id: map['id'],
      receiver: receiver,
      sender: sender,
      amount: double.parse(map['amount'].toString()),
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      modifiedOn: DateTime.parse(map['modified_on']).toLocal(),
      activityCount: map['activity_count'] as int,
    );
  }

  Map<String, dynamic> toSettleTransactionJSON() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'sender': sender,
      'receiver': receiver,
    };
  }

  Map<String, dynamic> toUpdateTransactionJSON() {
    return <String, dynamic>{'id': id, 'amount': amount};
  }

  @override
  String toString() {
    return 'RoomSettleModel(id: $id, receiver: $receiver, sender: $sender, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn)';
  }

  @override
  bool operator ==(covariant RoomSettleModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.receiver.id == receiver.id &&
        other.sender.id == sender.id &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn &&
        other.activityCount == activityCount;
  }

  @override
  int get hashCode {
    return hasData.hashCode ^
        id.hashCode ^
        receiver.id.hashCode ^
        sender.id.hashCode ^
        amount.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        activityCount.hashCode;
  }
}
