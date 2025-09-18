import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/core.dart';
import 'package:settlenow/data/repository/auth_repository.dart';

part 'friend_state.dart';

class FriendCubit extends Cubit<FriendState> {
  final AuthRepository repo;

  FriendCubit(this.repo) : super(FriendInitial());

  void fetchLoginData(UserModel userdata) async {
    emit(FriendLoading());

    try {
      final List<UserModel> data = await repo.fetchFriend(userdata.authToken);

      return emit(FriendSuccess(data));
    } catch (e) {
      return emit(FriendFailure(e.toString()));
    }
  }

  void reset() {
    return emit(FriendInitial());
  }
}
