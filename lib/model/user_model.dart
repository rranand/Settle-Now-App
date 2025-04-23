import 'dart:convert';

class UserModel {
  String id;
  String name;
  String email;
  String profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  factory UserModel.fromBasicInfoMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: "",
      profileImage: "",
    );
  }

  UserModel.fromBasicInfo({
    required this.id,
    required this.name,
    required this.profileImage,
    this.email = "",
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      profileImage: map['profileImage'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email)';
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
