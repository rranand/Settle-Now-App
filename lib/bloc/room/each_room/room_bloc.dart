import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository repo;

  RoomBloc(this.repo) : super(RoomInitial()) {
    on<RoomFetch>(_roomFetch);
  }

  void _roomFetch(RoomFetch event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      List<TransactionModel> data = await repo.fetchData("email", event.id);
      emit(RoomFetchSuccess(data));
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }
}
