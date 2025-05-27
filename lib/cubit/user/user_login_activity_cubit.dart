import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/bloc/auth/auth_bloc.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/model/login_activity_model.dart';
import 'package:settlenow_v2/model/user_model.dart';

part 'user_login_activity_state.dart';

class UserLoginActivityCubit extends Cubit<UserLoginActivityState> {
  final AuthRepository repo;
  UserLoginActivityCubit(this.repo) : super(UserLoginActivityInitial());

  void fetchLoginData(UserModel userdata) async {
    emit(UserLoginActivityLoading());

    try {
      final List<LoginActivityModel> data = await repo.fetchLoginActivity(
        userdata.authToken,
      );

      return emit(UserLoginActivitySuccess(data));
    } catch (e) {
      return emit(UserLoginActivityFailure(e.toString()));
    }
  }

  void logoutDevice(BuildContext context, String sessionID) async {
    final logInSuccessState =
        context.read<AuthBloc>().state as AuthLoginSuccess;
    final oldState = state as UserLoginActivitySuccess;
    List<LoginActivityModel> oldArr = [...oldState.data];
    try {
      for (int i = 0; i < oldArr.length; i++) {
        if (oldArr[i].id == sessionID) {
          oldArr[i].hasData = false;
          break;
        }
      }
      emit(UserLoginActivitySuccess(oldArr));
      await repo.logoutDifferentDevice(
        logInSuccessState.userData.authToken,
        sessionID,
      );
      oldArr.removeWhere((element) => element.id == sessionID);
      return emit(UserLoginActivitySuccess(oldArr));
    } catch (e) {
      for (int i = 0; i < oldArr.length; i++) {
        if (oldArr[i].id == sessionID) {
          oldArr[i].hasData = true;
          break;
        }
      }
      emit(UserLoginActivitySuccess(oldArr));
      return emit(UserLoginActivityFailure(e.toString()));
    }
  }
}
