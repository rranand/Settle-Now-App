import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';

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

  Future<PersonalExpenseTransactionModel> add(
    PersonalExpenseTransactionModel data,
  ) async {
    try {
      return _dataProvider.add(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(PersonalExpenseTransactionModel data) async {
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
