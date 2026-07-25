import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'user_update_profile_state.dart';

class UserUpdateProfileCubit extends Cubit<UserUpdateProfileState> {
  final AuthRepository repo;
  final AuthBloc authBloc;
  UserUpdateProfileCubit(this.repo, this.authBloc)
    : super(UserUpdateProfileState());

  void updateProfile(UserModel userData, PreferenceModel preferenceData) async {
    emit(UserUpdateProfileState(isLoading: true));
    try {
      await repo.updateProfile(userData);
      authBloc.add(AuthProfileUpdateRequested(userData, preferenceData));
      return emit(UserUpdateProfileState(isUpdated: true, error: null));
    } catch (e) {
      return emit(UserUpdateProfileState(error: e.toString()));
    }
  }

  void reset() {
    return emit(UserUpdateProfileState());
  }
}
