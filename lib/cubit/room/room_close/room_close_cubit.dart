import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
part 'room_close_state.dart';

class RoomCloseCubit extends Cubit<RoomCloseState> {
  final RoomRepository repo;
  final RoomUserCubit _roomUserCubit;
  RoomCloseCubit(this.repo, this._roomUserCubit) : super(RoomCloseInitial());

  void closeRoom(String id, String uid) async {
    if (state is RoomCloseSuccess && (state as RoomCloseSuccess).roomID == id) {
      return emit(
        RoomCloseSuccess(
          roomID: id,
          retryCount: (state as RoomCloseSuccess).retryCount + 1,
        ),
      );
    }
    emit(RoomCloseLoading());
    try {
      await repo.closeRoom(id);
      _roomUserCubit.updateCloseStatus(id, uid, false);
      return emit(RoomCloseSuccess(roomID: id, retryCount: 1));
    } catch (e) {
      return emit(RoomCloseFailure(roomID: id, error: e.toString()));
    }
  }

  void reset() {
    return emit(RoomCloseInitial());
  }
}
