import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'lenden_room_event.dart';
part 'lenden_room_state.dart';

class LendenRoomBloc extends Bloc<LendenRoomEvent, LendenRoomState> {
  final LendenRoomRepository repo;
  final LendenDashboardBloc lendenDashboardBloc;

  LendenRoomBloc(this.repo, this.lendenDashboardBloc)
    : super(LendenRoomInitial()) {
    on<LendenRoomFetch>(_lendenRoomFetch, transformer: droppable());
    on<LendenCloseRoom>(_lendenCloseRoom, transformer: droppable());
    on<LendenFetchTransaction>(
      _lendenFetchTransaction,
      transformer: droppable(),
    );
    on<LendenAddNewTransaction>(
      _lendenAddNewTransaction,
      transformer: sequential(),
    );
    on<LendenUpdateTransaction>(
      _lendenUpdateTransaction,
      transformer: sequential(),
    );
    on<LendenDeleteTransaction>(
      _lendenDeleteTransaction,
      transformer: sequential(),
    );
    on<LendenRoomDelete>(_lendenRoomDelete, transformer: droppable());
    on<LendenRoomReset>(_lendenRoomReset, transformer: droppable());
    on<LendenRoomUpdate>(_lendenRoomUpdate, transformer: droppable());
  }

  void _lendenRoomFetch(
    LendenRoomFetch event,
    Emitter<LendenRoomState> emit,
  ) async {
    LendenRoomFetchSuccess? oldState;

    if (!event.isFreshFetch && state is LendenRoomFetchSuccess) {
      oldState = state as LendenRoomFetchSuccess;
      if (!oldState.hasMoreData) {
        return;
      }

      emit(oldState.copyWith(isLoadingMore: true, error: null));
    } else {
      emit(LendenRoomLoading());
    }

    try {
      Tuple<LendenDashboardModel, List<LendenTransactionModel>, bool> data =
          await repo.fetchData(event.id);

      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: data.first));

      final newData = LinkedHashMap<String, LendenTransactionModel>.fromEntries(
        data.second.map((t) => MapEntry(t.id, t)),
      );

