import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/model/lenden_room_model.dart';
import 'package:settlenow_v2/model/lenden_user_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';

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
  }

  void _lendenRoomFetch(
    LendenRoomFetch event,
    Emitter<LendenRoomState> emit,
  ) async {
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
    final oldData = state as LendenRoomFetchSuccess;
    List<LendenTransactionModel> data = [event.data, ...oldData.data];
    LendenDashboardModel roomData = oldData.roomData.copyWith(
      amount: oldData.roomData.amount + event.data.amount,
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(LendenRoomFetchSuccess(oldData.id, roomData, data));
  }

  void _lendenUpdateTransaction(
    LendenUpdateTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
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
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(LendenRoomFetchSuccess(oldData.id, roomData, data));
  }

  void _lendenDeleteTransaction(
    LendenDeleteTransaction event,
    Emitter<LendenRoomState> emit,
  ) async {
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
    );
    lendenDashboardBloc.add(LendenDashboardOnUpdateRoom(data: roomData));
    return emit(LendenRoomFetchSuccess(oldData.id, roomData, data));
  }

  void _lendenCloseRoom(
    LendenCloseRoom event,
    Emitter<LendenRoomState> emit,
  ) async {
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
}
