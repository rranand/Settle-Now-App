import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'friend_state.dart';

class FriendCubit extends Cubit<FriendState> {
  final AuthRepository _repo;

  FriendCubit(this._repo) : super(FriendInitial());

  void fetchData() async {
    emit(FriendLoading());

    try {
      final data = await _repo.fetchFriend();
      return emit(FriendSuccess(data: data));
    } catch (e) {
      return emit(FriendFailure(error: e.toString()));
    }
  }

  void addFriendFromCache() {
    final friends = UserResolver.instance.getFriends();
    emit(FriendSuccess(data: friends));
  }

  void reset() {
    return emit(FriendInitial());
  }
}
