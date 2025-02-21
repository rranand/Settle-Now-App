import 'package:settlenow/others/crypto.dart';
import '../functions/additionalFunction.dart';

class RoomEach {
  String roomName;
  int members;
  final String roomKey;
  bool active;
  double total;
  double spend;
  final String date;
  final String roomLink;
  bool done;
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

class RoomMemberEach {
  String name;
  double expense;
  double totalSplitExpense;
  double current;
  double yourExpense;
  bool own;
  String email;
  String pic;
  bool done;

  RoomMemberEach(
      {required this.name,
      required this.expense,
      required this.totalSplitExpense,
      required this.current,
      required this.yourExpense,
      required this.done,
      required this.own,
      required this.email,
      required this.pic});

  factory RoomMemberEach.fromJson(Map<String, dynamic> json) {
    return RoomMemberEach(
        name: crypto.decrypt(json['Name']),
        expense: double.parse(crypto.decrypt(json['Expense'])),
        totalSplitExpense:
            double.parse(crypto.decrypt(json['TotalSplitExpense'])),
        current: double.parse(crypto.decrypt(json['current'])),
        done: json['done'],
        yourExpense: double.parse(crypto.decrypt(json['yourExpense'])),
        own: json['own'],
        email: crypto.decrypt(json['email']),
        pic: crypto.decrypt(json['pic']));
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
  final String subType;
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
      required this.subType,
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
        subType: crypto.decrypt(json['subType']),
        lastModDate: crypto.decrypt(json['lastModDate']) == ''
            ? ''
            : formatDateTime(crypto.decrypt(json['lastModDate'])),
        roomID: crypto.decrypt(json['roomID']),
        splitBetween: json['splitBetween'],
        isClosedAny: json['isClosedAny']);
  }
}
