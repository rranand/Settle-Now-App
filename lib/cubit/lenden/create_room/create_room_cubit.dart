import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/bloc/notification/notification_bloc.dart';
import 'package:settlenow_v2/data/repository/lenden/dashboard/lenden_dashboard_repository.dart';
import 'package:settlenow_v2/data/repository/lenden/room/lenden_room_repository.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/model/lenden_user_model.dart';
import 'package:settlenow_v2/model/notification_model.dart';
import 'package:settlenow_v2/model/user_model.dart';
import 'package:settlenow_v2/util/widgets/snackbar.dart';

part 'create_room_state.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  final LendenDashboardRepository repo;
  final LendenRoomRepository roomRepo;
  final NotificationBloc notificationBloc;
  CreateRoomCubit(this.repo, this.roomRepo, this.notificationBloc)
    : super(CreateRoomInitial());

  void createNewRoom(BuildContext context, String roomName) async {
    final lendenDashboardCtx = context.read<LendenDashboardBloc>();
    final authLoginState = context.read<AuthBloc>().state as AuthLoginSuccess;
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

      newData = await repo.createRoom(
        newData,
        authLoginState.userData.authToken,
      );

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
    String authToken,
    ScaffoldMessengerState scaffoldMessenger,
  ) async {
    showSnackbarWithChildWidget(
      "Inviting ${user.name}",
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
      ),
      duration: Duration(minutes: 2),
      scaffoldMessenger: scaffoldMessenger,
    );
    CreateRoomLoading();
    try {
      NotificationModel notificationData = await roomRepo.inviteUser(
        roomID,
        user.id,
        authToken,
      );
      notificationBloc.add(NotificationOnAdd(data: [notificationData]));
      scaffoldMessenger.hideCurrentSnackBar();
      showSnackbarWithChildWidget(
        "${user.name} Invited",
        child: Icon(Iconsax.tick_circle5, color: Colors.green),
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
