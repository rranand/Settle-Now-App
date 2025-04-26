import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/room_repository.dart';
import 'package:settlenow_v2/model/room_info_model.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository roomRepository;

  RoomBloc(this.roomRepository) : super(RoomInitial()) {
    on<RoomFetch>(_roomFetch);
  }

  void _roomFetch(RoomFetch event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      List<RoomInfoModel> data = await roomRepository.fetchData(
        "niriif@kff.ed",
      );
      return emit(RoomFetchSuccess(data));
    } catch (e) {
      return emit(RoomFailure(e.toString()));
    }
  }
}
