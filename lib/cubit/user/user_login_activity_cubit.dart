import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';

part 'user_login_activity_state.dart';

class UserLoginActivityCubit extends Cubit<UserLoginActivityState> {
  final AuthRepository repo;
  UserLoginActivityCubit(this.repo) : super(UserLoginActivityDataState());

  void fetchLoginData(UserModel userdata) async {
    emit(UserLoginActivityDataState(isLoading: true));

    try {
      final List<LoginActivityModel> data = await repo.fetchLoginActivity(
        userdata.authToken,
      );

      return emit(UserLoginActivityDataState(data: data));
    } catch (e) {
      return emit(
        UserLoginActivityDataState(
          isLoading: false,
          data: [],
          error: e.toString(),
        ),
      );
    }
  }

  void logoutDevice(BuildContext context, String sessionID) async {
    final logInSuccessState =
        context.read<AuthBloc>().state as AuthLoginSuccess;
    final oldState = state as UserLoginActivityDataState;
    List<LoginActivityModel> oldArr = [...oldState.data];
    try {
      for (int i = 0; i < oldArr.length; i++) {
        if (oldArr[i].id == sessionID) {
          oldArr[i].hasData = false;
          break;
        }
      }
      emit(UserLoginActivityDataState(data: oldArr));
      await repo.logoutDifferentDevice(
        logInSuccessState.userData.authToken,
        sessionID,
      );
      oldArr.removeWhere((element) => element.id == sessionID);
      return emit(UserLoginActivityDataState(data: oldArr));
    } catch (e) {
      for (int i = 0; i < oldArr.length; i++) {
        if (oldArr[i].id == sessionID) {
          oldArr[i].hasData = true;
          break;
        }
      }
      return emit(
        UserLoginActivityDataState(data: oldArr, error: e.toString()),
      );
    }
  }
}
