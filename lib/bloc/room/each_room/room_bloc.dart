import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/core.dart';
import 'package:settlenow_v2/cubit/room/room_user/room_user_cubit.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository repo;
  final RoomUserCubit roomUserCubit;

  RoomBloc(this.repo, this.roomUserCubit) : super(RoomInitial()) {
    on<RoomFetch>(_roomFetch);
    on<RoomAddNewTransaction>(_roomAddTransaction);
    on<RoomUpdateTransaction>(_roomUpdateTransaction);
    on<RoomDeleteTransaction>(_roomDeleteTransaction);
    on<RoomBlocReset>(_roomBlocReset);
    on<RoomAddToPersonalExpense>(_roomAddToPersonalExpense);
  }

  void _roomFetch(RoomFetch event, Emitter<RoomState> emit) async {
    if (state is RoomLoading && (state as RoomLoading).id == event.id) {
      return;
    }
    emit(RoomLoading(event.id));
    try {
      List<TransactionModel> data = await repo.fetchData(
        event.id,
        event.authToken,
        event.users,
      );
      return emit(RoomFetchSuccess(event.id, data));
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
    roomUserCubit.onAddNewTransaction(event.data);
    return emit(RoomFetchSuccess(oldData.id, data));
  }

  void _roomUpdateTransaction(
    RoomUpdateTransaction event,
    Emitter<RoomState> emit,
  ) async {
    final oldData = state as RoomFetchSuccess;
    List<TransactionModel> data = [...oldData.data];
    TransactionModel oldExpense = TransactionModel.empty();

    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        oldExpense = data[i];
        data[i] = event.data;
        break;
      }
    }
    roomUserCubit.onUpdateTransaction(oldExpense, event.data);
    return emit(RoomFetchSuccess(oldData.id, data));
  }

  void _roomDeleteTransaction(
    RoomDeleteTransaction event,
    Emitter<RoomState> emit,
  ) async {
    final oldData = state as RoomFetchSuccess;
    List<TransactionModel> data = [...oldData.data];
    int index = -1;
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.expenseID) {
        index = i;
        break;
      }
    }
    if (index != -1) {
      roomUserCubit.onDeleteTransaction(data.removeAt(index));
    }
    return emit(RoomFetchSuccess(oldData.id, data));
  }

  void _roomBlocReset(RoomBlocReset event, Emitter<RoomState> emit) {
    return emit(RoomInitial());
  }

  void _roomAddToPersonalExpense(
    RoomAddToPersonalExpense event,
    Emitter<RoomState> emit,
  ) {
    final oldState = state as RoomFetchSuccess;
    if (oldState.id != event.id) {
      return;
    }
    List<TransactionModel> oldData = List.from(oldState.data);

    for (int i = 0; i < oldData.length; i++) {
      if (oldData[i].id == event.expenseID) {
        oldData[i].isAddedToPersonalExpense = true;
      }
    }

    return emit(RoomFetchSuccess(oldState.id, oldData));
  }
}
