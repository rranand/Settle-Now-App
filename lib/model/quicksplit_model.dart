// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/model/user_amount_model.dart';

class QuickSplitModel {
  bool hasData = true;
  String id = "";
  String description = "";
  double amount = 0;
  List<String> tags = [];
  String category = "";
  UserAmountModel createdBy = UserAmountModel.empty();
  List<UserAmountModel> users = [];
  DateTime createdOn = DateTime.now();
  DateTime modifiedOn = DateTime.now();

  QuickSplitModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.tags,
    required this.category,
    required this.users,
    required this.createdBy,
    required this.createdOn,
    required this.modifiedOn,
  });

  QuickSplitModel.empty({this.hasData = false});

  QuickSplitModel copyWith({
    String? id,
    String? description,
    double? amount,
    List<String>? tags,
    String? category,
    List<UserAmountModel>? users,
    UserAmountModel? createdBy,
    DateTime? createdOn,
    DateTime? modifiedOn,
  }) {
    return QuickSplitModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      users: users ?? this.users,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'tags': tags,
      'category': category,
      'users': users.map((x) => x.toMap()).toList(),
      'createdBy': createdBy.toMap(),
      'createdOn': createdOn.toString(),
      'modifiedOn': modifiedOn.toString(),
    };
  }

  factory QuickSplitModel.fromMap(Map<String, dynamic> map) {
    return QuickSplitModel(
      id: map['id'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double,
      tags: List<String>.from(map['tags']),
      category: map['category'] as String,
      users: List<UserAmountModel>.from(
        (map['users']).map((x) => UserAmountModel.fromMap(x)),
      ),
      createdBy: UserAmountModel.fromMap(map['createdBy']),
      createdOn: DateTime.parse(map['createdOn']),
      modifiedOn: DateTime.parse(map['modifiedOn']),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuickSplitModel.fromJson(String source) =>
      QuickSplitModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'QuickSplitModel(id: $id, description: $description, amount: $amount, tags: $tags, category: $category)';
  }

  @override
  bool operator ==(covariant QuickSplitModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        listEquals(other.tags, tags) &&
        other.category == category &&
        listEquals(other.users, users) &&
        other.createdBy == createdBy &&
        other.createdOn == createdOn &&
        other.modifiedOn == modifiedOn;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        tags.hashCode ^
        category.hashCode ^
        users.hashCode ^
        createdBy.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode;
  }
}
