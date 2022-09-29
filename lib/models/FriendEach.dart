import 'package:settlenow/others/crypto.dart';

class FriendEach {
  String name;
  String email;
  String status;
  String pic;
  bool isGoogle;

  FriendEach({required this.name,required this.email,required this.status, required this.pic, required this.isGoogle});

  factory FriendEach.fromJson(Map<String, dynamic> json) {
    return FriendEach(
      name: crypto.decrypt(json['name']),
      email: crypto.decrypt(json['email']),
      status: crypto.decrypt(json['status']),
      pic: crypto.decrypt(json['pic']),
      isGoogle: json['isGoogle'],
    );
  }
}