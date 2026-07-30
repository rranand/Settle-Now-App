import 'dart:convert';

class UserModel {
  bool hasData = true;
  String id = "";
  String name = "";
  String email = "";
  String profileImage = "";
  DateTime createdOn = DateTime.now();
  String phoneNo = "";
  bool isGoogle = false;

  UserModel({
    this.hasData = true,
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    required this.createdOn,
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
    String? phoneNo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      createdOn: createdOn ?? this.createdOn,
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
      phoneNo: data.phoneNo,
    );
  }

  Map<String, dynamic> updateProfileJSON() {
    return <String, dynamic>{'name': name};
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'profile_pic': profileImage,
    };
  }

  factory UserModel.fromBasicInfoMap(Map<String, dynamic> map) {
    return UserModel.fromBasicInfo(
      id: map['id'],
      name: map['name'] ?? "",
      profileImage: map['profile_pic'] ?? "",
    );
  }

  factory UserModel.forOwnerInfo(Map<String, dynamic> map) {
    UserModel userData = UserModel.fromBasicInfo(
      id: map['id'],
      name: map['name'],
      profileImage: map['profile_pic'],
    );

    userData.phoneNo = map['phone_no'] ?? "";
    userData.createdOn = DateTime.parse(map['created_on']).toLocal();

    userData.email = map['email'];
    userData.isGoogle = map['is_google'];
    return userData;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'] ?? "",
      profileImage: map['profile_pic'] ?? "",
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      phoneNo: map['phone_no'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, profileImage: $profileImage, createdOn: $createdOn, phoneNo: $phoneNo, isGoogle: $isGoogle)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profileImage == profileImage &&
        other.createdOn == createdOn &&
        other.phoneNo == phoneNo &&
        other.isGoogle == isGoogle;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        profileImage.hashCode ^
        createdOn.hashCode ^
        phoneNo.hashCode ^
        isGoogle.hashCode;
  }
}
