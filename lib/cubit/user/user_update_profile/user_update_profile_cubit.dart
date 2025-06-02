import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/data/repository/auth_repository.dart';
import 'package:settlenow_v2/model/user_model.dart';

part 'user_update_profile_state.dart';

class UserUpdateProfileCubit extends Cubit<UserUpdateProfileState> {
  final AuthRepository repo;
  UserUpdateProfileCubit(this.repo) : super(UserUpdateProfileState());

  void updateProfile(UserModel userData) async {
    emit(UserUpdateProfileState(isLoading: true));
    try {
      await repo.updateProfile(userData);
      return emit(UserUpdateProfileState(isUpdated: true));
    } catch (e) {
      return emit(UserUpdateProfileState(error: e.toString()));
    }
  }
}
