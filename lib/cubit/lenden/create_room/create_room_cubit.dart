import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/bloc/lenden/dashboard/lenden_dashboard_bloc.dart';
import 'package:settlenow_v2/data/repository/lenden/dashboard/lenden_dashboard_repository.dart';
import 'package:settlenow_v2/model/lenden_dashboard_model.dart';
import 'package:settlenow_v2/model/lenden_user_model.dart';

part 'create_room_state.dart';

class CreateRoomCubit extends Cubit<CreateRoomState> {
  final LendenDashboardRepository repo;
  CreateRoomCubit(this.repo) : super(CreateRoomInitial());

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

      LendenDashboardModel newData = await repo.createRoom(roomName);
      newData.users = [LendenUserModel.fromUserModel(authLoginState.userData)];
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
}
