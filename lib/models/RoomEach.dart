import 'package:settlenow/others/crypto.dart';
import '../functions/additionalFunction.dart';

class RoomEach {
  final String roomName;
  final int members;
  final String roomKey;
  final bool active;
  final double total;
  final double spend;
  final String date;
  final String roomLink;
  final bool done;
  final String roomID;

  RoomEach(
      {required this.roomName,
      required this.members,
      required this.roomKey,
      required this.active,
      required this.total,
      required this.spend,
      required this.date,
      required this.roomLink,
      required this.done,
      required this.roomID});

  factory RoomEach.fromJson(Map<String, dynamic> json) {
    return RoomEach(
        roomName: crypto.decrypt(json['roomName']),
        members: int.parse(crypto.decrypt(json['members'])),
        roomKey: crypto.decrypt(json['roomKey']),
        active: json['active'],
        done: json['done'],
        total: double.parse(crypto.decrypt(json['total'])),
        spend: double.parse(crypto.decrypt(json['spend'])),
        date: formatDateTime(crypto.decrypt(json['date'])),
        roomLink: crypto.decrypt(json['joinLink']),
        roomID: crypto.decrypt(json['roomID']));
  }
}

class QuickSplitEach {
  final double amount;
  final String roomKey;
  final String owner;
  final bool active;
  final String email;
  final String purpose;
  final String date;
  final bool isEdited;
  final String lastModDate;
  final String type;
  final String roomID;
  final List<dynamic> splitBetween;
  final bool isClosedAny;

  QuickSplitEach(
      {required this.amount,
      required this.owner,
      required this.roomKey,
      required this.active,
      required this.email,
      required this.purpose,
      required this.date,
      required this.isEdited,
      required this.type,
      required this.lastModDate,
      required this.roomID,
      required this.splitBetween,
      required this.isClosedAny});

  factory QuickSplitEach.fromJson(Map<String, dynamic> json) {
    return QuickSplitEach(
        amount: double.parse(crypto.decrypt(json['amount'])),
        owner: crypto.decrypt(json['owner']),
        roomKey: crypto.decrypt(json['roomKey']),
        email: crypto.decrypt(json['email']),
        active: json['active'],
        purpose: crypto.decrypt(json['purpose']),
        date: formatDateTime(crypto.decrypt(json['date'])),
        isEdited: json['isEdited'],
        type: crypto.decrypt(json['type']),
        lastModDate: crypto.decrypt(json['lastModDate']) == ''
            ? ''
            : formatDateTime(crypto.decrypt(json['lastModDate'])),
        roomID: crypto.decrypt(json['roomID']),
        splitBetween: json['splitBetween'],
        isClosedAny: json['isClosedAny']);
  }
}
