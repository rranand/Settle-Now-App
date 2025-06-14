import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/data/data_provider/personal_expense/monthly_expense/personal_expense_data_provider.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';

class PersonalMonthlyExpenseRepository {
  final PersonalMonthlyExpenseDataProvider _dataProvider;

  PersonalMonthlyExpenseRepository(this._dataProvider);

  Future<List<PersonalExpenseTransactionModel>> fetchData(
    String authToken,
    String year,
    String month,
  ) async {
    try {
      List<PersonalExpenseTransactionModel> data = await _dataProvider
          .fetchData(authToken, year, month);

      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> add(NewTransactionModel data) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return _dataProvider.add(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> update(
    NewTransactionModel data,
  ) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return _dataProvider.update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID) async {
    try {
      await Future.delayed(Duration(seconds: 2), () {});
      return _dataProvider.delete(expenseID);
    } catch (e) {
      rethrow;
    }
  }
}
