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

  RoomEach(
      {required this.roomName,
      required this.members,
      required this.roomKey,
      required this.active,
      required this.total,
      required this.spend,
      required this.date,
      required this.roomLink});

  factory RoomEach.fromJson(Map<String, dynamic> json) {
    return RoomEach(
      roomName: crypto.decrypt(json['roomName']),
      members: int.parse(crypto.decrypt(json['members'])),
      roomKey: crypto.decrypt(json['roomKey']),
      active: json['active'],
      total: double.parse(crypto.decrypt(json['total'])),
      spend: double.parse(crypto.decrypt(json['spend'])),
      date: formatDateTime(crypto.decrypt(json['date'])),
      roomLink: crypto.decrypt(json['joinLink']),
    );
  }
}
