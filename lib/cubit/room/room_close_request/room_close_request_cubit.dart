import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
part 'room_close_request_state.dart';

class RoomCloseRequestCubit extends Cubit<RoomCloseRequestState> {
  final RoomRepository repo;
  RoomCloseRequestCubit(this.repo) : super(RoomCloseRequestInitial());

  void closeRoomRequest(String id, String authToken) async {
    emit(RoomCloseRequestLoading());
    try {
      await repo.closeRoomRequest(id, authToken);
      emit(RoomCloseRequestSuccess(id));
    } catch (e) {
      return emit(RoomCloseRequestFailure(id, e.toString()));
    }
  }
}
