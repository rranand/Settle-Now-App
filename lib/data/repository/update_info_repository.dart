import 'package:settlenow/data/data_provider/data_provider_core.dart';
import 'package:settlenow/model/model_core.dart';

class UpdateInfoRepository {
  final UpdateInfoDataProvider _dataProvider;

  UpdateInfoRepository(this._dataProvider);

  Future<UpdateInfoModel> fetchUpdateInfo() async {
    try {
      UpdateInfoModel updateInfo = await _dataProvider.fetchUpdateInfo();
      return updateInfo;
    } catch (e) {
      rethrow;
    }
  }
}
