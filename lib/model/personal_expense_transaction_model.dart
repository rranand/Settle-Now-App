// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:settlenow_v2/model/new_transaction_model.dart';

class RoomLinkedModel {
  bool hasData = true;
  String id = "";
  String roomName = "";
  String transactionID = "";
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();

  RoomLinkedModel({
    required this.id,
    required this.roomName,
    required this.transactionID,
    required this.createdOn,
    required this.modifiedOn,
  });

  RoomLinkedModel.empty({this.hasData = false});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'roomName': roomName,
      'transactionID': transactionID,
      'createdOn': createdOn,
      'modifiedOn': modifiedOn,
    };
  }

  factory RoomLinkedModel.fromMap(Map<String, dynamic> map) {
    return RoomLinkedModel(
      id: map['id'] as String,
      roomName: map['roomName'] as String,
      transactionID: map['transactionID'] as String,
      createdOn: DateTime.parse(map['createdOn']),
      modifiedOn: DateTime.parse(map['modifiedOn']),
    );
  }

  String toJson() => json.encode(toMap());

  factory RoomLinkedModel.fromJson(String source) =>
      RoomLinkedModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'RoomLinkedModel(id: $id, RoomName: $roomName, TransactionID: $transactionID)';
  }
}

class PersonalExpenseTransactionModel {
  bool hasData = true;
  String id = "";
  double amount = 0;
  String description = "";
  String category = "";
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();
  RoomLinkedModel roomData = RoomLinkedModel.empty();

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
        id: map['id'] as String,
        amount: map['amount'] as double,
        description: map['description'] as String,
        category: map['category'] as String,
        createdOn: DateTime.parse(map['createdOn']),
        modifiedOn: DateTime.parse(map['modifiedOn']),
        roomData: RoomLinkedModel.fromMap(map['roomData']),
      );
    } else {
      return PersonalExpenseTransactionModel(
        id: map['id'] as String,
        amount: map['amount'] as double,
        description: map['description'] as String,
        category: map['category'] as String,
        createdOn: DateTime.parse(map['createdOn']),
        modifiedOn: DateTime.parse(map['modifiedOn']),
        roomData: RoomLinkedModel.empty(),
      );
    }
  }

  String toJson() => json.encode(toMap());

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
