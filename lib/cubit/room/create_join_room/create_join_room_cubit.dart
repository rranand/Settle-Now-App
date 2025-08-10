import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/notification/notification_bloc.dart';
import 'package:settlenow_v2/bloc/room/dashboard/room_dashboard_bloc.dart';
import 'package:settlenow_v2/data/repository/room/dashboard/room_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/model/room_info_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/widgets/shimmer_effect.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

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
    String authToken,
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
      NotificationModel notificationData = await repo.joinRoom(
        roomKey,
        authToken,
      );
      notificationBloc.add(NotificationOnAdd(data: [notificationData]));
      scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "Room Join Requested",
        child: Icon(Iconsax.tick_circle_copy, color: Colors.green),
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
    List<UserModel> users,
    String authToken,
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
        authToken,
      );
      notificationBloc.add(NotificationOnAdd(data: notificationData));
      scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "${users.length} Members Invited",
        child: Icon(Iconsax.tick_circle_copy, color: Colors.green),
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
