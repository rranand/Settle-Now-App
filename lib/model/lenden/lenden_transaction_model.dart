import 'package:settlenow/model/model_core.dart';

class LendenTransactionModel extends BaseTransactionModel {
  LendenTransactionModel({
    required super.id,
    required super.amount,
    required super.description,
    required super.createdOn,
    required super.modifiedOn,
    required super.createdBy,
  }) : super();

  LendenTransactionModel.empty() : super.empty();

  @override
  LendenTransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    DateTime? createdOn,
    DateTime? modifiedOn,
    String? createdBy,
  }) {
    return LendenTransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      createdOn: createdOn ?? this.createdOn,
      createdBy: createdBy ?? this.createdBy,
      modifiedOn: modifiedOn ?? this.modifiedOn,
    );
  }

  factory LendenTransactionModel.fromMap(Map<String, dynamic> map) {
    final data = BaseTransactionModel.fromMap(map);

    return LendenTransactionModel(
      id: data.id,
      amount: data.amount,
      description: data.description,
      createdOn: data.createdOn,
      modifiedOn: data.modifiedOn,
      createdBy: data.createdBy,
    );
  }

  @override
  String toString() {
    return 'LendenTransactionModel(id: $id, amount: $amount, createdBy: $createdBy, description: $description, createdOn: $createdOn,)';
  }
}
