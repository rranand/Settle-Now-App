import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class QuicksplitUserModel extends UserAmountModel {
  bool isSettled;

  QuicksplitUserModel({
    required super.id,
    required super.name,
    required super.profilePic,
    required super.amount,
    required this.isSettled,
  });

  QuicksplitUserModel.empty() : isSettled = false, super.empty();

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{...super.toMap(), 'is_settled': isSettled};
  }

  @override
  QuicksplitUserModel copyWith({
    String? id,
    String? name,
    String? profilePic,
    String? phoneNo,
    double? amount,
    bool? isSettled,
  }) {
    return QuicksplitUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  factory QuicksplitUserModel.fromUserAmountObject(
    UserAmountModel data, {
    bool? isSettled,
  }) {
    return QuicksplitUserModel(
      id: data.id,
      name: data.name,
      profilePic: data.profilePic,
      amount: data.amount,
      isSettled: isSettled ?? false,
    );
  }

  factory QuicksplitUserModel.fromBaseObject(
    BaseUserModel data, {
    double? amount,
    bool? isSettled,
  }) {
    return QuicksplitUserModel(
      id: data.id,
      name: data.name,
      profilePic: data.profilePic,
      amount: amount ?? 0,
      isSettled: isSettled ?? false,
    );
  }

  factory QuicksplitUserModel.fromMap(Map<String, dynamic> map) {
    String name = map['name'] ?? "";
    BaseUserModel baseData = BaseUserModel.empty();

    if (name.isEmpty) {
      baseData = UserResolver.instance.resolve(map['id']);
    } else {
      baseData = BaseUserModel(id: name, name: name, profilePic: "");
    }

    if (!baseData.hasData) {
      baseData = baseData.copyWith(
        id: map['name'] ?? "",
        name: map['name'] ?? "",
      );
    }

    return QuicksplitUserModel.fromBaseObject(
      baseData,
      amount: double.parse(map['amount'].toString()),
      isSettled: map['is_settled'],
    );
  }

  @override
  String toString() {
    return 'QuicksplitUserModel(id: $id, name: $name, amount: $amount, is_settled: $isSettled)';
  }

  @override
  bool operator ==(covariant QuicksplitUserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.isSettled == isSettled;
  }

  @override
  int get hashCode => super.hashCode ^ isSettled.hashCode;
}
