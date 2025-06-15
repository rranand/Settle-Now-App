import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/handler/crypto.dart';

class LendenUserModel extends UserModel {
  bool isClosed = false;

  LendenUserModel({
    required super.id,
    required super.name,
    required super.profileImage,
    required this.isClosed,
  }) : super(
         hasData: true,
         createdOn: DateTime.now(),
         authToken: "",
         email: "",
         phoneNo: "",
       );

  LendenUserModel.empty()
    : super(
        id: "",
        name: "",
        email: "",
        profileImage: "",
        hasData: false,
        createdOn: DateTime.now(),
        authToken: "",
        phoneNo: "",
      );

  @override
  factory LendenUserModel.fromUserModel(UserModel user) {
    return LendenUserModel(
      id: user.id,
      name: user.name,
      profileImage: user.profileImage,
      isClosed: false,
    );
  }

  @override
  factory LendenUserModel.fromBasicInfoMap(Map<String, dynamic> map) {
    return LendenUserModel(
      id: Crypto.decrypt(map['id']),
      name: Crypto.decrypt(map['name']),
      profileImage: Crypto.decrypt(map['profileImage']),
      isClosed: Crypto.decrypt(map['isClosed']) == "true",
    );
  }
}
