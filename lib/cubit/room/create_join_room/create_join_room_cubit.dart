import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'create_join_room_state.dart';

class CreateJoinRoomCubit extends Cubit<CreateJoinRoomState> {
  final RoomDashboardRepository repo;
  final RoomRepository roomRepo;
  final NotificationBloc notificationBloc;
  CreateJoinRoomCubit(this.repo, this.roomRepo, this.notificationBloc)
    : super(CreateJoinRoomInitial());

  void createNewRoom(BuildContext context, String roomName) async {
    final authLoginState = context.read<AuthBloc>().state;

    if (authLoginState is! AuthLoginSuccess) {
      return;
    }
    final roomDashboardCtx = context.read<RoomDashboardBloc>();

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
    String roomKey,

    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    showSnackbarWithChildWidget(
      "Joining Room",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessenger,
    );
    CreateJoinRoomLoading();
    try {
      NotificationModel notificationData = await repo.joinRoom(roomKey);
      notificationBloc.add(NotificationOnAdd(data: [notificationData]));
      scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Room Join Requested",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: scaffoldMessenger,
      );
      return emit(CreateJoinRoomSuccess());
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      return emit(CreateJoinRoomFailure(e.toString()));
    }
  }

  void inviteMember(
    String roomID,
    List<BaseUserModel> users,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    String message = "";
    if (users.isEmpty) {
      return;
    } else if (users.length == 1) {
      message = "Inviting ${users.first.name}";
    } else {
      message = "Inviting ${users.first.name}, +${users.length - 1} Others";
    }
    showSnackbarWithChildWidget(
      message,
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessenger,
    );
    CreateJoinRoomLoading();
    try {
      List<NotificationModel> notificationData = await roomRepo.inviteNewMember(
        roomID,
        users,
      );
      notificationBloc.add(NotificationOnAdd(data: notificationData));
      scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "${users.length} Members Invited",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: scaffoldMessenger,
      );
      return emit(CreateJoinRoomSuccess());
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      return emit(CreateJoinRoomFailure(e.toString()));
    }
  }

  void reset() {
    return emit(CreateJoinRoomInitial());
  }
}
