import 'package:bloc/bloc.dart';
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
    on<LendenRoomFetch>(_lendenRoomFetch);
    on<LendenCloseRoom>(_lendenCloseRoom);
    on<LendenFetchTransaction>(_lendenFetchTransaction);
    on<LendenAddNewTransaction>(_lendenAddNewTransaction);
    on<LendenUpdateTransaction>(_lendenUpdateTransaction);
    on<LendenDeleteTransaction>(_lendenDeleteTransaction);
    on<LendenRoomDelete>(_lendenRoomDelete);
    on<LendenRoomReset>(_lendenRoomReset);
    on<LendenRoomUpdate>(_lendenRoomUpdate);
  }

  void _lendenRoomFetch(
    LendenRoomFetch event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is LendenRoomLoading) return;
    emit(LendenRoomLoading());
    try {
      Tuple<LendenDashboardModel, List<LendenTransactionModel>, bool> data =
          await repo.fetchData(event.id);

      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: data.first));
      return emit(
        LendenRoomFetchSuccess(
          id: event.id,
          roomData: data.first,
          data: data.second,
          fetchStatus: FetchStatus.done,
          hasMoreData: data.third,
        ),
      );
    } catch (e) {
      return emit(LendenRoomFailure(error: e.toString()));
    }
  }

  void _lendenFetchTransaction(
    LendenFetchTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) return;
    if (!(state as LendenRoomFetchSuccess).hasMoreData) return;

    final oldState = (state as LendenRoomFetchSuccess);

    emit(
      LendenRoomFetchSuccess(
        id: oldState.id,
        roomData: oldState.roomData,
        data: oldState.data,
        fetchStatus: FetchStatus.progress,
        hasMoreData: oldState.hasMoreData,
      ),
    );

    try {
      Pair<List<LendenTransactionModel>, bool> data = await repo
          .fetchTransaction(
            oldState.id,
            oldState.data.length,
            oldState.roomData.users,
          );

      return emit(
        LendenRoomFetchSuccess(
          id: oldState.id,
          roomData: oldState.roomData,
          data: [...oldState.data, ...data.first],
          fetchStatus: FetchStatus.done,
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      emit(LendenRoomFailure(error: e.toString()));
      return emit(
        LendenRoomFetchSuccess(
          id: oldState.id,
          roomData: oldState.roomData,
          data: oldState.data,
          fetchStatus: FetchStatus.done,
          hasMoreData: oldState.hasMoreData,
        ),
      );
    }
  }

  void _lendenAddNewTransaction(
    LendenAddNewTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
    if (state is! LendenRoomFetchSuccess) {
      return;
    }
    final oldData = state as LendenRoomFetchSuccess;
    List<LendenTransactionModel> data = [...oldData.data, event.data];
    List<LendenUserModel> newUserArr = [...oldData.roomData.users];

    for (int i = 0; i < newUserArr.length; i++) {
      if (newUserArr[i].id == event.data.createdBy.id) {
        if (event.data.amount < 0) {
          newUserArr[i].owe += event.data.amount * -1;
        } else {
          newUserArr[i].gave += event.data.amount;
        }

        break;
      }
    }

    LendenDashboardModel roomData = oldData.roomData.copyWith(
      users: newUserArr,
      modifiedOn: DateTime.now(),
    );

    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(
      LendenRoomFetchSuccess(
        id: oldData.id,
        roomData: roomData,
        data: data,
        hasMoreData: oldData.hasMoreData,
        fetchStatus: oldData.fetchStatus,
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
    final oldData = state as LendenRoomFetchSuccess;
    List<LendenTransactionModel> data = [...oldData.data];
    List<LendenUserModel> newUserArr = [...oldData.roomData.users];

    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        for (int j = 0; j < newUserArr.length; j++) {
          if (newUserArr[j].id == event.data.createdBy.id) {
            if (event.data.amount < 0) {
              newUserArr[j].owe += event.data.amount * -1;
            } else {
              newUserArr[j].gave += event.data.amount;
            }

            if (data[i].amount < 0) {
              newUserArr[j].owe -= data[i].amount * -1;
            } else {
              newUserArr[j].gave -= data[i].amount;
            }

            break;
          }
        }

        data[i] = event.data;
        break;
      }
    }
    LendenDashboardModel roomData = oldData.roomData.copyWith(
      users: newUserArr,
      modifiedOn: DateTime.now(),
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(
      LendenRoomFetchSuccess(
        id: oldData.id,
        roomData: roomData,
        data: data,
        hasMoreData: oldData.hasMoreData,
        fetchStatus: oldData.fetchStatus,
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
    final oldData = state as LendenRoomFetchSuccess;
    List<LendenTransactionModel> data = [...oldData.data];
    List<LendenUserModel> newUserArr = [...oldData.roomData.users];

    data.removeWhere((element) {
      if (element.id == event.expenseID) {
        for (int j = 0; j < newUserArr.length; j++) {
          if (newUserArr[j].id == element.createdBy.id) {
            if (element.amount < 0) {
              newUserArr[j].owe -= element.amount * -1;
            } else {
              newUserArr[j].gave -= element.amount;
            }

            break;
          }
        }
        return true;
      } else {
        return false;
      }
    });
    LendenDashboardModel roomData = oldData.roomData.copyWith(
      users: newUserArr,
      modifiedOn: DateTime.now(),
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(
      LendenRoomFetchSuccess(
        id: oldData.id,
        roomData: roomData,
        data: data,
        hasMoreData: oldData.hasMoreData,
        fetchStatus: oldData.fetchStatus,
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
    final oldData = state as LendenRoomFetchSuccess;
    emit(LendenRoomLoading());
    List<LendenUserModel> users = [...oldData.roomData.users];
    try {
      await repo.closeRoom(oldData.id);
      bool active = false;
      for (int i = 0; i < users.length; i++) {
        if (users[i].id == event.uid) {
          users[i].active = false;
        } else {
          active = users[i].active;
        }
      }
      LendenDashboardModel roomData = oldData.roomData.copyWith(
        status: active ? RoomStatus.partiallyClosed : RoomStatus.closed,
        users: users,
        modifiedOn: DateTime.now(),
      );
      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
      return emit(
        LendenRoomFetchSuccess(
          id: oldData.id,
          roomData: roomData,
          data: oldData.data,
          hasMoreData: oldData.hasMoreData,
          fetchStatus: oldData.fetchStatus,
        ),
      );
    } catch (e) {
      emit(LendenRoomFailure(error: e.toString()));
      return emit(
        LendenRoomFetchSuccess(
          id: oldData.id,
          roomData: oldData.roomData,
          data: oldData.data,
          hasMoreData: oldData.hasMoreData,
          fetchStatus: oldData.fetchStatus,
        ),
      );
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
    final oldData = state as LendenRoomFetchSuccess;

    showSnackbarWithChildWidget(
      "Updating Name",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: event.scaffoldMessengerState,
    );
    try {
      await repo.updateRoom(oldData.id, event.roomName);
      LendenDashboardModel updatedData = oldData.roomData.copyWith(
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
          id: oldData.id,
          roomData: updatedData,
          data: oldData.data,
          hasMoreData: oldData.hasMoreData,
          fetchStatus: oldData.fetchStatus,
        ),
      );
    } catch (e) {
      event.scaffoldMessengerState.hideCurrentSnackBar();
      emit(LendenRoomFailure(error: e.toString()));
      return emit(
        LendenRoomFetchSuccess(
          id: oldData.id,
          roomData: oldData.roomData,
          data: oldData.data,
          hasMoreData: oldData.hasMoreData,
          fetchStatus: oldData.fetchStatus,
        ),
      );
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
      return emit(
        LendenRoomFetchSuccess(
          id: oldData.id,
          roomData: oldData.roomData,
          data: oldData.data,
          hasMoreData: oldData.hasMoreData,
          fetchStatus: oldData.fetchStatus,
        ),
      );
    }
  }
}
