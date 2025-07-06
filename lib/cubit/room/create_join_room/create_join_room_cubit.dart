import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/data/repository/room/dashboard/room_dashboard_repository.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

part 'create_join_room_state.dart';

class CreateJoinRoomCubit extends Cubit<CreateJoinRoomState> {
  final RoomDashboardRepository repo;
  CreateJoinRoomCubit(this.repo) : super(CreateJoinRoomInitial());

  void createNewRoom(BuildContext context, String roomName) async {
    final roomDashboardCtx = context.read<RoomDashboardBloc>();
    final authLoginState = context.read<AuthBloc>().state as AuthLoginSuccess;
    try {
      roomDashboardCtx.add(
        RoomDashboardOnAddNewRoom(data: RoomInfoModel.empty(), isLoading: true),
      );

      RoomInfoModel newData = await repo.createRoom(
        roomName,
        authLoginState.userData,
      );

      roomDashboardCtx.add(
        RoomDashboardOnAddNewRoom(data: newData, isLoading: false),
      );
      return emit(CreateJoinRoomSuccess());
    } catch (e) {
      roomDashboardCtx.add(
        RoomDashboardOnAddNewRoom(
          data: RoomInfoModel.empty(),
          isLoading: false,
        ),
      );
      return emit(CreateJoinRoomFailure(e.toString()));
    }
  }

  void joinNewRoom(
    BuildContext context,
    String roomKey,
    String authToken,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    showSnackbarWithChildWidget(
      "Joining Room",
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
      ),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessenger,
    );
    CreateJoinRoomLoading();
    try {
      bool isRoomJoined = await repo.joinRoom(roomKey, authToken);
      if (isRoomJoined) {
        scaffoldMessenger.hideCurrentSnackBar();
        showSnackbarWithChildWidget(
          "Room Join Requested",
          child: Icon(Iconsax.tick_circle5, color: Colors.green),
          scaffoldMessenger: scaffoldMessenger,
        );
        return emit(CreateJoinRoomSuccess());
      } else {
        scaffoldMessenger.hideCurrentSnackBar();
        return emit(CreateJoinRoomFailure("Something went wrong!"));
      }
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      return emit(CreateJoinRoomFailure(e.toString()));
    }
  }
}
