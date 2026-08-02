import 'package:settlenow/model/model_core.dart';

class UserModel extends FriendUserModel {
  String email;
  DateTime createdOn;
  bool isGoogle;

  UserModel({
    required super.id,
    required super.name,
    required this.email,
    required super.profilePic,
    required this.createdOn,
    required super.phoneNo,
    required this.isGoogle,
  });

  UserModel.empty()
    : email = "",
      createdOn = DateTime.now(),
      isGoogle = false,
      super.empty();

  @override
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePic,
    DateTime? createdOn,
    String? phoneNo,
    bool? isGoogle,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      createdOn: createdOn ?? this.createdOn,
      phoneNo: phoneNo ?? this.phoneNo,
      isGoogle: isGoogle ?? this.isGoogle,
    );
  }

  Map<String, dynamic> toUpdateJSON() {
    return <String, dynamic>{'name': name};
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      ...super.toMap(),
      'email': email,
      'created_on': createdOn,
      'is_google': isGoogle,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final data = FriendUserModel.fromMap(map);

    return UserModel(
      id: data.id,
      name: data.name,
      profilePic: data.profilePic,
      phoneNo: data.phoneNo,
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      email: map['email'],
      isGoogle: map['is_google'],
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, profilePic: $profilePic, createdOn: $createdOn, phoneNo: $phoneNo, isGoogle: $isGoogle)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profilePic == profilePic &&
        other.createdOn == createdOn &&
        other.phoneNo == phoneNo &&
        other.isGoogle == isGoogle;
  }

  @override
  int get hashCode {
    return super.hashCode ^
        email.hashCode ^
        isGoogle.hashCode ^
        createdOn.hashCode;
  }
}
