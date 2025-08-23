import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/constant/remote_config_constant.dart';
import 'package:settlenow_v2/firebase/firebase_remote.dart';
import 'package:settlenow_v2/model/update_info_model.dart';
import 'package:settlenow_v2/util/handler/platform_service.dart';

part 'update_info_event.dart';
part 'update_info_state.dart';

class UpdateInfoBloc extends Bloc<UpdateInfoEvent, UpdateInfoState> {
  UpdateInfoBloc() : super(UpdateInfoInitial()) {
    on<UpdateInfoFetchRequested>(_updateInfoFetchRequested);
  }

  void _updateInfoFetchRequested(
    UpdateInfoFetchRequested event,
    Emitter<UpdateInfoState> emit,
  ) async {
    if (state is UpdateInfoSuccess || state is UpdateInfoLoading) {
      return;
    }
    emit(UpdateInfoLoading());
    try {
      final String version = await getAppVersion();
      final versionInfoFromRemote = event.remoteConfigService.getJSON(
        RemoteConfigConstant.versionInfoConstant,
      );
      final UpdateInfoModel updateInfo = UpdateInfoModel.fromMap(
        versionInfoFromRemote, version
      );
      return emit(UpdateInfoSuccess(data: updateInfo));
    } catch (e) {
      return emit(UpdateInfoFailure(e.toString()));
    }
  }
}
