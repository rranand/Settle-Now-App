import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/repository_core.dart';
part 'room_close_request_state.dart';

class RoomCloseRequestCubit extends Cubit<RoomCloseRequestState> {
  final RoomRepository repo;
  RoomCloseRequestCubit(this.repo) : super(RoomCloseRequestInitial());

  void closeRoomRequest(String id) async {
    if (state is RoomCloseRequestSuccess &&
        (state as RoomCloseRequestSuccess).roomID == id) {
      return emit(
        RoomCloseRequestSuccess(
          roomID: id,
          retryCount: (state as RoomCloseRequestSuccess).retryCount + 1,
        ),
      );
    }
    emit(RoomCloseRequestLoading());
    try {
      await repo.closeRoomRequest(id);
      return emit(RoomCloseRequestSuccess(roomID: id, retryCount: 1));
    } catch (e) {
      return emit(RoomCloseRequestFailure(roomID: id, error: e.toString()));
    }
  }

  void reset() {
    return emit(RoomCloseRequestInitial());
  }
}