      return emit(
        LendenRoomFetchSuccess(
          id: event.id,
          roomData: data.first,
          data: newData,
          hasMoreData: data.third,
        ),
      );
    } catch (e) {
      if (oldState == null || event.isFreshFetch) {
        return emit(LendenRoomFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, error: e.toString()),
        );
      }
    }
  }

  void _lendenFetchTransaction(
    LendenFetchTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) return;
    final oldState = (state as LendenRoomFetchSuccess);

    if (!oldState.hasMoreData) {
      return;
    }

    emit(oldState.copyWith(isLoadingMore: true, error: null));

    try {
      Pair<List<LendenTransactionModel>, bool> data = await repo
          .fetchTransaction(
            oldState.id,
            oldState.dataList.isEmpty
                ? DateTime.now()
                : oldState.dataList.last.createdOn,
          );

      LinkedHashMap<String, LendenTransactionModel> allRecords =
          LinkedHashMap();

      allRecords.addAll(oldState.data);
      allRecords.addAll(
        LinkedHashMap<String, LendenTransactionModel>.fromEntries(
          data.first.map((t) => MapEntry(t.id, t)),
        ),
      );

      return emit(
        oldState.copyWith(
          data: allRecords,
          isLoadingMore: false,
          error: null,
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      emit(LendenRoomFailure(error: e.toString()));
      return emit(oldState.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }

  void _lendenAddNewTransaction(
    LendenAddNewTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) {
      return;
    }
    final oldState = state as LendenRoomFetchSuccess;

    LinkedHashMap<String, LendenTransactionModel> data =
        LinkedHashMap()..addAll(oldState.data);
    data.addAll({event.data.id: event.data});

    List<LendenUserModel> newUserArr = [...oldState.roomData.users];

    for (int i = 0; i < newUserArr.length; i++) {
      if (newUserArr[i].id == event.data.createdBy) {
        if (event.data.amount < 0) {
          newUserArr[i].owe += event.data.amount * -1;
        } else {
          newUserArr[i].gave += event.data.amount;
        }

        break;
      }
    }

    LendenDashboardModel roomData = oldState.roomData.copyWith(
      users: newUserArr,
      modifiedOn: DateTime.now(),
    );

    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));

    return emit(
      LendenRoomFetchSuccess(
        id: oldState.id,
        roomData: roomData,
        data: data,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _lendenUpdateTransaction(
    LendenUpdateTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) {
      return;
    }
    final oldState = state as LendenRoomFetchSuccess;

    LinkedHashMap<String, LendenTransactionModel> data =
        LinkedHashMap()..addAll(oldState.data);

    List<LendenUserModel> newUserArr = [...oldState.roomData.users];
    double oldAmount = data[event.data.id]?.amount ?? 0.0;

    for (int i = 0; i < newUserArr.length; i++) {
      if (newUserArr[i].id == event.data.createdBy) {
        if (event.data.amount < 0) {
          newUserArr[i].owe += event.data.amount * -1;
        } else {
          newUserArr[i].gave += event.data.amount;
        }

        if (oldAmount < 0) {
          newUserArr[i].owe -= oldAmount * -1;
        } else {
          newUserArr[i].gave -= oldAmount;
        }

        break;
      }
    }

    data[event.data.id] = event.data;
    LendenDashboardModel roomData = oldState.roomData.copyWith(
      users: newUserArr,
      modifiedOn: DateTime.now(),
    );

    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));

    return emit(
      LendenRoomFetchSuccess(
        id: oldState.id,
        roomData: roomData,
        data: data,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _lendenDeleteTransaction(
    LendenDeleteTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) {
      return;
    }
    final oldState = state as LendenRoomFetchSuccess;

    LinkedHashMap<String, LendenTransactionModel> data =
        LinkedHashMap()..addAll(oldState.data);

    List<LendenUserModel> newUserArr = [...oldState.roomData.users];
    double oldAmount = data[event.expenseID]?.amount ?? 0.0;
    String createdBy = data[event.expenseID]?.createdBy ?? "";

    for (int j = 0; j < newUserArr.length; j++) {
      if (newUserArr[j].id == createdBy) {
        if (oldAmount < 0) {
          newUserArr[j].owe -= oldAmount * -1;
        } else {
          newUserArr[j].gave -= oldAmount;
        }

        break;
      }
    }

    data.remove(event.expenseID);
    LendenDashboardModel roomData = oldState.roomData.copyWith(
      users: newUserArr,
      modifiedOn: DateTime.now(),
    );

    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));

    return emit(
      LendenRoomFetchSuccess(
        id: oldState.id,
        roomData: roomData,
        data: data,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _lendenCloseRoom(
    LendenCloseRoom event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) {
      return;
    }
    final oldState = state as LendenRoomFetchSuccess;
    emit(LendenRoomLoading());

    List<LendenUserModel> users = [...oldState.roomData.users];
    try {
      await repo.closeRoom(oldState.id);

      bool active = false;
      for (int i = 0; i < users.length; i++) {
        if (users[i].id == event.uid) {
          users[i].active = false;
        } else {
          active = users[i].active;
        }
      }

      LendenDashboardModel roomData = oldState.roomData.copyWith(
        status: active ? RoomStatus.partiallyClosed : RoomStatus.closed,
        users: users,
        modifiedOn: DateTime.now(),
      );

      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));

      return emit(
        LendenRoomFetchSuccess(
          id: oldState.id,
          roomData: roomData,
          data: oldState.data,
          hasMoreData: oldState.hasMoreData,
        ),
      );
    } catch (e) {
      emit(LendenRoomFailure(error: e.toString()));
      return emit(oldState.copyWith(isLoadingMore: false, error: null));
    }
  }

  void _lendenRoomReset(LendenRoomReset event, Emitter<LendenRoomState> emit) {
    return emit(LendenRoomInitial());
  }

  void _lendenRoomUpdate(
    LendenRoomUpdate event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) {
      return;
    }
    final oldState = state as LendenRoomFetchSuccess;

    showSnackbarWithChildWidget(
      "Updating Name",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: event.scaffoldMessengerState,
    );

    try {
      await repo.updateRoom(oldState.id, event.roomName);

      LendenDashboardModel updatedData = oldState.roomData.copyWith(
        roomName: event.roomName,
      );

      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: updatedData));

      event.scaffoldMessengerState.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Room Name Updated",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: event.scaffoldMessengerState,
      );

      return emit(
        LendenRoomFetchSuccess(
          id: oldState.id,
          roomData: updatedData,
          data: oldState.data,
          hasMoreData: oldState.hasMoreData,
        ),
      );
    } catch (e) {
      event.scaffoldMessengerState.hideCurrentSnackBar();
      emit(LendenRoomFailure(error: e.toString()));

      return emit(oldState.copyWith(isLoadingMore: false, error: null));
    }
  }

  void _lendenRoomDelete(
    LendenRoomDelete event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) {
      return;
    }
    final oldData = state as LendenRoomFetchSuccess;

    if (oldData.id != event.id) {
      return;
    }

    showSnackbarWithChildWidget(
      event.isRemoving ? "Leaving Room" : "Deleting Room",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: event.scaffoldMessengerState,
    );

    try {
      await repo.deleteRoom(oldData.id);

      lendenDashboardBloc.add(LendenDashboardOnDeleteRoom(id: event.id));

      event.scaffoldMessengerState.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        event.isRemoving ? "You’ve left the room" : "Room deleted successfully",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: event.scaffoldMessengerState,
      );

      return emit(LendenRoomInitial());
    } catch (e) {
      event.scaffoldMessengerState.hideCurrentSnackBar();
      emit(LendenRoomFailure(error: e.toString()));

      return emit(oldData.copyWith(isLoadingMore: false, error: null));
    }
  }
}
