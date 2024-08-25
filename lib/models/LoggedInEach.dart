import 'package:settlenow/others/crypto.dart';

import '../functions/additionalFunction.dart';

class LoggedInEach {
  String country;
  String city;
  String device;
  String os;
  String id;
  String lastUsed;
  bool currentSession;

  LoggedInEach({
    required this.country,
    required this.city,
    required this.device,
    required this.os,
    required this.id,
    required this.lastUsed,
    required this.currentSession,
  });

  factory LoggedInEach.fromJson(Map<String, dynamic> json) {
    print(json['currentSession']);
    return LoggedInEach(
        country: crypto.decrypt(json['country']),
        city: crypto.decrypt(json['city']),
        device: crypto.decrypt(json['device']),
        os: (crypto.decrypt(json['os'])),
        id: (crypto.decrypt(json['id'])),
        lastUsed: formatDateTime(crypto.decrypt(json['lastUsed'])),
        currentSession: (json['currentSession'] == 'true'));
  }
}
