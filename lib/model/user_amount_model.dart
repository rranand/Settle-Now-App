import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class UserAmountModel extends BaseUserModel {
  double amount;

  UserAmountModel({
    required super.id,
    required super.name,
    required super.profilePic,
    required this.amount,
  }) : super();

  UserAmountModel.empty() : amount = 0, super.empty();

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'amount': amount};
  }

  @override
  UserAmountModel copyWith({
    String? id,
    String? name,
    String? profilePic,
    String? phoneNo,
    double? amount,
  }) {
    return UserAmountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      amount: amount ?? this.amount,
    );
  }

  factory UserAmountModel.fromBaseObject(BaseUserModel data, {double? amount}) {
    return UserAmountModel(
      id: data.id,
      name: data.name,
      profilePic: data.profilePic,
      amount: amount ?? 0,
    );
  }

  factory UserAmountModel.fromMap(Map<String, dynamic> map) {
    BaseUserModel baseData = UserResolver.instance.resolve(map['id'] ?? "");

    if (!baseData.hasData) {
      baseData = baseData.copyWith(
        id: map['name'] ?? "",
        name: map['name'] ?? "",
      );
    }

    final newData = baseData as UserAmountModel;

    return newData.copyWith(amount: double.parse(map['amount'].toString()));
  }

  @override
  String toString() {
    return 'UserAmountModel(id: $id, name: $name, amount: $amount)';
  }

  @override
  bool operator ==(covariant UserAmountModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.amount == amount;
  }

  @override
  int get hashCode => super.hashCode ^ amount.hashCode;
}
