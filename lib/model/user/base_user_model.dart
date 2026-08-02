class BaseUserModel {
  bool hasData = true;
  String id;
  String name;
  String profilePic;

  BaseUserModel({
    required this.id,
    required this.name,
    required this.profilePic,
  });

  BaseUserModel.empty({this.hasData = false})
    : id = "",
      name = "",
      profilePic = "";

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name, 'profile_pic': profilePic};
  }

  BaseUserModel copyWith({String? id, String? name, String? profilePic}) {
    return BaseUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  factory BaseUserModel.fromMap(Map<String, dynamic> map) {
    return BaseUserModel(
      id: map['id'],
      name: map['name'],
      profilePic: map['profile_pic'] ?? "",
    );
  }

  @override
  String toString() {
    return 'BaseUserModel(id: $id, name: $name, profilePic: $profilePic)';
  }

  @override
  bool operator ==(covariant BaseUserModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.name == name &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return hasData.hashCode ^ id.hashCode ^ name.hashCode ^ profilePic.hashCode;
  }
}
