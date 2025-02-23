import 'package:settlenow/others/crypto.dart';
import '../contents.dart' as global;

class FriendEach {
  String requestID;
  String name;
  String email;
  String status;
  String pic;
  String phoneNo;
  bool isGoogle;
  bool fromContact;

  FriendEach(
      {required this.requestID,
      required this.name,
      required this.email,
      required this.status,
      required this.pic,
      required this.isGoogle,
      required this.phoneNo,
      required this.fromContact});

  factory FriendEach.fromJson(Map<String, dynamic> json) {
    return FriendEach(
      requestID: json.containsKey('requestID')
          ? crypto.decrypt(json['requestID'])
          : '',
      name: json.containsKey('name') ? crypto.decrypt(json['name']) : '',
      fromContact: false,
      email: json.containsKey('email') ? crypto.decrypt(json['email']) : '',
      status: json.containsKey('status') ? crypto.decrypt(json['status']) : '',
      pic: json.containsKey('pic') ? crypto.decrypt(json['pic']) : '',
      isGoogle: json['isGoogle'],
      phoneNo:
          json.containsKey('phoneNo') ? crypto.decrypt(json['phoneNo']) : '',
    );
  }

  factory FriendEach.fromLocal(Map<dynamic, dynamic> contactEach) {
    return FriendEach(
      requestID: "",
      name: contactEach.containsKey('name') ? contactEach['name'] : '',
      fromContact: true,
      email: contactEach.containsKey('email') ? contactEach['email'] : '',
      status: 'NJ',
      pic: contactEach.containsKey('pic')
          ? contactEach['pic']
          : global.unknown_avatar_id,
      isGoogle: contactEach.containsKey('isGoogle')
          ? (contactEach['isGoogle'].toString().toLowerCase() == "false"
              ? false
              : true)
          : false,
      phoneNo: contactEach.containsKey('phoneNo') ? contactEach['phoneNo'] : '',
    );
  }

  factory FriendEach.forLocal(Map<dynamic, dynamic> contactEach) {
    return FriendEach(
      requestID: "",
      name: contactEach.containsKey('name')
          ? crypto.decrypt(contactEach['name'])
          : '',
      fromContact: true,
      email: contactEach.containsKey('email')
          ? crypto.decrypt(contactEach['email'])
          : '',
      status: 'NJ',
      pic: contactEach.containsKey('pic')
          ? crypto.decrypt(contactEach['pic'])
          : global.unknown_avatar_id,
      isGoogle:
          contactEach.containsKey('isGoogle') ? contactEach['isGoogle'] : false,
      phoneNo: contactEach.containsKey('phoneNo')
          ? crypto.decrypt(contactEach['phoneNo'])
          : '',
    );
  }
}
