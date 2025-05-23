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
    on<RoomAddNewTransaction>(_roomAddTransaction);
    on<RoomUpdateTransaction>(_roomUpdateTransaction);
    on<RoomDeleteTransaction>(_roomDeleteTransaction);
  }

  void _roomFetch(RoomFetch event, Emitter<RoomState> emit) async {
    emit(RoomLoading());
    try {
      List<TransactionModel> data = await repo.fetchData("email", event.id);
      emit(RoomFetchSuccess(event.id, data));
    } catch (e) {
      emit(RoomFailure(e.toString()));
    }
  }

  void _roomAddTransaction(
    RoomAddNewTransaction event,
    Emitter<RoomState> emit,
  ) async {
    final oldData = state as RoomFetchSuccess;
    List<TransactionModel> data = [event.data, ...oldData.data];
    return emit(RoomFetchSuccess(oldData.id, data));
  }

  void _roomUpdateTransaction(
    RoomUpdateTransaction event,
    Emitter<RoomState> emit,
  ) async {
    final oldData = state as RoomFetchSuccess;
    List<TransactionModel> data = [...oldData.data];
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        data[i] = event.data;
        break;
      }
    }
    return emit(RoomFetchSuccess(oldData.id, data));
  }

  void _roomDeleteTransaction(
    RoomDeleteTransaction event,
    Emitter<RoomState> emit,
  ) async {
    final oldData = state as RoomFetchSuccess;
    List<TransactionModel> data = [...oldData.data];
    data.removeWhere((element) => element.id == event.expenseID);
    return emit(RoomFetchSuccess(oldData.id, data));
  }
}
