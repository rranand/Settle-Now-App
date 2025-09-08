import 'package:settlenow_v2/data/data_provider/update_info_data_provider.dart';
import 'package:settlenow_v2/model/update_info_model.dart';

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
