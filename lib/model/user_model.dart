import 'dart:convert';

import 'package:settlenow_v2/util/handler/crypto.dart';

class UserModel {
  bool hasData = true;
  String id = "";
  String name = "";
  String email = "";
  String profileImage = "";
  DateTime createdOn = DateTime.now();
  String authToken = "";
  String phoneNo = "";
  bool isGoogle = false;

  UserModel({
    this.hasData = true,
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.createdOn,
    required this.authToken,
    required this.phoneNo,
  });

  UserModel.fromBasicInfo({
    required this.id,
    required this.name,
    required this.profileImage,
  });

  UserModel.empty({this.hasData = false});

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? createdOn,
    String? authToken,
    String? phoneNo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdOn: createdOn ?? this.createdOn,
      authToken: authToken ?? this.authToken,
      phoneNo: phoneNo ?? this.phoneNo,
    );
  }

  factory UserModel.copyFromUser(UserModel data) {
    return UserModel(
      id: data.id,
      name: data.name,
      email: data.email,
      profileImage: data.profileImage,
      createdOn: data.createdOn,
      authToken: data.authToken,
      phoneNo: data.phoneNo,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }

  factory UserModel.fromBasicInfoMap(Map<String, dynamic> map) {
    return UserModel.fromBasicInfo(
      id: Crypto.decrypt(map['id']),
      name: Crypto.decrypt(map['name'] ?? ""),
      profileImage: Crypto.decrypt(map['profileImage'] ?? ""),
    );
  }

  factory UserModel.forOwnerInfo(Map<String, dynamic> map, String authToken) {
    UserModel userData = UserModel.fromBasicInfo(
      id: Crypto.decrypt(map['id']),
      name: Crypto.decrypt(map['name']),
      profileImage: Crypto.decrypt(map['profileImage']),
    );

    userData.phoneNo = Crypto.decrypt(map['phoneNo']);
    userData.createdOn =
        DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal();

    userData.email = Crypto.decrypt(map['email']);
    userData.isGoogle = Crypto.decrypt(map['isGoogle']) == "true";
    userData.authToken = authToken;
    return userData;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: Crypto.decrypt(map['id']),
      name: Crypto.decrypt(map['name']),
      email: Crypto.decrypt(map['email'] ?? ""),
      profileImage: Crypto.decrypt(map['profileImage'] ?? ""),
      createdOn: DateTime.parse(Crypto.decrypt(map['createdOn'])).toLocal(),
      authToken: Crypto.decrypt(map['authToken'] ?? ""),
      phoneNo: Crypto.decrypt(map['phoneNo'] ?? ""),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, profileImage: $profileImage, id: $id, createdOn: $createdOn, phoneNo: $phoneNo, isGoogle: $isGoogle)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profileImage == profileImage;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ email.hashCode ^ profileImage.hashCode;
  }
}
