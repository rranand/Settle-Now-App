import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenUserModel extends BaseUserModel {
  bool active;
  double gave;
  double owe;

  LendenUserModel({
    required super.id,
    required super.name,
    required super.profilePic,
    required this.active,
    required this.gave,
    required this.owe,
  }) : super();

  LendenUserModel.empty() : active = false, gave = 0, owe = 0, super.empty();

  factory LendenUserModel.fromUserModel(BaseUserModel user) {
    return LendenUserModel(
      id: user.id,
      name: user.name,
      profilePic: user.profilePic,
      active: true,
      gave: 0,
      owe: 0,
    );
  }

  factory LendenUserModel.fromUserResolver(Map<String, dynamic> map) {
    BaseUserModel userData = UserResolver.instance.resolve(map['id']);

    return LendenUserModel(
      id: userData.id,
      name: userData.name,
      profilePic: userData.profilePic,
      active: map['active'],
      gave: double.parse(map['gave'].toString()),
      owe: double.parse(map['owe'].toString()),
    );
  }

  double get netBalance => getPrecisedAmount(gave - owe);

  @override
  String toString() {
    return 'LendenUserModel(id: $id, name: $name, gave: $gave, owe: $owe, active: $active)';
  }

  @override
  bool operator ==(covariant LendenUserModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.active == active &&
        other.gave == gave &&
        other.owe == owe;
  }

  @override
  int get hashCode {
    return super.hashCode ^ active.hashCode ^ gave.hashCode ^ owe.hashCode;
  }
}
