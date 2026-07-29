// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/resolver/user_resolver.dart';

class UserAmountModel extends UserModel {
  double amount = 0;
  bool isSettled = false;

  UserAmountModel({
    required super.id,
    required super.name,
    required super.profileImage,
    required this.amount,
  }) : super(hasData: true, createdOn: DateTime.now(), phoneNo: "", email: "");

  UserAmountModel.empty()
    : super(
        id: "",
        name: "",
        email: "",
        profileImage: "",
        hasData: false,
        createdOn: DateTime.now(),
        phoneNo: "",
      );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['amount'] = amount;
    map['is_settled'] = isSettled;
    return map;
  }

  factory UserAmountModel.copyFromUser(UserModel user, double amount) {
    return UserAmountModel(
      id: user.id,
      name: user.name,
      profileImage: user.profileImage,
      amount: amount,
    );
  }

  factory UserAmountModel.fromMap(Map<String, dynamic> map) {
    UserModel userData = UserResolver.instance.resolve(map['id'] ?? "");

    if (!userData.hasData) {
      userData = UserModel.fromBasicInfo(
        id: map['name'] ?? "",
        name: map['name'] ?? "",
        profileImage: "",
      );
    }

    UserAmountModel newData = UserAmountModel.copyFromUser(
      userData,
      double.parse(map['amount'].toString()),
    );

    if (map.containsKey('is_settled')) {
      newData.isSettled = map['is_settled'];
    }
    return newData;
  }

  @override
  String toJson() {
    return json.encode(toMap());
  }

  String toQuickSplitJson() {
    Map<String, dynamic> data = {
      'id': id,
      'amount': amount.toString(),
      'is_settled': isSettled,
    };
    return json.encode(data);
  }

  factory UserAmountModel.fromJson(String source) =>
      UserAmountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserAmountModel(id: $id, name: $name, amount: $amount, is_settled: $isSettled)';
  }

  @override
  bool operator ==(covariant UserAmountModel other) {
    if (identical(this, other)) return true;

    return other.amount == amount &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profileImage == profileImage &&
        other.isSettled == isSettled;
  }

  @override
  int get hashCode =>
      super.hashCode ^ amount.hashCode ^ isSettled.hashCode ^ id.hashCode;
}
