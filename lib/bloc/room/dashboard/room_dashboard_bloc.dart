import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/data/repository/room/dashboard/room_dashboard_repository.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/util/custom/pair.dart';
import 'package:settlenow_v2/util/enum/enums.dart';

part 'room_dashboard_event.dart';
part 'room_dashboard_state.dart';

class RoomDashboardBloc extends Bloc<RoomDashboardEvent, RoomDashboardState> {
  final RoomDashboardRepository repo;

  RoomDashboardBloc(this.repo) : super(RoomDashboardInitial()) {
    on<RoomDashboardFetch>(_roomFetch);
    on<RoomDashboardOnAddNewRoom>(_roomDashboardOnAddNewRoom);
    on<RoomDashboardOnCloseRoom>(_roomDashboardOnCloseRoom);
    on<RoomDashboardReset>(_roomDashboardReset);
  }

  void _roomFetch(
    RoomDashboardFetch event,
    Emitter<RoomDashboardState> emit,
  ) async {
    List<RoomInfoModel> oldRoomActiveData = [];
    List<RoomInfoModel> oldRoomInActiveData = [];
    FetchStatus oldRoomActiveStatus = FetchStatus.success;
    FetchStatus oldRoomInActiveStatus = FetchStatus.success;

    if (state is RoomDashboardFetchSuccess) {
      final oldState = state as RoomDashboardFetchSuccess;
      oldRoomActiveData = oldState.activeData;
      oldRoomInActiveData = oldState.inactiveData;
      oldRoomActiveStatus = oldState.activeStatus;
      oldRoomInActiveStatus = oldState.inactiveStatus;

      if ((event.isActiveRoom && oldRoomActiveStatus == FetchStatus.done) ||
          (!event.isActiveRoom && oldRoomInActiveStatus == FetchStatus.done)) {
        return emit(
          RoomDashboardFetchSuccess(
            activeStatus: oldRoomActiveStatus,
            inactiveStatus: oldRoomInActiveStatus,
            activeData: oldRoomActiveData,
            inactiveData: oldRoomInActiveData,
          ),
        );
      }
    }

    emit(RoomDashboardLoading());
    try {
      Pair<List<RoomInfoModel>, bool> data = await repo.fetchData(
        event.isActiveRoom,
        event.isActiveRoom
            ? oldRoomActiveData.length
            : oldRoomInActiveData.length,
        event.authToken,
      );
      if (event.isActiveRoom) {
        return emit(
          RoomDashboardFetchSuccess(
            activeStatus: data.second ? FetchStatus.success : FetchStatus.done,
            inactiveStatus: oldRoomInActiveStatus,
            activeData: [...oldRoomActiveData, ...data.first],
            inactiveData: oldRoomActiveData,
          ),
        );
      } else {
        return emit(
          RoomDashboardFetchSuccess(
            activeStatus: oldRoomActiveStatus,
            inactiveStatus:
                data.second ? FetchStatus.success : FetchStatus.done,
            activeData: oldRoomActiveData,
            inactiveData: [...oldRoomInActiveData, ...data.first],
          ),
        );
      }
    } catch (e) {
      emit(RoomDashboardFailure(e.toString()));
      return emit(
        RoomDashboardFetchSuccess(
          activeStatus: oldRoomActiveStatus,
          inactiveStatus: oldRoomInActiveStatus,
          activeData: oldRoomActiveData,
          inactiveData: oldRoomInActiveData,
        ),
      );
    }
  }

  void _roomDashboardOnAddNewRoom(
    RoomDashboardOnAddNewRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    final allRoomState = (state as RoomDashboardFetchSuccess);
    List<RoomInfoModel> data = [];
    if (event.isLoading) {
      data = [event.data, ...allRoomState.activeData];
    } else {
      if (event.data.hasData) {
        data = [event.data];
      }
      for (int i = 0; i < allRoomState.activeData.length; i++) {
        if (allRoomState.activeData[i].hasData) {
          data.add(allRoomState.activeData[i]);
        }
      }
    }
    return emit(
      RoomDashboardFetchSuccess(
        activeStatus: allRoomState.activeStatus,
        inactiveStatus: allRoomState.inactiveStatus,
        activeData: data,
        inactiveData: allRoomState.inactiveData,
      ),
    );
  }

  void _roomDashboardOnCloseRoom(
    RoomDashboardOnCloseRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    if (state is RoomDashboardFetchSuccess) {
      final allRoomState = (state as RoomDashboardFetchSuccess);
      List<RoomInfoModel> activeRoomData = [];
      List<RoomInfoModel> inactiveRoomData = [];

      for (int i = 0; i < allRoomState.activeData.length; i++) {
        if (allRoomState.activeData[i].id == event.data.id &&
            !event.data.active) {
          inactiveRoomData.add(event.data);
        } else {
          activeRoomData.add(allRoomState.activeData[i]);
        }
      }
      inactiveRoomData.addAll(allRoomState.inactiveData);
      return emit(
        RoomDashboardFetchSuccess(
          activeStatus: allRoomState.activeStatus,
          inactiveStatus: allRoomState.inactiveStatus,
          activeData: activeRoomData,
          inactiveData: inactiveRoomData,
        ),
      );
    } else {
      return;
    }
  }

  void _roomDashboardReset(
    RoomDashboardReset event,
    Emitter<RoomDashboardState> emit,
  ) {
    return emit(RoomDashboardInitial());
  }
}
