import 'package:settlenow/model/model_core.dart';

class FriendUserModel extends BaseUserModel {
  String phoneNo;

  FriendUserModel({
    required super.id,
    required super.name,
    required super.profilePic,
    required this.phoneNo,
  });

  FriendUserModel.empty() : phoneNo = "", super.empty();

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{...super.toMap(), 'phone_no': phoneNo};
  }

  @override
  FriendUserModel copyWith({
    String? id,
    String? name,
    String? profilePic,
    String? phoneNo,
  }) {
    return FriendUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      phoneNo: phoneNo ?? this.phoneNo,
    );
  }

  factory FriendUserModel.withoutPhone(
    String id,
    String name,
    String profilePic,
  ) {
    return FriendUserModel(
      id: id,
      name: name,
      profilePic: profilePic,
      phoneNo: "",
    );
  }

  factory FriendUserModel.fromMap(Map<String, dynamic> map) {
    final data = BaseUserModel.fromMap(map);

    return FriendUserModel(
      id: data.id,
      name: data.name,
      profilePic: data.profilePic,
      phoneNo: map['phone_no'] ?? "",
    );
  }

  @override
  String toString() {
    return 'FriendUserModel(id: $id, name: $name, profilePic: $profilePic, phoneNo: $phoneNo)';
  }

  @override
  bool operator ==(covariant FriendUserModel other) {
    if (identical(this, other)) return true;

    return other.hasData == hasData &&
        other.id == id &&
        other.name == name &&
        other.profilePic == profilePic &&
        other.phoneNo == phoneNo;
  }

  @override
  int get hashCode {
    return super.hashCode ^ phoneNo.hashCode;
  }
}
