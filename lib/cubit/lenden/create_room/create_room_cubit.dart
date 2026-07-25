import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'create_room_state.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  final LendenDashboardRepository repo;
  final LendenRoomRepository roomRepo;
  final NotificationBloc notificationBloc;
  CreateRoomCubit(this.repo, this.roomRepo, this.notificationBloc)
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
        status: "Open",
        createdBy: authLoginState.userData,
        createdOn: DateTime.now(),
        modifiedOn: DateTime.now(),
        amount: 0,
        users: [LendenUserModel.fromUserModel(authLoginState.userData)],
      );

      newData = await repo.createRoom(newData);

      lendenDashboardCtx.add(
        LendenDashboardOnAddNewRoom(data: newData, isLoading: false),
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
    String roomID,
    UserModel user,

    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    showSnackbarWithChildWidget(
      "Inviting ${user.name}",
      child: CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessenger,
    );

    try {
      NotificationModel notificationData = await roomRepo.inviteUser(
        roomID,
        user.id,
      );
      notificationBloc.add(NotificationOnAdd(data: [notificationData]));
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
