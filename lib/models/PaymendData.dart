import 'package:settlenow/functions/additionalFunction.dart';
import 'package:settlenow/others/crypto.dart';

class PaymentDataEach {
  String objID;
  double amount;
  String sender;
  String receiver;
  String senderEmail;
  String receiverEmail;
  String lastModDate;
  String creationDate;
  bool isEdited;

  PaymentDataEach(
      {required this.objID,
      required this.amount,
      required this.sender,
      required this.receiver,
      required this.senderEmail,
      required this.receiverEmail,
      required this.lastModDate,
      required this.creationDate,
      required this.isEdited});

  factory PaymentDataEach.fromJson(Map<String, dynamic> json) {
    return PaymentDataEach(
      objID: json.containsKey('objID') ? crypto.decrypt(json['objID']) : '',
      amount: json.containsKey('Amount')
          ? double.parse(crypto.decrypt(json['Amount']))
          : 0,
      sender: json.containsKey('sender') ? crypto.decrypt(json['sender']) : '',
      receiver:
          json.containsKey('receiver') ? crypto.decrypt(json['receiver']) : '',
      senderEmail:
          json.containsKey('sEmail') ? crypto.decrypt(json['sEmail']) : '',
      receiverEmail:
          json.containsKey('rEmail') ? crypto.decrypt(json['rEmail']) : '',
      lastModDate: json.containsKey('lastModDate')
          ? formatDateTime(crypto.decrypt(json['lastModDate']))
          : '',
      creationDate: json.containsKey('Date')
          ? formatDateTime(crypto.decrypt(json['Date']))
          : '',
      isEdited: json.containsKey('isEdited') ? json['isEdited'] : false,
    );
  }
}
