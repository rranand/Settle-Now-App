import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class LendenUserModel extends UserModel {
  bool active = false;

  LendenUserModel({
    required super.id,
    required super.name,
    required super.profileImage,
    required this.active,
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
    );
  }

  factory LendenUserModel.fromBasicInfoMap(Map<String, dynamic> map) {
    return LendenUserModel(
      id: map['id'],
      name: map['name'] ?? "",
      profileImage: map['profile_pic'] ?? "",
      active: map['active'],
    );
  }

  factory LendenUserModel.fromUserResolver(Map<String, dynamic> map) {
    UserModel userData = UserResolver.instance.resolve(map['id'] ?? "");

    return LendenUserModel(
      id: map['id'],
      name: map['name'] ?? userData.name,
      profileImage: map['profile_pic'] ?? userData.profileImage,
      active: map['active'],
    );
  }

  @override
  String toString() {
    return 'LendenUserModel(id: $id, name: $name, active: $active)';
  }
}
