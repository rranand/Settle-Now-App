import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';

part 'lenden_room_name_state.dart';

class LendenRoomNameCubit extends Cubit<LendenRoomNameState> {
  final LendenRoomRepository repo;
  LendenRoomNameCubit(this.repo) : super(LendenRoomNameInitial());

  void fetchName(String id, String? name) async {
    emit(LendenRoomNameLoading());
    try {
      if (name == null) {
        name = await repo.fetchRoomNameByID("email", id);
        emit(LendenRoomNameSuccess(name));
      } else {
        emit(LendenRoomNameSuccess(name));
      }
    } catch (e) {
      emit(LendenRoomNameSuccess(e.toString()));
    }
  }
}
