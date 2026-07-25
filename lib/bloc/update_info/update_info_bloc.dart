import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/firebase/firebase_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'update_info_event.dart';
part 'update_info_state.dart';

class UpdateInfoBloc extends Bloc<UpdateInfoEvent, UpdateInfoState> {
  final UpdateInfoRepository repo;
  UpdateInfoBloc(this.repo) : super(UpdateInfoInitial()) {
    on<UpdateInfoFetchRequested>(_updateInfoFetchRequested);
  }

  void _updateInfoFetchRequested(
    UpdateInfoFetchRequested event,
    Emitter<UpdateInfoState> emit,
  ) async {
    if (state is UpdateInfoLoading || (kIsWeb && state is UpdateInfoSuccess)) {
      return;
    }
    emit(UpdateInfoLoading());
    try {
      final String version = await getAppVersion();
      UpdateInfoModel updateInfo = UpdateInfoModel.empty();

      if (kIsWeb) {
        updateInfo = await repo.fetchUpdateInfo();
      } else {
        final versionInfoFromRemote = event.remoteConfigService.getJSON(
          RemoteConfigConstant.versionInfoConstant,
        );
        updateInfo = UpdateInfoModel.fromMap(versionInfoFromRemote, version);
      }

      return emit(UpdateInfoSuccess(data: updateInfo));
    } catch (e) {
      return emit(UpdateInfoFailure(e.toString()));
    }
  }
}
