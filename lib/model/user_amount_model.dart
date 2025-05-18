import 'dart:convert';

import 'package:settlenow_v2/model/user_model.dart';

class UserAmountModel extends UserModel {
  double amount = 0;

  UserAmountModel({
    super.hasData = true,
    required super.id,
    required super.name,
    required super.email,
    required super.profileImage,
    required this.amount,
  });

  UserAmountModel.empty({
    super.id = "",
    super.name = "",
    super.email = "",
    super.profileImage = "",
    super.hasData = false,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['amount'] = amount;
    return map;
  }

  @override
  factory UserAmountModel.copyFromUser(UserModel user, double amount) {
    return UserAmountModel(
      id: user.id,
      name: user.name,
      email: user.email,
      profileImage: user.profileImage,
      amount: amount,
    );
  }

  @override
  factory UserAmountModel.fromMap(Map<String, dynamic> map) {
    return UserAmountModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
    );
  }

  @override
  String toJson() {
    return json.encode(toMap());
  }

  @override
  factory UserAmountModel.fromJson(String source) =>
      UserAmountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserAmountModel(name: $name, email: $email, amount: $amount)';
  }
}
