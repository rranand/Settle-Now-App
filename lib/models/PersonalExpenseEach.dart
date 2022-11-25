import 'package:settlenow/others/crypto.dart';

class PersonalExpenseEach {
  String Date;
  double Total;
  String Month;
  String Year;

  PersonalExpenseEach(
      {required this.Date,
      required this.Total,
      required this.Month,
      required this.Year});

  factory PersonalExpenseEach.fromJson(Map<String, dynamic> json) {
    return PersonalExpenseEach(
      Date: crypto.decrypt(json['Date']),
      Total: double.parse(crypto.decrypt(json['Total'])),
      Month: crypto.decrypt(json['Month']),
      Year: crypto.decrypt(json['Year']),
    );
  }
}
