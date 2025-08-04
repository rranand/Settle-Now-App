import 'package:settlenow_v2/data/data_provider/quicksplit_data_provider.dart';
import 'package:settlenow_v2/model/new_transaction_model.dart';
import 'package:settlenow_v2/model/transaction_model.dart';

class QuicksplitRepository {
  final QuicksplitDataProvider _dataProvider;

  QuicksplitRepository(this._dataProvider);

  Future<List<TransactionModel>> fetchData(String authToken) async {
    try {
      List<TransactionModel> data = await _dataProvider.fetchData(authToken);
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> create(
    NewTransactionModel data,
    String authToken,
  ) async {
    try {
      return _dataProvider.create(data, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<TransactionModel> update(
    NewTransactionModel data,
    String authToken,
  ) async {
    try {
      return _dataProvider.update(data, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> delete(String expenseID, String authToken) async {
    try {
      return _dataProvider.delete(expenseID, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addToPersonalExpense(String expenseID, String authToken) async {
    try {
      return _dataProvider.addToPersonalExpense(expenseID, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> settleExpense(String expenseID, String authToken) async {
    try {
      return _dataProvider.settleExpense(expenseID, authToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> optout(String expenseID, String authToken) async {
    try {
      return _dataProvider.optout(expenseID, authToken);
    } catch (e) {
      rethrow;
    }
  }
}
