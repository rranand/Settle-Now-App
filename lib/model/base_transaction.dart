import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class BaseTransaction {
  String id;
  String category;
  double amount;
  SplitType splitType;
  DateTime createdOn;
  DateTime modifiedOn;
  String createdBy;
  List<UserAmountModel> users;

  BaseTransaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.splitType,
    required this.createdOn,
    required this.modifiedOn,
    required this.createdBy,
    required this.users,
  });

  BaseTransaction copyWith({
    String? id,
    String? category,
    double? amount,
    SplitType? splitType,
    DateTime? createdOn,
    DateTime? modifiedOn,
    String? createdBy,
    List<UserAmountModel>? users,
  }) {
    return BaseTransaction(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      splitType: splitType ?? this.splitType,
      createdOn: createdOn ?? this.createdOn,
      modifiedOn: modifiedOn ?? this.modifiedOn,
      createdBy: createdBy ?? this.createdBy,
      users: users ?? this.users,
    );
  }
}
