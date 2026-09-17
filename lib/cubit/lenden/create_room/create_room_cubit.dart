import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'create_room_state.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  final LendenDashboardRepository _repo;
  final LendenRoomRepository _roomRepo;
  final NotificationBloc _notificationBloc;
  CreateRoomCubit(this._repo, this._roomRepo, this._notificationBloc)
    : super(CreateRoomInitial());

  void createNewRoom(BuildContext context, String roomName) async {
    final authLoginState = context.read<AuthBloc>().state;
    if (authLoginState is! AuthLoginSuccess) {
      return;
    }
    final lendenDashboardCtx = context.read<LendenDashboardBloc>();
    try {
      lendenDashboardCtx.add(
        LendenDashboardOnAddNewRoom(
          data: LendenDashboardModel.empty(),
          isLoading: true,
        ),
      );

      LendenDashboardModel newData = LendenDashboardModel(
        id: "",
        roomName: roomName,
        status: RoomStatus.open,
        createdBy: authLoginState.userData.id,
        createdOn: DateTime.now(),
        modifiedOn: DateTime.now(),
        users: [LendenUserModel.fromUserModel(authLoginState.userData)],
      );

      String newRoomId = await _repo.createRoom(newData);

      lendenDashboardCtx.add(
        LendenDashboardOnAddNewRoom(
          data: newData.copyWith(id: newRoomId),
          isLoading: false,
        ),
      );
      return emit(CreateRoomSuccess());
    } catch (e) {
      lendenDashboardCtx.add(
        LendenDashboardOnAddNewRoom(
          data: LendenDashboardModel.empty(),
          isLoading: false,
        ),
      );
      return emit(CreateRoomFailure(e.toString()));
    }
  }

  void inviteMember(
    String roomId,
    BaseUserModel user,
    String roomName,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    showSnackbarWithChildWidget(
      "Inviting ${user.name}",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: const Duration(seconds: 10),
      scaffoldMessenger: scaffoldMessenger,
    );

    try {
      NotificationModel notificationData = await _roomRepo.inviteUser(
        roomId,
        roomName,
        user.id,
      );
      _notificationBloc.add(NotificationOnAdd(data: [notificationData]));
      scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "${user.name} Invited",
        child: snackbarSuccessIcon(),
        scaffoldMessenger: scaffoldMessenger,
      );
      return emit(CreateRoomSuccess());
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      return emit(CreateRoomFailure(e.toString()));
    }
  }

  void reset() {
    return emit(CreateRoomInitial());
  }
}
