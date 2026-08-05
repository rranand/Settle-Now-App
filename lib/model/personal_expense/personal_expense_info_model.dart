import 'package:settlenow/constant/constant_core.dart';

class PersonalExpenseInfoModel {
  bool hasData = true;
  String id = "";
  double amount = 0;
  String monthName = "";
  String year = "";
  int transactionCount = 0;

  PersonalExpenseInfoModel({
    required this.id,
    required this.amount,
    required this.monthName,
    required this.year,
    required this.transactionCount,
  });

  PersonalExpenseInfoModel.empty({this.hasData = false});

  PersonalExpenseInfoModel copyWith({
    String? id,
    double? amount,
    String? monthName,
    String? year,
    int? transactionCount,
  }) {
    return PersonalExpenseInfoModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      monthName: monthName ?? this.monthName,
      year: year ?? this.year,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'monthName': monthName,
      'year': year,
      'transaction_count': transactionCount,
    };
  }

  factory PersonalExpenseInfoModel.fromMap(Map<String, dynamic> map) {
    String date = map['date'] ?? "";

    String year = date.substring(date.length - 4);
    int monthIndex = int.parse(date.substring(0, date.length - 4));

    return PersonalExpenseInfoModel(
      id: map['id'],
      amount: double.parse(map['amount'].toString()),
      monthName: CalenderConstant.monthName[monthIndex],
      year: year,
      transactionCount: map['transaction_count'],
    );
  }

  @override
  String toString() {
    return 'PersonalExpenseInfoModel(monthName: $monthName, year: $year, amount: $amount)';
  }

  @override
  bool operator ==(covariant PersonalExpenseInfoModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.amount == amount &&
        other.monthName == monthName &&
        other.year == year &&
        other.transactionCount == transactionCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        monthName.hashCode ^
        year.hashCode ^
        transactionCount.hashCode;
  }
}
