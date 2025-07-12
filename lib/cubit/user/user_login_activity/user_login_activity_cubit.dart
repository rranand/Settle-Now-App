import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';

part 'user_login_activity_state.dart';

class UserLoginActivityCubit extends Cubit<UserLoginActivityState> {
  final AuthRepository repo;
  UserLoginActivityCubit(this.repo) : super(UserLoginActivityState());

  void fetchLoginData(UserModel userdata) async {
    if (state.isLoading == true) return;
    emit(UserLoginActivityState(isLoading: true));

    try {
      final List<LoginActivityModel> data = await repo.fetchLoginActivity(
        userdata.authToken,
      );

      return emit(UserLoginActivityState(data: data));
    } catch (e) {
      return emit(
        UserLoginActivityState(isLoading: false, data: [], error: e.toString()),
      );
    }
  }

  void logoutDevice(BuildContext context, String sessionID) async {
    final logInSuccessState =
        context.read<AuthBloc>().state as AuthLoginSuccess;
    List<LoginActivityModel> oldArr = [...state.data];
    try {
      for (int i = 0; i < oldArr.length; i++) {
        if (oldArr[i].id == sessionID) {
          oldArr[i].hasData = false;
          break;
        }
      }
      emit(UserLoginActivityState(data: oldArr));
      await repo.logoutDifferentDevice(
        logInSuccessState.userData.authToken,
        sessionID,
      );
      oldArr.removeWhere((element) => element.id == sessionID);
      return emit(UserLoginActivityState(data: oldArr));
    } catch (e) {
      for (int i = 0; i < oldArr.length; i++) {
        if (oldArr[i].id == sessionID) {
          oldArr[i].hasData = true;
          break;
        }
      }
      return emit(UserLoginActivityState(data: oldArr, error: e.toString()));
    }
  }

  void reset() {
    return emit(UserLoginActivityState());
  }
}
