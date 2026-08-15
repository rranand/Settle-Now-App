import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'room_dashboard_event.dart';
part 'room_dashboard_state.dart';

class RoomDashboardBloc extends Bloc<RoomDashboardEvent, RoomDashboardState> {
  final RoomDashboardRepository repo;

  RoomDashboardBloc(this.repo) : super(RoomDashboardInitial()) {
    on<RoomDashboardFetch>(_roomFetch, transformer: droppable());
    on<RoomDashboardOnAddNewRoom>(
      _roomDashboardOnAddNewRoom,
      transformer: sequential(),
    );
    on<RoomDashboardOnCloseRoom>(
      _roomDashboardOnCloseRoom,
      transformer: sequential(),
    );
    on<RoomDashboardReset>(_roomDashboardReset, transformer: droppable());
    on<RoomDashboardOnUpdateRoom>(
      _roomDashboardOnUpdateRoom,
      transformer: sequential(),
    );
    on<RoomDashboardOnDeleteRoom>(
      _roomDashboardOnDeleteRoom,
      transformer: sequential(),
    );
  }

  DateTime _getCursor(
    bool isFreshFetch,
    bool isActiveRoom,
    RoomDashboardFetchSuccess? oldState,
  ) {
    if (isFreshFetch || oldState == null) {
      return DateTime.now();
    }

    if (isActiveRoom) {
      if (oldState.activeRoomDashboardModel.dataList.isEmpty) {
        return DateTime.now();
      }
      return oldState.activeRoomDashboardModel.dataList.last.createdOn;
    } else {
      if (oldState.inactiveRoomDashboardModel.dataList.isEmpty) {
        return DateTime.now();
      }
      return oldState.inactiveRoomDashboardModel.dataList.last.createdOn;
    }
  }

  void _roomFetch(
    RoomDashboardFetch event,
    Emitter<RoomDashboardState> emit,
  ) async {
    RoomDashboardFetchSuccess? oldState;

    if (state is RoomDashboardFetchSuccess) {
      oldState = state as RoomDashboardFetchSuccess;
    }

    if (!event.isFreshFetch && oldState != null) {
      if (event.isActiveRoom) {
        if (!oldState.activeRoomDashboardModel.hasMoreData) {
          return;
        }

        final oldRoomDashboardModel = oldState.activeRoomDashboardModel
            .copyWith(isLoadingMore: true);

        emit(
          oldState.copyWith(
            activeRoomDashboardModel: oldRoomDashboardModel,
            error: null,
          ),
        );
      }
      if (!event.isActiveRoom) {
        if (!oldState.inactiveRoomDashboardModel.hasMoreData) {
          return;
        }

        final oldRoomDashboardModel = oldState.inactiveRoomDashboardModel
            .copyWith(isLoadingMore: true);

        emit(
          oldState.copyWith(
            inactiveRoomDashboardModel: oldRoomDashboardModel,
            error: null,
          ),
        );
      }
    } else {
      emit(RoomDashboardLoading());
    }

    try {
      Pair<List<RoomInfoModel>, bool> data = await repo.fetchData(
        event.isActiveRoom,
        _getCursor(event.isFreshFetch, event.isActiveRoom, oldState),
      );

      final newData = LinkedHashMap<String, RoomInfoModel>.fromEntries(
        data.first.map((t) => MapEntry(t.id, t)),
      );

      LinkedHashMap<String, RoomInfoModel> allRecords = LinkedHashMap();
      if (event.isActiveRoom) {
        allRecords.addAll(
          oldState?.activeRoomDashboardModel.data ?? <String, RoomInfoModel>{},
        );
      } else {
        allRecords.addAll(
          oldState?.inactiveRoomDashboardModel.data ??
              <String, RoomInfoModel>{},
        );
      }
      allRecords.addAll(newData);

      if (event.isActiveRoom) {
        return emit(
          RoomDashboardFetchSuccess(
            activeRoomDashboardModel: (oldState?.activeRoomDashboardModel ??
                    RoomDashboardModel(
                      data: LinkedHashMap(),
                      hasMoreData: true,
                      isLoadingMore: false,
                    ))
                .copyWith(
                  data: allRecords,
                  hasMoreData: data.second,
                  isLoadingMore: false,
                ),
            inactiveRoomDashboardModel:
                oldState?.inactiveRoomDashboardModel ??
                RoomDashboardModel(
                  data: LinkedHashMap(),
                  hasMoreData: true,
                  isLoadingMore: false,
                ),
          ),
        );
      } else {
        return emit(
          RoomDashboardFetchSuccess(
            activeRoomDashboardModel:
                (oldState?.activeRoomDashboardModel ??
                    RoomDashboardModel(
                      data: LinkedHashMap(),
                      hasMoreData: true,
                      isLoadingMore: false,
                    )),
            inactiveRoomDashboardModel: (oldState?.inactiveRoomDashboardModel ??
                    RoomDashboardModel(
                      data: LinkedHashMap(),
                      hasMoreData: true,
                      isLoadingMore: false,
                    ))
                .copyWith(
                  data: allRecords,
                  hasMoreData: data.second,
                  isLoadingMore: false,
                ),
          ),
        );
      }
    } catch (e) {
      if (oldState == null || event.isFreshFetch) {
        return emit(RoomDashboardFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(
            activeRoomDashboardModel: oldState.activeRoomDashboardModel
                .copyWith(isLoadingMore: false),
            inactiveRoomDashboardModel: oldState.inactiveRoomDashboardModel
                .copyWith(isLoadingMore: false),
            error: e.toString(),
          ),
        );
      }
    }
  }

