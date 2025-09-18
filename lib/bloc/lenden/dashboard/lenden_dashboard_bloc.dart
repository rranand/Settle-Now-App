import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/lenden/dashboard/lenden_dashboard_repository.dart';
import 'package:settlenow/model/lenden_dashboard_model.dart';

part 'lenden_dashboard_event.dart';
part 'lenden_dashboard_state.dart';

class LendenDashboardBloc
    extends Bloc<LendenDashboardEvent, LendenDashboardState> {
  final LendenDashboardRepository repo;

  LendenDashboardBloc(this.repo) : super(LendenDashboardInitial()) {
    on<LendenDashboardFetch>(_lendenDashboardFetch);
    on<LendenDashboardOnAddNewRoom>(_lendenDashboardOnAddNewRoom);
    on<LendenDashboardOnUpdateRoom>(_lendenDashboardOnUpdateRoom);
    on<LendenDashboardReset>(_lendenDashboardReset);
    on<LendenDashboardOnDeleteRoom>(_lendenDashboardOnDeleteRoom);
  }

  void _lendenDashboardFetch(
    LendenDashboardFetch event,
    Emitter<LendenDashboardState> emit,
  ) async {
    if (state is LendenDashboardLoading) return;
    emit(LendenDashboardLoading());
    try {
      List<LendenDashboardModel> data = await repo.fetchData(event.authToken);
      return emit(LendenDashboardFetchSuccess(data));
    } catch (e) {
      return emit(LendenDashboardFailure(e.toString()));
    }
  }

  void _lendenDashboardOnAddNewRoom(
    LendenDashboardOnAddNewRoom event,
    Emitter<LendenDashboardState> emit,
  ) async {
    if (state is! LendenDashboardFetchSuccess) {
      return;
    }
    final allLendenRoomState = (state as LendenDashboardFetchSuccess);
    List<LendenDashboardModel> data = [];
    if (event.isLoading) {
      data = [event.data, ...allLendenRoomState.data];
    } else {
      if (event.data.hasData) {
        data = [event.data];
      }
      for (int i = 0; i < allLendenRoomState.data.length; i++) {
        if (allLendenRoomState.data[i].hasData) {
          data.add(allLendenRoomState.data[i]);
        }
      }
    }
    return emit(LendenDashboardFetchSuccess(data));
  }

  void _lendenDashboardOnUpdateRoom(
    LendenDashboardOnUpdateRoom event,
    Emitter<LendenDashboardState> emit,
  ) async {
    if (state is LendenDashboardFetchSuccess) {
      final allLendenRoomState = (state as LendenDashboardFetchSuccess);
      List<LendenDashboardModel> data = allLendenRoomState.data;
      int index = -1;

      for (int i = 0; i < data.length; i++) {
        if (data[i].id == event.data.id) {
          index = i;
          data[i] = event.data;
          break;
        }
      }

      if (index == -1) {
        data = [event.data, ...data];
      }
      return emit(LendenDashboardFetchSuccess(data));
    }
  }

  void _lendenDashboardOnDeleteRoom(
    LendenDashboardOnDeleteRoom event,
    Emitter<LendenDashboardState> emit,
  ) async {
    if (state is LendenDashboardFetchSuccess) {
      final allLendenRoomState = (state as LendenDashboardFetchSuccess);
      List<LendenDashboardModel> data = [...allLendenRoomState.data];
      data.removeWhere((ele) => ele.id == event.id);
      return emit(LendenDashboardFetchSuccess(data));
    }
  }

  void _lendenDashboardReset(
    LendenDashboardReset event,
    Emitter<LendenDashboardState> emit,
  ) {
    return emit(LendenDashboardInitial());
  }
}
