import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:settlenow/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow/model/lenden_dashboard_model.dart';
import 'package:settlenow/model/lenden_room_model.dart';
import 'package:settlenow/model/lenden_user_model.dart';
import 'package:settlenow/util/custom/pair.dart';
import 'package:settlenow/util/widgets/shimmer_effect.dart';
import 'package:settlenow/util/widgets/snackbar.dart';
import 'package:settlenow/util/widgets/widgets.dart';

part 'lenden_room_event.dart';
part 'lenden_room_state.dart';

class LendenRoomBloc extends Bloc<LendenRoomEvent, LendenRoomState> {
  final LendenRoomRepository repo;
  final LendenDashboardBloc lendenDashboardBloc;

  LendenRoomBloc(this.repo, this.lendenDashboardBloc)
    : super(LendenRoomInitial()) {
    on<LendenRoomFetch>(_lendenRoomFetch);
    on<LendenCloseRoom>(_lendenCloseRoom);
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
      Pair<LendenDashboardModel, List<LendenTransactionModel>> data = await repo
          .fetchData(event.id);

      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: data.first));
      return emit(LendenRoomFetchSuccess(event.id, data.first, data.second));
    } catch (e) {
      return emit(LendenRoomFailure(e.toString()));
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
    LendenDashboardModel roomData = oldData.roomData.copyWith(
      amount: oldData.roomData.amount + event.data.amount,
      modifiedOn: DateTime.now(),
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(LendenRoomFetchSuccess(oldData.id, roomData, data));
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
    double updatedAmount = oldData.roomData.amount + event.data.amount;
    for (int i = 0; i < data.length; i++) {
      if (data[i].id == event.data.id) {
        updatedAmount -= data[i].amount;
        data[i] = event.data;
        break;
      }
    }
    LendenDashboardModel roomData = oldData.roomData.copyWith(
      amount: updatedAmount,
      modifiedOn: DateTime.now(),
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(LendenRoomFetchSuccess(oldData.id, roomData, data));
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
    double updatedAmount = oldData.roomData.amount;
    data.removeWhere((element) {
      if (element.id == event.expenseID) {
        updatedAmount -= element.amount;
        return true;
      } else {
        return false;
      }
    });
    LendenDashboardModel roomData = oldData.roomData.copyWith(
      amount: updatedAmount,
      modifiedOn: DateTime.now(),
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(LendenRoomFetchSuccess(oldData.id, roomData, data));
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
        status: active ? "Partially Closed" : "Closed",
        users: users,
        modifiedOn: DateTime.now(),
      );
      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
      return emit(LendenRoomFetchSuccess(oldData.id, roomData, oldData.data));
    } catch (e) {
      emit(LendenRoomFailure(e.toString()));
      return emit(
        LendenRoomFetchSuccess(oldData.id, oldData.roomData, oldData.data),
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
        LendenRoomFetchSuccess(oldData.id, updatedData, oldData.data),
      );
    } catch (e) {
      event.scaffoldMessengerState.hideCurrentSnackBar();
      emit(LendenRoomFailure(e.toString()));
      return emit(
        LendenRoomFetchSuccess(oldData.id, oldData.roomData, oldData.data),
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
      emit(LendenRoomFailure(e.toString()));
      return emit(
        LendenRoomFetchSuccess(oldData.id, oldData.roomData, oldData.data),
      );
    }
  }
}
