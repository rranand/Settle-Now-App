import 'dart:convert';

import 'package:settlenow_v2/model/user_model.dart';

class LendenRoomModel {
  bool hasData = true;
  String id = "";
  double amount = 0;
  String description = "";
  DateTime createdOn = DateTime.now();
  UserModel createdBy = UserModel.empty();
  DateTime modifiedOn = DateTime.now();

  LendenRoomModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.createdOn,
    required this.createdBy,
    required this.modifiedOn,
  });

  LendenRoomModel.empty({this.hasData = false});

  LendenRoomModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? createdOn,
    UserModel? createdBy,
    DateTime? modifiedOn,
  }) {
    return LendenRoomModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'description': description,
      'createdOn': createdOn.toString(),
      'createdBy': createdBy,
      'modifiedOn': modifiedOn.toString(),
    };
  }

  factory LendenRoomModel.fromMap(Map<String, dynamic> map) {
    return LendenRoomModel(
      id: map['id'] as String,
      amount: map['amount'] as double,
      description: map['description'] as String,
      createdOn: DateTime.parse(map['createdOn']),
      createdBy: UserModel.fromBasicInfoMap(map['createdBy']),
      modifiedOn: DateTime.parse(map['modifiedOn']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LendenRoomModel.fromJson(String source) =>
      LendenRoomModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LendenRoomModel(id: $id, amount: $amount, createdBy: $createdBy, description: $description)';
  }

  @override
  bool operator ==(covariant LendenRoomModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.createdOn == createdOn &&
        other.createdBy == createdBy &&
        other.modifiedOn == modifiedOn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        createdOn.hashCode ^
        createdBy.hashCode ^
        modifiedOn.hashCode;
  }
}
