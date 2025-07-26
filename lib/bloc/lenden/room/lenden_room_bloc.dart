import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/lenden_user_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

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
          .fetchData(event.id, event.authToken);
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
      await repo.closeRoom(oldData.id, event.authToken);
      bool isClosed = true;
      for (int i = 0; i < users.length; i++) {
        if (users[i].id == event.uid) {
          users[i].isClosed = true;
        }
        isClosed = isClosed && users[i].isClosed;
      }
      LendenDashboardModel roomData = oldData.roomData.copyWith(
        status: isClosed ? "Closed" : "Partially Closed",
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
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
      ),
      duration: Duration(minutes: 2),
      scaffoldMessenger: event.scaffoldMessengerState,
    );
    try {
      await repo.updateRoom(oldData.id, event.authToken, event.roomName);
      LendenDashboardModel updatedData = oldData.roomData.copyWith(
        roomName: event.roomName,
      );
      lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: updatedData));
      event.scaffoldMessengerState.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Room Name Updated",
        child: Icon(Iconsax.tick_circle5, color: Colors.green),
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
}
