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
}
