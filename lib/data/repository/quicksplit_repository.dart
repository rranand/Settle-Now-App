import 'package:settlenow_v2/data/data_provider/quicksplit_data_provider.dart';
import 'package:settlenow_v2/model/transaction_model.dart';

class QuicksplitRepository {
  final QuicksplitDataProvider _dataProvider;

  QuicksplitRepository(this._dataProvider);

  Future<List<TransactionModel>> fetchData(String email) async {
    try {
      return _dataProvider.fetchData(email);
    } catch (e) {
      rethrow;
    }
  }
}
