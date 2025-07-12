import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/data/repository/notification_repository.dart';
import 'package:settlenow_v2/model/notification_model.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repo;
  NotificationBloc(this.repo) : super(NotificationInitial()) {
    on<NotificationOnAdd>(_notificationOnAdd);
    on<NotificationOnDelete>(_notificationOnDelete);
    on<NotificationFetch>(_notificationFetch);
    on<NotificationReset>(_notificationReset);
  }

  void _notificationFetch(
    NotificationFetch event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoading) return;
    emit(NotificationLoading());
    try {
      List<NotificationModel> data = await repo.fetchData(event.authToken);
      return emit(NotificationFetchSuccess(data));
    } catch (e) {
      return emit(NotificationFailure(e.toString()));
    }
  }

  void _notificationOnAdd(
    NotificationOnAdd event,
    Emitter<NotificationState> emit,
  ) {
    List<NotificationModel> data = [event.data];
    if (state is NotificationFetchSuccess) {
      final oldState = state as NotificationFetchSuccess;
      data.addAll(oldState.data);
    }
    return emit(NotificationFetchSuccess(data));
  }

  void _notificationOnDelete(
    NotificationOnDelete event,
    Emitter<NotificationState> emit,
  ) {
    List<NotificationModel> data = [];
    if (state is NotificationFetchSuccess) {
      final oldState = state as NotificationFetchSuccess;
      data.addAll(oldState.data);

      data.removeWhere((ele) => ele.id == event.id);
    }
    return emit(NotificationFetchSuccess(data));
  }

  void _notificationReset(
    NotificationReset event,
    Emitter<NotificationState> emit,
  ) {
    return emit(NotificationInitial());
  }
}
