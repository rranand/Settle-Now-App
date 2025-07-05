import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/model/room_user_model.dart';

part 'room_info_state.dart';

class RoomInfoCubit extends Cubit<RoomInfoState> {
  final RoomDashboardBloc _roomDashboardBloc;
  final RoomRepository repo;

  RoomInfoCubit(this._roomDashboardBloc, this.repo) : super(RoomInfoInitial());

  void fetchData(String id, String authToken) async {
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

  void updateUserData(String id, List<RoomUserModel> userData) async {
    if (state is RoomInfoSuccess) {
      final oldState = (state as RoomInfoSuccess);

      if (oldState.data.id == id) {
        bool isActive = false;
        for (int i = 0; i < userData.length; i++) {
          isActive = isActive || userData[i].active;
        }

        RoomInfoModel updatedRoomInfo = oldState.data.copyWith(
          users: userData,
          active: isActive,
          status: isActive ? "Partially Closed" : "Closed",
        );
        _roomDashboardBloc.add(RoomDashboardOnCloseRoom(data: updatedRoomInfo));
        return emit(RoomInfoSuccess(updatedRoomInfo));
      }
    }

    return;
  }
}
