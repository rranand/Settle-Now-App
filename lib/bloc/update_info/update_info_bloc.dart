import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/data/repository/update_info_repository.dart';
import 'package:settlenow_v2/model/update_info_model.dart';

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
    if (state is UpdateInfoSuccess || state is UpdateInfoLoading) {
      return;
    }
    emit(UpdateInfoLoading());
    try {
      UpdateInfoModel updateInfo = await repo.fetchUpdateInfo();
      return emit(UpdateInfoSuccess(data: updateInfo));
    } catch (e) {
      return emit(UpdateInfoFailure(e.toString()));
    }
  }
}
