import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
part 'room_close_request_state.dart';

class RoomCloseRequestCubit extends Cubit<RoomCloseRequestState> {
  final RoomRepository repo;
  RoomCloseRequestCubit(this.repo) : super(RoomCloseRequestInitial());

  void closeRoomRequest(String id, String authToken) async {
    if (state is RoomCloseRequestSuccess &&
        (state as RoomCloseRequestSuccess).roomID == id) {
      return emit(
        RoomCloseRequestSuccess(
          id,
          (state as RoomCloseRequestSuccess).retryCount + 1,
        ),
      );
    }
    emit(RoomCloseRequestLoading());
    try {
      await repo.closeRoomRequest(id, authToken);
      return emit(RoomCloseRequestSuccess(id, 1));
    } catch (e) {
      return emit(RoomCloseRequestFailure(id, e.toString()));
    }
  }

  void reset() {
    return emit(RoomCloseRequestInitial());
  }
}
