import 'package:settlenow/others/crypto.dart';

class FriendEach {
  String name;
  String email;
  String status;
  String pic;
  bool isGoogle;

  FriendEach(
      {required this.name,
      required this.email,
      required this.status,
      required this.pic,
      required this.isGoogle});

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
