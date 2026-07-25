import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'friend_state.dart';

class FriendCubit extends Cubit<FriendState> {
  final AuthRepository repo;

  FriendCubit(this.repo) : super(FriendInitial());

  void fetchData() async {
    emit(FriendLoading());

    try {
      final List<UserModel> data = await repo.fetchFriend();

      return emit(FriendSuccess(data));
    } catch (e) {
      return emit(FriendFailure(e.toString()));
    }
  }

  void reset() {
    return emit(FriendInitial());
  }
}
