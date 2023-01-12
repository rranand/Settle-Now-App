import 'package:settlenow/others/crypto.dart';

class ContactEach {
  String name;
  String email;
  String pic;
  String date;
  String subject;
  String message;

  ContactEach(
      {required this.name,
      required this.email,
      required this.pic,
      required this.date,
      required this.subject,
      required this.message});

  factory ContactEach.fromJson(Map<String, dynamic> json) {
    return ContactEach(
        name: crypto.decrypt(json['name']),
        email: crypto.decrypt(json['email']),
        pic: crypto.decrypt(json['pic']),
        date: crypto.decrypt(json['date']),
        subject: crypto.decrypt(json['subject']),
        message: crypto.decrypt(json['message']));
  }
}
