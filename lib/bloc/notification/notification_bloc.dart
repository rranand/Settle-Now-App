import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow_v2/model/notification_model.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<NotificationOnAdd>(_notificationOnAdd);
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
}
