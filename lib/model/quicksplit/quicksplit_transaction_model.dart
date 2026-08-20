import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class QuicksplitTransactionModel
    extends MultiUserBaseTransactionModel<QuicksplitUserModel> {
  String personalExpenseId;
  bool active;
  bool isClosedAny;

  QuicksplitTransactionModel({
    required super.id,
    required super.amount,
    required super.category,
    required super.description,
    required super.createdOn,
    required super.modifiedOn,
    required super.createdBy,
    required super.users,
    required this.personalExpenseId,
    required this.active,
    required this.isClosedAny,
  }) : super();

  QuicksplitTransactionModel.empty()
    : personalExpenseId = '',
      active = false,
      isClosedAny = false,
      super.empty();

  @override
  QuicksplitTransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? createdOn,
    DateTime? modifiedOn,
    String? createdBy,
    List<QuicksplitUserModel>? users,
    SplitType? splitType,
    String? category,
    String? personalExpenseId,
    bool? active,
    bool? isClosedAny,
  }) {
    return QuicksplitTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      category: category ?? this.category,
      users: users ?? this.users,
      personalExpenseId: personalExpenseId ?? this.personalExpenseId,
      active: active ?? this.active,
      isClosedAny: isClosedAny ?? this.isClosedAny,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'personal_expense_id': personalExpenseId,
      'active': active,
      'is_closed_any': isClosedAny,
    };
  }

  factory QuicksplitTransactionModel.fromMap(Map<String, dynamic> map) {
    map['split_type'] = SplitType.partial.label;

    final data = MultiUserBaseTransactionModel.fromMap(
      map,
      QuicksplitUserModel.fromMap,
    );

    return QuicksplitTransactionModel(
      id: data.id,
      amount: data.amount,
      category: data.category,
      description: data.description,
      createdOn: data.createdOn,
      modifiedOn: data.modifiedOn,
      createdBy: data.createdBy,
      users: data.users,
      personalExpenseId: map['personal_expense_id'] ?? "",
      active: map['active'],
      isClosedAny: map['is_closed_any'],
    );
  }

  @override
  String toString() {
    return 'QuicksplitTransactionModel(id: $id, description: $description, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn, createdBy: $createdBy, category: $category, active:$active, personalExpenseId:$personalExpenseId, isClosedAny:$isClosedAny)';
  }

  @override
  bool operator ==(covariant QuicksplitTransactionModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.createdBy == createdBy &&
        other.category == category &&
        other.personalExpenseId == personalExpenseId &&
        other.active == active &&
        other.isClosedAny == isClosedAny &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return super.hashCode ^
        personalExpenseId.hashCode ^
        active.hashCode ^
        isClosedAny.hashCode;
  }
}
