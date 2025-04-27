import 'package:settlenow_v2/data/data_provider/lenden_data_provider.dart';
import 'package:settlenow_v2/model/lenden_model.dart';

class LendenRepository {
  final LendenDataProvider lendenDataProvider;

  LendenRepository(this.lendenDataProvider);

  Future<List<LendenModel>> fetchData(String email) async {
    try {
      return lendenDataProvider.fetchData(email);
    } catch (e) {
      rethrow;
    }
  }
}
