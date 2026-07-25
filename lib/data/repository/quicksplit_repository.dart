import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';

class QuicksplitRepository {
  final QuicksplitDataProvider _dataProvider;

  QuicksplitRepository(this._dataProvider);

  Future<List<TransactionModel>> fetchData() async {
    try {
      List<TransactionModel> data = await _dataProvider.fetchData();
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> create(NewTransactionModel data) async {
    try {
      return _dataProvider.create(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> update(NewTransactionModel data) async {
    try {
      return _dataProvider.update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID) async {
    try {
      return _dataProvider.delete(expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToPersonalExpense(String expenseID) async {
    try {
      return _dataProvider.addToPersonalExpense(expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> settleExpense(String expenseID) async {
    try {
      return _dataProvider.settleExpense(expenseID);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> optout(String expenseID) async {
    try {
      return _dataProvider.optout(expenseID);
    } catch (e) {
      rethrow;
    }
  }
}
