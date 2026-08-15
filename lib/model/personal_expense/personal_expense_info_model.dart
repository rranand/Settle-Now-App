import 'package:settlenow/constant/constant_core.dart';

class PersonalExpenseInfoModel {
  bool hasData = true;
  double amount = 0;
  String monthName = "";
  String year = "";
  DateTime createdOn = DateTime.now();
  int transactionCount = 0;

  PersonalExpenseInfoModel({
    required this.amount,
    required this.monthName,
    required this.year,
    required this.transactionCount,
    required this.createdOn,
  });

  String get id => (year + monthName).toLowerCase();

  PersonalExpenseInfoModel.empty({this.hasData = false});

  PersonalExpenseInfoModel copyWith({
    double? amount,
    String? monthName,
    String? year,
    int? transactionCount,
    DateTime? createdOn,
  }) {
    return PersonalExpenseInfoModel(
      amount: amount ?? this.amount,
      monthName: monthName ?? this.monthName,
      year: year ?? this.year,
      transactionCount: transactionCount ?? this.transactionCount,
      createdOn: createdOn ?? this.createdOn,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'amount': amount,
      'month_name': monthName,
      'year': year,
      'transaction_count': transactionCount,
      'created_on': createdOn,
    };
  }

  factory PersonalExpenseInfoModel.fromMap(Map<String, dynamic> map) {
    String date = map['date'] ?? "";

    String year = date.substring(date.length - 4);
    int monthIndex = int.parse(date.substring(0, date.length - 4));

    return PersonalExpenseInfoModel(
      amount: double.parse(map['amount'].toString()),
      monthName: CalenderConstant.monthName[monthIndex],
      year: year,
      transactionCount: map['transaction_count'],
      createdOn: DateTime.parse(map['created_on']).toLocal(),
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
