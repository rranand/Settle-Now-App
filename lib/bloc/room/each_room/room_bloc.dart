import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

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

    List<RoomTransactionModel> oldData = [];

    if (!event.isFreshFetch && state is RoomFetchSuccess) {
      final oldState = state as RoomFetchSuccess;
      if (oldState.id == event.id) {
        if (!oldState.hasMoreData) {
          return;
        }

        oldData = [...(oldState.data)];
      }
    }

    emit(RoomLoading(id: event.id));
    try {
      final data = await repo.fetchData(
        event.id,
        oldData.isEmpty ? DateTime.now() : oldData.last.createdOn,
      );
      return emit(
        RoomFetchSuccess(
          id: event.id,
          data: data.first,
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      emit(RoomFailure(error: e.toString()));
    }
  }

  void _roomAddTransaction(
    RoomAddNewTransaction event,
    Emitter<RoomState> emit,
  ) async {
    if (state is! RoomFetchSuccess) {
      return;
    }
    final oldData = state as RoomFetchSuccess;
    List<RoomTransactionModel> data = [...event.data, ...oldData.data];
    for (int i = 0; i < event.data.length; i++) {
      roomUserCubit.onAddNewTransaction(event.data[i]);
    }

    return emit(
      RoomFetchSuccess(
        id: oldData.id,
        data: data,
        hasMoreData: oldData.hasMoreData,
      ),
    );
  }

  void _roomUpdateTransaction(
    RoomUpdateTransaction event,
    Emitter<RoomState> emit,
  ) async {
    if (state is! RoomFetchSuccess) {
      return;
    }
    final oldData = state as RoomFetchSuccess;
    List<RoomTransactionModel> data = [...oldData.data];
    RoomTransactionModel oldExpense = RoomTransactionModel.empty();

    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        oldExpense = data[i].copyWith();
        data[i] = event.data;
        break;
      }
    }
    roomUserCubit.onUpdateTransaction(oldExpense, event.data);
    return emit(
      RoomFetchSuccess(
        id: oldData.id,
        data: data,
        hasMoreData: oldData.hasMoreData,
      ),
    );
  }

  void _roomDeleteTransaction(
    RoomDeleteTransaction event,
    Emitter<RoomState> emit,
  ) async {
    if (state is! RoomFetchSuccess) {
      return;
    }
    final oldData = state as RoomFetchSuccess;
    List<RoomTransactionModel> data = [...oldData.data];
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
    return emit(
      RoomFetchSuccess(
        id: oldData.id,
        data: data,
        hasMoreData: oldData.hasMoreData,
      ),
    );
  }

  void _roomBlocReset(RoomBlocReset event, Emitter<RoomState> emit) {
    return emit(RoomInitial());
  }

  void _roomAddToPersonalExpense(
    RoomAddToPersonalExpense event,
    Emitter<RoomState> emit,
  ) {
    if (state is! RoomFetchSuccess) {
      return;
    }
    final oldState = state as RoomFetchSuccess;
    if (oldState.id != event.id) {
      return;
    }
    List<RoomTransactionModel> oldData = List.from(oldState.data);

    for (int i = 0; i < oldData.length; i++) {
      if (oldData[i].id == event.expenseID) {
        oldData[i].personalExpenseId = event.personalExpenseID;
      }
    }

    return emit(
      RoomFetchSuccess(
        id: oldState.id,
        data: oldData,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }
}
