import 'dart:convert';

import 'package:settlenow/model/update_info_model.dart';
import 'package:settlenow/util/handler/crypto.dart';
import 'package:settlenow/util/handler/network_call.dart';
import 'package:settlenow/util/handler/platform_service.dart';

class UpdateInfoDataProvider {
  Future<UpdateInfoModel> fetchUpdateInfo() async {
    try {
      String version = await getAppVersion();
      final response = await createAPICall('server', 'get', "", {});

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        UpdateInfoModel updateData = UpdateInfoModel.fromAPI(
          data['data'],
          version,
        );
        return updateData;
      } else {
        throw Crypto.decrypt(data['message']);
      }
    } catch (e) {
      rethrow;
    }
  }
}
