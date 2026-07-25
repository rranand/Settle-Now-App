import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'room_dashboard_event.dart';
part 'room_dashboard_state.dart';

class RoomDashboardBloc extends Bloc<RoomDashboardEvent, RoomDashboardState> {
  final RoomDashboardRepository repo;

  RoomDashboardBloc(this.repo) : super(RoomDashboardInitial()) {
    on<RoomDashboardFetch>(_roomFetch);
    on<RoomDashboardOnAddNewRoom>(_roomDashboardOnAddNewRoom);
    on<RoomDashboardOnCloseRoom>(_roomDashboardOnCloseRoom);
    on<RoomDashboardReset>(_roomDashboardReset);
    on<RoomDashboardOnUpdateRoom>(_roomDashboardOnUpdateRoom);
    on<RoomDashboardOnDeleteRoom>(_roomDashboardOnDeleteRoom);
  }

  void _roomFetch(
    RoomDashboardFetch event,
    Emitter<RoomDashboardState> emit,
  ) async {
    if (state is RoomDashboardLoading) return;

    List<RoomInfoModel> oldRoomActiveData = [];
    List<RoomInfoModel> oldRoomInActiveData = [];
    bool activeHasMoreData = false;
    bool inactiveHasMoreData = false;

    if (state is RoomDashboardFetchSuccess) {
      final oldState = state as RoomDashboardFetchSuccess;
      oldRoomActiveData = oldState.activeData;
      oldRoomInActiveData = oldState.inactiveData;
      activeHasMoreData = oldState.activeHasMoreData;
      inactiveHasMoreData = oldState.inactiveHasMoreData;

      if (!event.isFreshFetch &&
          ((event.isActiveRoom && !activeHasMoreData) ||
              (!event.isActiveRoom && !inactiveHasMoreData))) {
        return emit(
          RoomDashboardFetchSuccess(
            activeHasMoreData: activeHasMoreData,
            inactiveHasMoreData: inactiveHasMoreData,
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
        event.isFreshFetch
            ? 0
            : (event.isActiveRoom
                ? oldRoomActiveData.length
                : oldRoomInActiveData.length),
      );
      if (event.isActiveRoom) {
        if (event.isFreshFetch) {
          emit(
            RoomDashboardFetchSuccess(
              activeHasMoreData: data.second,
              inactiveHasMoreData: inactiveHasMoreData,
              activeData: data.first,
              inactiveData: oldRoomInActiveData,
            ),
          );
        } else {
          return emit(
            RoomDashboardFetchSuccess(
              activeHasMoreData: data.second,
              inactiveHasMoreData: inactiveHasMoreData,
              activeData: [...oldRoomActiveData, ...data.first],
              inactiveData: oldRoomInActiveData,
            ),
          );
        }
      } else {
        if (event.isFreshFetch) {
          return emit(
            RoomDashboardFetchSuccess(
              activeHasMoreData: activeHasMoreData,
              inactiveHasMoreData: data.second,
              activeData: oldRoomActiveData,
              inactiveData: data.first,
            ),
          );
        } else {
          return emit(
            RoomDashboardFetchSuccess(
              activeHasMoreData: activeHasMoreData,
              inactiveHasMoreData: data.second,
              activeData: oldRoomActiveData,
              inactiveData: [...oldRoomInActiveData, ...data.first],
            ),
          );
        }
      }
    } catch (e) {
      emit(RoomDashboardFailure(e.toString()));
      return emit(
        RoomDashboardFetchSuccess(
          activeHasMoreData: activeHasMoreData,
          inactiveHasMoreData: inactiveHasMoreData,
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
    if (state is! RoomDashboardFetchSuccess) {
      return;
    }
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
        activeHasMoreData: allRoomState.activeHasMoreData,
        inactiveHasMoreData: allRoomState.inactiveHasMoreData,
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
          activeHasMoreData: allRoomState.activeHasMoreData,
          inactiveHasMoreData: allRoomState.inactiveHasMoreData,
          activeData: activeRoomData,
          inactiveData: inactiveRoomData,
        ),
      );
    } else {
      return;
    }
  }

  void _roomDashboardOnUpdateRoom(
    RoomDashboardOnUpdateRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    if (state is RoomDashboardFetchSuccess) {
      final allRoomState = (state as RoomDashboardFetchSuccess);
      List<RoomInfoModel> activeRoomData = [...allRoomState.activeData];

      for (int i = 0; i < activeRoomData.length; i++) {
        if (allRoomState.activeData[i].id == event.data.id) {
          activeRoomData[i] = event.data;
          break;
        }
      }
      return emit(
        RoomDashboardFetchSuccess(
          activeHasMoreData: allRoomState.activeHasMoreData,
          inactiveHasMoreData: allRoomState.inactiveHasMoreData,
          activeData: activeRoomData,
          inactiveData: allRoomState.inactiveData,
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

  void _roomDashboardOnDeleteRoom(
    RoomDashboardOnDeleteRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    if (state is! RoomDashboardFetchSuccess) {
      return;
    }
    final allRoomState = (state as RoomDashboardFetchSuccess);
    List<RoomInfoModel> data = [...allRoomState.activeData];

    data.removeWhere((ele) => ele.id == event.id);

    return emit(
      RoomDashboardFetchSuccess(
        activeHasMoreData: allRoomState.activeHasMoreData,
        inactiveHasMoreData: allRoomState.inactiveHasMoreData,
        activeData: data,
        inactiveData: allRoomState.inactiveData,
      ),
    );
  }
}
