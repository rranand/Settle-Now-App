import 'dart:convert';

import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class UpdateInfoDataProvider {
  Future<UpdateInfoModel> fetchUpdateInfo() async {
    try {
      String version = await getAppVersion();
      final response = await createAPICall('server', 'get', {});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        UpdateInfoModel updateData = UpdateInfoModel.fromAPI(
          data['data'],
          version,
        );
        return updateData;
      } else {
        throw data['message'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
