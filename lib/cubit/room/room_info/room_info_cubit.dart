import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'room_info_state.dart';

class RoomInfoCubit extends Cubit<RoomInfoState> {
  final RoomDashboardBloc _roomDashboardBloc;
  final RoomRepository repo;

  RoomInfoCubit(this._roomDashboardBloc, this.repo) : super(RoomInfoInitial());

  Future<void> fetchData(String id, {bool forceRefresh = false}) async {
    if (state is RoomInfoLoading) return;
    emit(RoomInfoLoading());
    try {
      final roomDashboardState = _roomDashboardBloc.state;
      RoomInfoModel oldData = RoomInfoModel.empty();
      if (roomDashboardState is RoomDashboardFetchSuccess) {
        final List<RoomInfoModel> oldArr = [
          ...roomDashboardState.activeData,
          ...roomDashboardState.inactiveData,
        ];

        oldData = oldArr.firstWhere(
          (ele) => ele.id == id,
          orElse: () => RoomInfoModel.empty(),
        );
      }

      if (oldData.hasData && !forceRefresh) {
        return emit(RoomInfoSuccess(oldData, false));
      } else {
        RoomInfoModel data = await repo.fetchRoomInfo(id);
        return emit(RoomInfoSuccess(data, false));
      }
    } catch (e) {
      return emit(RoomInfoFailure(e.toString()));
    }
  }

  void updateUserData(
    String id,
    List<RoomUserModel> userData, {
    bool forceUpdate = false,
  }) {
    if (state is RoomInfoSuccess) {
      final oldState = (state as RoomInfoSuccess);

      if (forceUpdate ||
          (oldState.data.id == id &&
              !listEquals(oldState.data.users, userData))) {
        int activeUserCount = 0;
        for (int i = 0; i < userData.length; i++) {
          if (userData[i].active) {
            activeUserCount++;
          }
        }

        RoomInfoModel updatedRoomInfo = oldState.data.copyWith(
          users: userData,
          active: activeUserCount > 0,
          status:
              activeUserCount > 0
                  ? (activeUserCount != userData.length
                      ? RoomStatus.partiallyClosed
                      : RoomStatus.open)
                  : RoomStatus.closed,
          modifiedOn: DateTime.now(),
        );
        _roomDashboardBloc.add(RoomDashboardOnCloseRoom(data: updatedRoomInfo));
        return emit(RoomInfoSuccess(updatedRoomInfo, true));
      }
    }

    return;
  }

  void updateRoomData(String id) {
    if (state is RoomInfoSuccess) {
      final oldState = (state as RoomInfoSuccess);

      if (oldState.data.id == id) {
        RoomInfoModel updatedRoomInfo = oldState.data.copyWith(
          modifiedOn: DateTime.now(),
        );
        _roomDashboardBloc.add(
          RoomDashboardOnUpdateRoom(data: updatedRoomInfo),
        );
        return emit(RoomInfoSuccess(updatedRoomInfo, true));
      }
    }

    return;
  }

  void reset() {
    return emit(RoomInfoInitial());
  }

  void updateRoomName(
    String roomName,
    ScaffoldMessengerState scaffoldMessengerState,
  ) async {
    if (state is! RoomInfoSuccess) {
      return;
    }
    final oldData = state as RoomInfoSuccess;
    showSnackbarWithChildWidget(
      "Updating Name",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessengerState,
    );
    try {
      await repo.updateRoom(oldData.data.id, roomName);
      scaffoldMessengerState.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Room Name Updated",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: scaffoldMessengerState,
      );
      RoomInfoModel updatedRoomInfo = oldData.data.copyWith(
        name: roomName,
        modifiedOn: DateTime.now(),
      );
      _roomDashboardBloc.add(RoomDashboardOnUpdateRoom(data: updatedRoomInfo));
      return emit(RoomInfoSuccess(updatedRoomInfo, true));
    } catch (e) {
      scaffoldMessengerState.hideCurrentSnackBar();
      emit(RoomInfoFailure(e.toString()));
      return emit(RoomInfoSuccess(oldData.data, true));
    }
  }

  void deleteRoom(
    String id,

    bool isRemoving,
    ScaffoldMessengerState scaffoldMessengerState,
  ) async {
    if (state is! RoomInfoSuccess) {
      return;
    }
    final oldData = state as RoomInfoSuccess;

    if (oldData.data.id != id) {
      return;
    }

    showSnackbarWithChildWidget(
      isRemoving ? "Leaving Room" : "Deleting Room",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessengerState,
    );
    try {
      await repo.deleteRoom(id);
      _roomDashboardBloc.add(RoomDashboardOnDeleteRoom(id: id));
      scaffoldMessengerState.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        isRemoving ? "You’ve left the room" : "Room deleted successfully",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: scaffoldMessengerState,
      );
      return emit(RoomInfoInitial());
    } catch (e) {
      scaffoldMessengerState.hideCurrentSnackBar();
      emit(RoomInfoFailure(e.toString()));
      return emit(RoomInfoSuccess(oldData.data, true));
    }
  }
}
