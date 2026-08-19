import 'dart:collection';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repo;
  NotificationBloc(this.repo) : super(NotificationInitial()) {
    on<NotificationOnAdd>(_notificationOnAdd, transformer: sequential());
    on<NotificationOnDelete>(_notificationOnDelete, transformer: sequential());
    on<NotificationFetch>(_notificationFetch, transformer: droppable());
    on<NotificationUpdate>(_notificationUpdate, transformer: sequential());
    on<NotificationReset>(_notificationReset, transformer: droppable());
  }

  void _notificationFetch(
    NotificationFetch event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    try {
      List<NotificationModel> data = await repo.fetchData();
      final newData = LinkedHashMap<String, NotificationModel>.fromEntries(
        data.map((t) => MapEntry(t.id, t)),
      );
      return emit(NotificationFetchSuccess(data: newData));
    } catch (e) {
      return emit(NotificationFailure(error: e.toString()));
    }
  }

  void _notificationUpdate(
    NotificationUpdate event,
    Emitter<NotificationState> emit,
  ) {
    if (state is! NotificationFetchSuccess) {
      return;
    }

    final oldState = state as NotificationFetchSuccess;

    final oldData = oldState.dataList;

    LinkedHashMap<String, NotificationModel> updatedData =
        LinkedHashMap<String, NotificationModel>.fromEntries(
          oldData.map((t) {
            if (t.roomID == event.roomID) {
              return MapEntry(t.id, t.copyWith(roomName: event.roomName));
            }

            return MapEntry(t.id, t);
          }),
        );

    return emit(NotificationFetchSuccess(data: updatedData));
  }

  void _notificationOnAdd(
    NotificationOnAdd event,
    Emitter<NotificationState> emit,
  ) {
    LinkedHashMap<String, NotificationModel> data =
        LinkedHashMap<String, NotificationModel>.fromEntries(
          event.data.map((t) => MapEntry(t.id, t)),
        );

    if (state is NotificationFetchSuccess) {
      final oldState = state as NotificationFetchSuccess;
      data.addAll(oldState.data);
    }

    return emit(NotificationFetchSuccess(data: data));
  }

  void _notificationOnDelete(
    NotificationOnDelete event,
    Emitter<NotificationState> emit,
  ) {
    LinkedHashMap<String, NotificationModel> data = LinkedHashMap();

    if (state is NotificationFetchSuccess) {
      final oldState = state as NotificationFetchSuccess;
      data.addAll(oldState.data);
      data.remove(event.id);
    }

    return emit(NotificationFetchSuccess(data: data));
  }

  void _notificationReset(
    NotificationReset event,
    Emitter<NotificationState> emit,
  ) {
    return emit(NotificationInitial());
  }
}
