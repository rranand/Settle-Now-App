import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:settlenow_v2/bloc/update_info/update_info_bloc.dart';

class InAppUpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        bool isImportantUpdate = false;
        final updateInfoState = context.read<UpdateInfoBloc>().state;
        if (updateInfoState is UpdateInfoSuccess &&
            updateInfoState.data.important &&
            updateInfoState.data.isUpdateRequired()) {
          isImportantUpdate = true;
        }
        final updateInfo = await InAppUpdate.checkForUpdate();

        if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          if (isImportantUpdate && updateInfo.immediateUpdateAllowed) {
            await InAppUpdate.performImmediateUpdate();
          } else if (updateInfo.flexibleUpdateAllowed) {
            await InAppUpdate.startFlexibleUpdate();
            await InAppUpdate.completeFlexibleUpdate();
          }
        }
      }
    } catch (_) {}
  }
}
