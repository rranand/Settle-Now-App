import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class RoomUserModel extends BaseUserModel {
  double contribution;
  double spent;
  double settle;
  bool active;

  RoomUserModel({
    required super.id,
    required super.name,
    required super.profilePic,
    required this.contribution,
    required this.spent,
    required this.settle,
    required this.active,
  });

  RoomUserModel.empty()
    : contribution = 0,
      spent = 0,
      settle = 0,
      active = false,
      super.empty();

  @override
  RoomUserModel copyWith({
    String? id,
    String? name,
    String? profilePic,
    double? contribution,
    double? spent,
    double? settle,
    bool? active,
  }) {
    return RoomUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      contribution: contribution ?? this.contribution,
      spent: spent ?? this.spent,
      settle: settle ?? this.settle,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'contribution': contribution,
      'spent': spent,
      'settle': settle,
      'active': active,
    };
  }

  factory RoomUserModel.fromMap(Map<String, dynamic> map) {
    final data = (UserResolver.instance.resolve(map['id'] ?? ""));

    return RoomUserModel(
      id: data.id,
      name: data.name,
      profilePic: data.profilePic,
      contribution: double.parse(map['contribution'].toString()),
      spent: double.parse(map['spent'].toString()),
      settle: double.parse(map['settle'].toString()),
      active: map['active'],
    );
  }

  @override
  String toString() {
    return 'RoomUserModel(id: $id, active: $active contribution: $contribution, spent: $spent, settle: $settle)';
  }

  @override
  bool operator ==(covariant RoomUserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.active == active &&
        other.contribution == contribution &&
        other.spent == spent &&
        other.settle == settle;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        active.hashCode ^
        contribution.hashCode ^
        spent.hashCode ^
        settle.hashCode;
  }
}
