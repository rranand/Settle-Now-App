// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow/model/user_model.dart';

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
    map['isSettled'] = isSettled;
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

  factory UserAmountModel.fromBasicInfoMap(Map<String, dynamic> map) {
    UserAmountModel newData = UserAmountModel(
      id: map['id'],
      name: map['name'] ?? "",
      profileImage: map['profileImage'] ?? "",
      amount: double.parse(map['amount'].toString()),
    );
    if (map.containsKey('isSettled')) {
      newData.isSettled = map['isSettled'];
    }
    return newData;
  }

  factory UserAmountModel.fromMap(Map<String, dynamic> map) {
    UserAmountModel newData = UserAmountModel(
      id: map['id'],
      name: map['name'],
      profileImage: map['profileImage'],
      amount: double.parse(map['amount'].toString()),
    );
    if (map.containsKey('isSettled')) {
      newData.isSettled = map['isSettled'];
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
      'isSettled': isSettled,
    };
    return json.encode(data);
  }

  factory UserAmountModel.fromJson(String source) =>
      UserAmountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserAmountModel(id: $id, name: $name, amount: $amount , isSettled: $isSettled)';
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
  int get hashCode => amount.hashCode ^ isSettled.hashCode ^ id.hashCode;
}
