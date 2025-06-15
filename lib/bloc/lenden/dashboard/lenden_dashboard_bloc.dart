import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/lenden/dashboard/lenden_dashboard_repository.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';

part 'lenden_dashboard_event.dart';
part 'lenden_dashboard_state.dart';

class LendenDashboardBloc
    extends Bloc<LendenDashboardEvent, LendenDashboardState> {
  final LendenDashboardRepository repo;

  LendenDashboardBloc(this.repo) : super(LendenDashboardInitial()) {
    on<LendenDashboardFetch>(_lendenDashboardFetch);
    on<LendenDashboardOnAddNewRoom>(_lendenDashboardOnAddNewRoom);
  }

  void _lendenDashboardFetch(
    LendenDashboardFetch event,
    Emitter<LendenDashboardState> emit,
  ) async {
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
}
