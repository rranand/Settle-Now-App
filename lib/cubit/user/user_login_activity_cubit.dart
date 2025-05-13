import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        userdata.id,
        "",
      );

      return emit(UserLoginActivitySuccess(data));
    } catch (e) {
      return emit(UserLoginActivityFailure(e.toString()));
    }
  }
}