  void _roomDashboardOnAddNewRoom(
    RoomDashboardOnAddNewRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    if (state is! RoomDashboardFetchSuccess) {
      return;
    }
    final oldState = (state as RoomDashboardFetchSuccess);
    LinkedHashMap<String, RoomInfoModel> data = LinkedHashMap();

    data.addAll({event.data.id: event.data});
    data.addAll(oldState.activeRoomDashboardModel.data);

    if (!event.isLoading) {
      data.remove("");
    }

    return emit(
      RoomDashboardFetchSuccess(
        activeRoomDashboardModel: oldState.activeRoomDashboardModel.copyWith(
          data: data,
        ),
        inactiveRoomDashboardModel: oldState.inactiveRoomDashboardModel,
      ),
    );
  }

  void _roomDashboardOnCloseRoom(
    RoomDashboardOnCloseRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    if (state is! RoomDashboardFetchSuccess) {
      return;
    }
    final oldState = (state as RoomDashboardFetchSuccess);
    LinkedHashMap<String, RoomInfoModel> activeRoomData =
        LinkedHashMap<String, RoomInfoModel>.from(
          oldState.activeRoomDashboardModel.data,
        );
    LinkedHashMap<String, RoomInfoModel> inactiveRoomData = LinkedHashMap();

    if (!event.data.active) {
      activeRoomData.remove(event.data.id);
      inactiveRoomData.addAll({event.data.id: event.data});
    } else {
      activeRoomData[event.data.id] = event.data;
    }

    inactiveRoomData.addAll(
      LinkedHashMap<String, RoomInfoModel>.from(
        oldState.inactiveRoomDashboardModel.data,
      ),
    );

    return emit(
      RoomDashboardFetchSuccess(
        activeRoomDashboardModel: oldState.activeRoomDashboardModel.copyWith(
          data: activeRoomData,
          isLoadingMore: false,
        ),
        inactiveRoomDashboardModel: oldState.inactiveRoomDashboardModel
            .copyWith(data: inactiveRoomData, isLoadingMore: false),
      ),
    );
  }

  void _roomDashboardOnUpdateRoom(
    RoomDashboardOnUpdateRoom event,
    Emitter<RoomDashboardState> emit,
  ) async {
    if (state is! RoomDashboardFetchSuccess) {
      return;
    }
    final oldState = (state as RoomDashboardFetchSuccess);

    LinkedHashMap<String, RoomInfoModel> activeRoomData =
        LinkedHashMap<String, RoomInfoModel>.from(
          oldState.activeRoomDashboardModel.data,
        );

    if (activeRoomData.containsKey(event.data.id)) {
      activeRoomData[event.data.id] = event.data;
    }

    return emit(
      RoomDashboardFetchSuccess(
        activeRoomDashboardModel: oldState.activeRoomDashboardModel.copyWith(
          data: activeRoomData,
          isLoadingMore: false,
        ),
        inactiveRoomDashboardModel: oldState.inactiveRoomDashboardModel,
      ),
    );
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
    final oldState = (state as RoomDashboardFetchSuccess);

    LinkedHashMap<String, RoomInfoModel> activeRoomData =
        LinkedHashMap<String, RoomInfoModel>.from(
          oldState.activeRoomDashboardModel.data,
        );

    activeRoomData.remove(event.id);

    return emit(
      RoomDashboardFetchSuccess(
        activeRoomDashboardModel: oldState.activeRoomDashboardModel.copyWith(
          data: activeRoomData,
          isLoadingMore: false,
        ),
        inactiveRoomDashboardModel: oldState.inactiveRoomDashboardModel,
      ),
    );
  }
}
