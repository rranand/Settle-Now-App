import 'dart:convert';

import 'package:settlenow_v2/model/user_model.dart';

class LenDenModel {
  double amount;
  String direction;
  String description;
  DateTime createdOn;
  UserModel createdBy;
  DateTime modifiedOn;

  LenDenModel({
    required this.amount,
    required this.direction,
    required this.description,
    required this.createdOn,
    required this.createdBy,
    required this.modifiedOn,
  });

  LenDenModel copyWith({
    double? amount,
    String? direction,
    String? description,
    DateTime? createdOn,
    UserModel? createdBy,
    DateTime? modifiedOn,
  }) {
    return LenDenModel(
      amount: amount ?? this.amount,
      direction: direction ?? this.direction,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'direction': direction,
      'description': description,
      'createdOn': createdOn.toString(),
      'createdBy': createdBy,
      'modifiedOn': modifiedOn.toString(),
    };
  }

  factory LenDenModel.fromMap(Map<String, dynamic> map) {
    return LenDenModel(
      amount: map['amount'] as double,
      direction: map['direction'] as String,
      description: map['description'] as String,
      createdOn: DateTime.parse(map['createdOn']),
      createdBy: UserModel.fromMap(map['createdBy']),
      modifiedOn: DateTime.parse(map['modifiedOn']),
    );
  }

  String toJson() => json.encode(toMap());

  factory LenDenModel.fromJson(String source) =>
      LenDenModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'LenDenModel(amount: $amount, direction: $direction, description: $description)';
  }

  @override
  bool operator ==(covariant LenDenModel other) {
    if (identical(this, other)) return true;

    return other.amount == amount &&
        other.direction == direction &&
        other.description == description &&
        other.createdOn == createdOn &&
        other.createdBy == createdBy &&
        other.modifiedOn == modifiedOn;
  }

  @override
  int get hashCode {
    return amount.hashCode ^
        direction.hashCode ^
        description.hashCode ^
        createdOn.hashCode ^
        createdBy.hashCode ^
        modifiedOn.hashCode;
  }
}
