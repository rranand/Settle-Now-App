import 'package:settlenow/core.dart';
import 'package:settlenow/data/data_provider/personal_expense/monthly_expense/personal_expense_data_provider.dart';
import 'package:settlenow/model/new_transaction_model.dart';

class PersonalMonthlyExpenseRepository {
  final PersonalMonthlyExpenseDataProvider _dataProvider;

  PersonalMonthlyExpenseRepository(this._dataProvider);

  Future<List<PersonalExpenseTransactionModel>> fetchData(
    String year,
    String month,
  ) async {
    try {
      List<PersonalExpenseTransactionModel> data = await _dataProvider
          .fetchData(year, month);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> add(NewTransactionModel data) async {
    try {
      return _dataProvider.add(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> update(
    NewTransactionModel data,
  ) async {
    try {
      return _dataProvider.update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID, String transactionType) async {
    try {
      return _dataProvider.delete(expenseID, transactionType);
    } catch (e) {
      rethrow;
    }
  }
}
