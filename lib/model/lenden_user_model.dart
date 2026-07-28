import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenUserModel extends UserModel {
  bool active = false;
  double gave = 0;
  double owe = 0;

  LendenUserModel({
    required super.id,
    required super.name,
    required super.profileImage,
    required this.active,
    required this.gave,
    required this.owe,
  }) : super(hasData: true, createdOn: DateTime.now(), email: "", phoneNo: "");

  LendenUserModel.empty()
    : super(
        id: "",
        name: "",
        email: "",
        profileImage: "",
        hasData: false,
        createdOn: DateTime.now(),
        phoneNo: "",
      );

  factory LendenUserModel.fromUserModel(UserModel user) {
    return LendenUserModel(
      id: user.id,
      name: user.name,
      profileImage: user.profileImage,
      active: false,
      gave: 0,
      owe: 0,
    );
  }

  factory LendenUserModel.fromBasicInfoMap(Map<String, dynamic> map) {
    return LendenUserModel(
      id: map['id'],
      name: map['name'] ?? "",
      profileImage: map['profile_pic'] ?? "",
      active: map['active'],
      gave: double.parse(map['gave'].toString()),
      owe: double.parse(map['owe'].toString()),
    );
  }

  factory LendenUserModel.fromUserResolver(Map<String, dynamic> map) {
    UserModel userData = UserResolver.instance.resolve(map['id'] ?? "");

    return LendenUserModel(
      id: map['id'],
      name: map['name'] ?? userData.name,
      profileImage: map['profile_pic'] ?? userData.profileImage,
      active: map['active'],
      gave: double.parse(map['gave'].toString()),
      owe: double.parse(map['owe'].toString()),
    );
  }

  @override
  String toString() {
    return 'LendenUserModel(id: $id, name: $name, gave: $gave, owe: $owe, active: $active)';
  }
}
