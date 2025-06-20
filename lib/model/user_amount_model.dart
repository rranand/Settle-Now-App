// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

class UserAmountModel extends UserModel {
  double amount = 0;
  bool isSettled = false;

  UserAmountModel({
    required super.id,
    required super.name,
    required super.email,
    required super.profileImage,
    required this.amount,
  }) : super(
         hasData: true,
         createdOn: DateTime.now(),
         authToken: "",
         phoneNo: "",
       );

  UserAmountModel.empty()
    : super(
        id: "",
        name: "",
        email: "",
        profileImage: "",
        hasData: false,
        createdOn: DateTime.now(),
        authToken: "",
        phoneNo: "",
      );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['amount'] = amount;
    map['isSettled'] = isSettled;
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
    UserAmountModel newData = UserAmountModel(
      id: Crypto.decrypt(map['id']),
      name: Crypto.decrypt(map['name']),
      email: '',
      profileImage: Crypto.decrypt(map['profileImage']),
      amount: double.parse(Crypto.decrypt(map['amount'])),
    );
    newData.isSettled = Crypto.decrypt(map['isSettled']) == 'true';
    return newData;
  }

  @override
  String toJson() {
    return json.encode(toMap());
  }

  String toQuickSplitJson() {
    Map<String, String> data = {
      'id': Crypto.encrypt(id),
      'amount': Crypto.encrypt(amount.toString()),
      'isSettled': Crypto.encrypt(isSettled.toString()),
    };
    return json.encode(data);
  }

  @override
  factory UserAmountModel.fromJson(String source) =>
      UserAmountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserAmountModel(id: $id, name: $name, email: $email, profileImage: $profileImage, amount: $amount)';
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
  int get hashCode => amount.hashCode;
}
