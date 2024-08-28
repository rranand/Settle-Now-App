import 'package:settlenow/others/crypto.dart';

import '../functions/additionalFunction.dart';

class LoggedInEach {
  String country;
  String city;
  String device;
  String deviceType;
  String id;
  String lastUsed;
  bool currentSession;

  LoggedInEach({
    required this.country,
    required this.city,
    required this.device,
    required this.deviceType,
    required this.id,
    required this.lastUsed,
    required this.currentSession,
  });

  factory LoggedInEach.fromJson(Map<String, dynamic> json) {
    return LoggedInEach(
        country: crypto.decrypt(json['country']),
        city: crypto.decrypt(json['city']),
        device: crypto.decrypt(json['device']),
        deviceType: (crypto.decrypt(json['deviceType'])),
        id: (crypto.decrypt(json['id'])),
        lastUsed: formatDateTime(crypto.decrypt(json['lastUsed'])),
        currentSession: (json['currentSession'] == 'true'));
  }
}
