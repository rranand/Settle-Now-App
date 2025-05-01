import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';

part 'lenden_room_event.dart';
part 'lenden_room_state.dart';

class LendenRoomBloc extends Bloc<LendenRoomEvent, LendenRoomState> {
  final LendenRoomRepository repo;

  LendenRoomBloc(this.repo) : super(LendenRoomInitial()) {
    on<LendenRoomFetch>(_lendenRoomFetch);
  }

  void _lendenRoomFetch(
    LendenRoomFetch event,
    Emitter<LendenRoomState> emit,
  ) async {
    emit(LendenRoomLoading());
    try {
      List<LendenRoomModel> data = await repo.fetchData(
        "niriif@kff.ed",
        event.id,
      );
      return emit(LendenRoomFetchSuccess(event.id, data));
    } catch (e) {
      return emit(LendenRoomFailure(e.toString()));
    }
  }
}
