import 'package:settlenow_v2/data/data_provider/quicksplit_data_provider.dart';
import 'package:settlenow_v2/model/quicksplit_model.dart';

class QuicksplitRepository {
  final QuicksplitDataProvider quicksplitDataProvider;

  QuicksplitRepository(this.quicksplitDataProvider);

  Future<List<QuickSplitModel>> fetchData(String email) async {
    try {
      return quicksplitDataProvider.fetchData(email);
    } catch (e) {
      rethrow;
    }
  }
}
