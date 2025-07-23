// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow_v2/model/common_transaction_field.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

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
      'roomName': roomName,
      'transactionType': transactionType,
    };
  }

  factory RoomLinkedModel.fromMap(Map<String, dynamic> map) {
    return RoomLinkedModel(
      id: Crypto.decrypt(map['id']),
      roomName: Crypto.decrypt(map['roomName']),
      transactionType: Crypto.decrypt(map['transactionType']),
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomLinkedModel.fromJson(String source) =>
      RoomLinkedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomLinkedModel(id: $id, RoomName: $roomName, TransactionType: $transactionType)';
  }
}

class PersonalExpenseTransactionModel implements CommonTransactionField {
  bool hasData = true;
  String id = "";
  String category = "";
  DateTime modifiedOn = DateTime.now();
  RoomLinkedModel roomData = RoomLinkedModel.empty();

  @override
  double amount = 0;
  @override
  String description = "";
  @override
  DateTime createdOn = DateTime.now();

  PersonalExpenseTransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.createdOn,
    required this.modifiedOn,
    required this.roomData,
  });

  PersonalExpenseTransactionModel.empty({this.hasData = false});

  PersonalExpenseTransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    String? category,
    DateTime? createdOn,
    DateTime? modifiedOn,
    RoomLinkedModel? roomData,
  }) {
    return PersonalExpenseTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      roomData: roomData ?? this.roomData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'description': description,
      'category': category,
      'createdOn': createdOn.toString(),
      'modifiedOn': modifiedOn.toString(),
      'roomData': roomData.toMap(),
    };
  }

  factory PersonalExpenseTransactionModel.fromNewTransaction(
    NewTransactionModel data,
  ) {
    return PersonalExpenseTransactionModel(
      id: data.id,
      amount: data.amount,
      description: data.description,
      category: data.category,
      createdOn: data.createdOn,
      modifiedOn: data.createdOn,
      roomData: RoomLinkedModel.empty(),
    );
  }

  @override
  factory PersonalExpenseTransactionModel.fromMap(Map<String, dynamic> map) {
    if (map.containsKey('roomData') && map['roomData'] != null) {
      return PersonalExpenseTransactionModel(
        id: Crypto.decrypt(map['id']),
        amount: double.parse(Crypto.decrypt(map['amount'])),
        description: Crypto.decrypt(map['description']),
        category: Crypto.decrypt(map['category']),
        createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
        modifiedOn: DateTime.parse(Crypto.decrypt(map['modifiedOn'])).toLocal(),
        roomData: RoomLinkedModel.fromMap(map['roomData']),
      );
    } else {
      return PersonalExpenseTransactionModel(
        id: Crypto.decrypt(map['id']),
        amount: double.parse(Crypto.decrypt(map['amount'])),
        description: Crypto.decrypt(map['description']),
        category: Crypto.decrypt(map['category']),
        createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
        modifiedOn: DateTime.parse(Crypto.decrypt(map['modifiedOn'])).toLocal(),
        roomData: RoomLinkedModel.empty(),
      );
    }
  }

  String toJson() => json.encode(toMap());

  String toCreateNewExpenseJson() {
    Map<String, String> data = {
      "id": Crypto.encrypt(id),
      "description": Crypto.encrypt(description),
      "amount": Crypto.encrypt(amount.toString()),
      "category": Crypto.encrypt(category),
      "createdOn": Crypto.encrypt(createdOn.toIso8601String()),
    };
    return json.encode(data);
  }

  factory PersonalExpenseTransactionModel.fromJson(String source) =>
      PersonalExpenseTransactionModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  String toString() {
    return 'PersonalExpenseTransactionModel(id: $id, amount: $amount, description: $description, category: $category, createdOn: $createdOn, modifiedOn: $modifiedOn, roomData: $roomData)';
  }

  @override
  bool operator ==(covariant PersonalExpenseTransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.category == category &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn &&
        other.roomData == roomData;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        category.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        roomData.hashCode;
  }
}
