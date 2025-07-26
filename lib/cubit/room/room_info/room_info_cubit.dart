import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

part 'room_info_state.dart';

class RoomInfoCubit extends Cubit<RoomInfoState> {
  final RoomDashboardBloc _roomDashboardBloc;
  final RoomRepository repo;

  RoomInfoCubit(this._roomDashboardBloc, this.repo) : super(RoomInfoInitial());

  void fetchData(String id, String authToken) async {
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

      if (oldData.hasData) {
        return emit(RoomInfoSuccess(oldData));
      } else {
        RoomInfoModel data = await repo.fetchRoomInfo(id, authToken);
        return emit(RoomInfoSuccess(data));
      }
    } catch (e) {
      return emit(RoomInfoFailure(e.toString()));
    }
  }

  void updateUserData(String id, List<RoomUserModel> userData) {
    if (state is RoomInfoSuccess) {
      final oldState = (state as RoomInfoSuccess);

      if (oldState.data.id == id) {
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
                      ? "Partially Closed"
                      : "Open")
                  : "Closed",
          modifiedOn: DateTime.now(),
        );
        _roomDashboardBloc.add(RoomDashboardOnCloseRoom(data: updatedRoomInfo));
        return emit(RoomInfoSuccess(updatedRoomInfo));
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
        return emit(RoomInfoSuccess(updatedRoomInfo));
      }
    }

    return;
  }

  void reset() {
    return emit(RoomInfoInitial());
  }

  void updateRoomName(
    String authToken,
    String roomName,
    ScaffoldMessengerState scaffoldMessengerState,
  ) async {
    if (state is! RoomInfoSuccess) {
      return;
    }
    final oldData = state as RoomInfoSuccess;
    showSnackbarWithChildWidget(
      "Updating Name",
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
      ),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessengerState,
    );
    try {
      await repo.updateRoom(oldData.data.id, authToken, roomName);
      scaffoldMessengerState.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Room Name Updated",
        child: Icon(Iconsax.tick_circle5, color: Colors.green),
        scaffoldMessenger: scaffoldMessengerState,
      );
      RoomInfoModel updatedRoomInfo = oldData.data.copyWith(
        roomName: roomName,
        modifiedOn: DateTime.now(),
      );
      _roomDashboardBloc.add(RoomDashboardOnUpdateRoom(data: updatedRoomInfo));
      return emit(RoomInfoSuccess(updatedRoomInfo));
    } catch (e) {
      scaffoldMessengerState.hideCurrentSnackBar();
      emit(RoomInfoFailure(e.toString()));
      return emit(RoomInfoSuccess(oldData.data));
    }
  }
}
