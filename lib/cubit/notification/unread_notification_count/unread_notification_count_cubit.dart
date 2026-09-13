import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/repository_core.dart';

part 'unread_notification_count_state.dart';

class UnreadNotificationCountCubit extends Cubit<UnreadNotificationCountState> {
  final NotificationRepository _repo;

  UnreadNotificationCountCubit(this._repo)
    : super(UnreadNotificationCountInitial());

  void fetchUnreadNotificationCount() async {
    emit(UnreadNotificationCountLoading());

    try {
      final count = await _repo.unreadActivityNotificationCount();
      emit(UnreadNotificationCountSuccess(count: count));
    } catch (e) {
      emit(UnreadNotificationCountFailure(error: e.toString()));
    }
  }

  void updateUnreadNotificationCount(int delta, {bool resetToZero = false}) {
    if (state is UnreadNotificationCountSuccess) {
      final oldState = state as UnreadNotificationCountSuccess;
      int newCount =
          resetToZero || oldState.count <= delta ? 0 : oldState.count - delta;
      emit(UnreadNotificationCountSuccess(count: newCount));
    }
  }

  void reset() {
    emit(UnreadNotificationCountInitial());
  }
}
