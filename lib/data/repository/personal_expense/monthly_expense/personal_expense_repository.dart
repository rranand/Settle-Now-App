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
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> add(
    String authToken,
    NewTransactionModel data,
  ) async {
    try {
      return _dataProvider.add(authToken, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<PersonalExpenseTransactionModel> update(
    String authToken,
    NewTransactionModel data,
  ) async {
    try {
      return _dataProvider.update(authToken, data);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(
    String authToken,
    String expenseID,
    String transactionType,
  ) async {
    try {
      return _dataProvider.delete(authToken, expenseID, transactionType);
    } catch (e) {
      rethrow;
    }
  }
}
