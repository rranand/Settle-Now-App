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
    on<LendenAddNewTransaction>(_lendenAddNewTransaction);
    on<LendenUpdateTransaction>(_lendenUpdateTransaction);
    on<LendenDeleteTransaction>(_lendenDeleteTransaction);
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

  void _lendenAddNewTransaction(
    LendenAddNewTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    final oldData = state as LendenRoomFetchSuccess;
    List<LendenRoomModel> data = [event.data, ...oldData.data];
    return emit(LendenRoomFetchSuccess(oldData.id, data));
  }

  void _lendenUpdateTransaction(
    LendenUpdateTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    final oldData = state as LendenRoomFetchSuccess;
    List<LendenRoomModel> data = [...oldData.data];
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        data[i] = event.data;
        break;
      }
    }
    return emit(LendenRoomFetchSuccess(oldData.id, data));
  }

  void _lendenDeleteTransaction(
    LendenDeleteTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    final oldData = state as LendenRoomFetchSuccess;
    List<LendenRoomModel> data = [...oldData.data];
    data.removeWhere((element) => element.id == event.expenseID);
    return emit(LendenRoomFetchSuccess(oldData.id, data));
  }
}
