import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/room/dashboard/room_dashboard_repository.dart';
import 'package:settlenow_v2/model/room_info_model.dart';

part 'room_dashboard_event.dart';
part 'room_dashboard_state.dart';

class RoomDashboardBloc extends Bloc<RoomDashboardEvent, RoomDashboardState> {
  final RoomDashboardRepository repo;

  RoomDashboardBloc(this.repo) : super(RoomDashboardInitial()) {
    on<RoomDashboardFetch>(_roomFetch);
    on<RoomDashboardOnAddNewRoom>(_roomDashboardOnAddNewRoom);
  }

  void _roomFetch(
    RoomDashboardFetch event,
    Emitter<RoomDashboardState> emit,
  ) async {
    emit(RoomDashboardLoading());
    try {
      List<RoomInfoModel> data = await repo.fetchData("niriif@kff.ed");
      return emit(RoomDashboardFetchSuccess(data));
    } catch (e) {
      return emit(RoomDashboardFailure(e.toString()));
    }
  }

  void _roomDashboardOnAddNewRoom(
    RoomDashboardOnAddNewRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    final allRoomState = (state as RoomDashboardFetchSuccess);
    List<RoomInfoModel> data = [];
    if (event.isLoading) {
      data = [event.data, ...allRoomState.data];
    } else {
      if (event.data.hasData) {
        data = [event.data];
      }
      for (int i = 0; i < allRoomState.data.length; i++) {
        if (allRoomState.data[i].hasData) {
          data.add(allRoomState.data[i]);
        }
      }
    }
    return emit(RoomDashboardFetchSuccess(data));
  }
}
