import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

part 'room_user_state.dart';

class RoomUserCubit extends Cubit<RoomUserState> {
  final RoomRepository repo;
  RoomUserCubit(this.repo) : super(RoomUserInitial());

  void fetchData(String id) async {
    emit(RoomUserLoading());
    try {
      List<RoomUserModel> data = await repo.fetchUserData("email", id);
      return emit(RoomUserSuccess(data));
    } catch (e) {
      return emit(RoomUserFailure(e.toString()));
    }
  }
}
