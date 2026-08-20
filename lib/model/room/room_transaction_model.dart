import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/model/model_core.dart';

class RoomTransactionModel
    extends MultiUserBaseTransactionModel<UserAmountModel> {
  String personalExpenseId;
  int activityCount;

  RoomTransactionModel({
    required super.id,
    required super.amount,
    required super.category,
    required super.description,
    required super.createdOn,
    required super.modifiedOn,
    required super.createdBy,
    required super.users,
    required this.personalExpenseId,
    required this.activityCount,
  });

  RoomTransactionModel.empty()
    : personalExpenseId = "",
      activityCount = 0,
      super.empty();

  @override
  RoomTransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? createdOn,
    DateTime? modifiedOn,
    String? createdBy,
    List<UserAmountModel>? users,
    String? category,
    String? personalExpenseId,
    int? activityCount,
  }) {
    return RoomTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      category: category ?? this.category,
      users: users ?? this.users,
      personalExpenseId: personalExpenseId ?? this.personalExpenseId,
      activityCount: activityCount ?? this.activityCount,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'personal_expense_id': personalExpenseId,
      'activity_count': activityCount,
    };
  }

  factory RoomTransactionModel.fromMap(Map<String, dynamic> map) {
    final data = MultiUserBaseTransactionModel.fromMap(
      map,
      UserAmountModel.fromMap,
    );

    return RoomTransactionModel(
      id: data.id,
      amount: data.amount,
      category: data.category,
      description: data.description,
      createdOn: data.createdOn,
      modifiedOn: data.modifiedOn,
      createdBy: data.createdBy,
      users: data.users,
      personalExpenseId: map['personal_expense_id'] ?? "",
      activityCount: map['activity_count'] as int,
    );
  }

  factory RoomTransactionModel.fromBulkTransaction(
    BulkTransactionModel data,
    String id,
    String createdByUID,
    List<RoomUserModel> users,
  ) {
    List<UserAmountModel> userWithAmount = [];
    int amountInPaisa =
        (Decimal.parse(data.amount.toString()) * Decimal.fromInt(100))
            .toBigInt()
            .toInt();
    int remaining = amountInPaisa % users.length;
    int eachAmount = (amountInPaisa / users.length).toInt();

    for (int i = 0; i < users.length; i++) {
      userWithAmount.add(
        UserAmountModel.fromBaseObject(
          users[i],
          amount: ((eachAmount + (remaining > 0 ? 1 : 0)) / 100),
        ),
      );
      remaining--;
    }

    return RoomTransactionModel(
      id: id,
      amount: data.amount,
      category: data.category,
      description: data.description,
      createdOn: DateTime.now(),
      modifiedOn: DateTime.now(),
      createdBy: createdByUID,
      users: userWithAmount,
      personalExpenseId: "",
      activityCount: 1,
    );
  }

  @override
  String toString() {
    return 'RoomTransactionModel(id: $id, description: $description, amount: $amount, createdOn: $createdOn, modifiedOn: $modifiedOn, createdBy: $createdBy, category: $category)';
  }

  @override
  bool operator ==(covariant RoomTransactionModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.createdOn == createdOn &&
        other.createdBy == createdBy &&
        other.category == category &&
        other.activityCount == activityCount &&
        listEquals(other.users, users);
  }

  @override
  int get hashCode {
    return hasData.hashCode ^
        id.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        createdOn.hashCode ^
        modifiedOn.hashCode ^
        createdBy.hashCode ^
        category.hashCode ^
        users.hashCode ^
        activityCount.hashCode ^
        personalExpenseId.hashCode;
  }
}
