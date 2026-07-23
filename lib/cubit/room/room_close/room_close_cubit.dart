import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow/data/repository/room/each_room/room_repository.dart';
part 'room_close_state.dart';

class RoomCloseCubit extends Cubit<RoomCloseState> {
  final RoomRepository repo;
  final RoomUserCubit _roomUserCubit;
  RoomCloseCubit(this.repo, this._roomUserCubit) : super(RoomCloseInitial());

  void closeRoom(String id, String uid, ) async {
    if (state is RoomCloseSuccess && (state as RoomCloseSuccess).roomID == id) {
      return emit(
        RoomCloseSuccess(id, (state as RoomCloseSuccess).retryCount + 1),
      );
    }
    emit(RoomCloseLoading());
    try {
      await repo.closeRoom(id, );
      _roomUserCubit.updateCloseStatus(id, uid, false);
      return emit(RoomCloseSuccess(id, 1));
    } catch (e) {
      return emit(RoomCloseFailure(id, e.toString()));
    }
  }

  void reset() {
    return emit(RoomCloseInitial());
  }
}
