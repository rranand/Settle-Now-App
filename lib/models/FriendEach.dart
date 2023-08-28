import 'package:settlenow/others/crypto.dart';

class FriendEach {
  String name;
  String email;
  String status;
  String pic;
  String phoneNo;
  bool isGoogle;
  bool fromContact;

  FriendEach(
      {required this.name,
      required this.email,
      required this.status,
      required this.pic,
      required this.isGoogle,
      required this.phoneNo,
      required this.fromContact});

  factory FriendEach.fromJson(Map<String, dynamic> json) {
    return FriendEach(
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

  factory FriendEach.fromLocal(
      Map<dynamic, dynamic> contactEach, Function fixPhoneNo) {
    return FriendEach(
      name: contactEach.containsKey('displayName')
          ? contactEach['displayName']
          : '',
      fromContact: true,
      email: contactEach.containsKey('emails')
          ? (contactEach['emails'].isNotEmpty
              ? contactEach['emails'][0]['value']
              : '')
          : '',
      status: '',
      pic: '',
      isGoogle: false,
      phoneNo: fixPhoneNo(contactEach.containsKey('phones')
          ? (contactEach['phones'].isNotEmpty
              ? contactEach['phones'][0]['value']
              : '')
          : ''),
    );
  }
}

class TransactionEach {
  String amount;
  String date;
  String transactionID;
  String receiver;
  String type;
  String bank;
  String mode;

  TransactionEach({
    required this.amount,
    required this.date,
    required this.transactionID,
    required this.receiver,
    required this.type,
    required this.bank,
    required this.mode,
  });
}
