import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:settlenow/cubit/cubit_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/notification/activity_notification_model.dart';
import 'package:settlenow/util/util_core.dart';

part 'activity_notification_event.dart';
part 'activity_notification_state.dart';

class ActivityNotificationBloc
    extends Bloc<ActivityNotificationEvent, ActivityNotificationState> {
  final NotificationRepository _repo;
  final UnreadNotificationCountCubit unreadNotificationCountCubit;

  ActivityNotificationBloc(this._repo, this.unreadNotificationCountCubit)
    : super(ActivityNotificationInitial()) {
    on<ActivityNotificationFetch>(
      _activityNotificationFetch,
      transformer: droppable(),
    );
    on<ActivityNotificationMarkAsRead>(
      _activityNotificationMarkAsRead,
      transformer: sequential(),
    );
    on<ActivityNotificationMarkAllAsRead>(
      _activityNotificationMarkAllAsRead,
      transformer: droppable(),
    );
    on<ActivityNotificationReset>(
      _activityNotificationReset,
      transformer: droppable(),
    );
  }

  void _activityNotificationFetch(
    ActivityNotificationFetch event,
    Emitter<ActivityNotificationState> emit,
  ) async {
    ActivityNotificationFetchSuccess? oldState;

    if (!event.isFreshFetch && state is ActivityNotificationFetchSuccess) {
      oldState = state as ActivityNotificationFetchSuccess;
      if (!oldState.hasMoreData) {
        return;
      }

      emit(oldState.copyWith(isLoadingMore: true, error: null));
    } else {
      emit(ActivityNotificationLoading());
    }

    try {
      final data = await _repo.fetchActivityBasedNotifications(
        oldState == null || oldState.dataList.isEmpty
            ? DateTime.now()
            : oldState.dataList.last.createdOn,
      );

      final newData =
          LinkedHashMap<String, ActivityNotificationModel>.fromEntries(
            data.first.map((t) => MapEntry(t.id, t)),
          );

      LinkedHashMap<String, ActivityNotificationModel> allRecords =
          LinkedHashMap();
      allRecords.addAll(
        oldState?.data ?? <String, ActivityNotificationModel>{},
      );
      allRecords.addAll(newData);

      return emit(
        ActivityNotificationFetchSuccess(
          data: allRecords,
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      if (oldState == null || event.isFreshFetch) {
        return emit(ActivityNotificationFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, error: e.toString()),
        );
      }
    }
  }

  void _activityNotificationMarkAsRead(
    ActivityNotificationMarkAsRead event,
    Emitter<ActivityNotificationState> emit,
  ) async {
    if (state is ActivityNotificationFetchSuccess) {
      try {
        await _repo.markAsRead(event.ids.toList());

        final oldState = state as ActivityNotificationFetchSuccess;
        DateTime currentTime = DateTime.now();

        final updatedDataMap =
            LinkedHashMap<String, ActivityNotificationModel>.fromEntries(
              oldState.dataList.map(
                (t) => MapEntry(
                  t.id,
                  event.ids.contains(t.id)
                      ? t.copyWith(readOn: currentTime)
                      : t,
                ),
              ),
            );

        unreadNotificationCountCubit.updateUnreadNotificationCount(false);
        return emit(oldState.copyWith(data: updatedDataMap));
      } catch (e) {
        logDebug("Failed to mark notifications as read: ${e.toString()}");
      }
    }
  }

  void _activityNotificationMarkAllAsRead(
    ActivityNotificationMarkAllAsRead event,
    Emitter<ActivityNotificationState> emit,
  ) async {
    if (state is ActivityNotificationFetchSuccess) {
      try {
        showSnackbarWithChildWidget(
          "Marking all notifications as read",
          child:
              CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
          duration: Duration(seconds: 10),
          scaffoldMessenger: event.scaffoldMessenger,
        );

        await _repo.markAllAsRead();

        event.scaffoldMessenger.hideCurrentSnackBar();
        DateTime currentTime = DateTime.now();
        final oldState = state as ActivityNotificationFetchSuccess;

        final updatedDataMap =
            LinkedHashMap<String, ActivityNotificationModel>.fromEntries(
              oldState.dataList.map(
                (t) => MapEntry(t.id, t.copyWith(readOn: currentTime)),
              ),
            );

        unreadNotificationCountCubit.updateUnreadNotificationCount(true);
        return emit(oldState.copyWith(data: updatedDataMap));
      } catch (e) {
        showSnackbarWithChildWidget(
          "Failed to mark all notifications as read",
          child:
              CustomShimmerEffect.shimmerCircularProgressIndicatorForSnackbar(),
          duration: Duration(seconds: 10),
          scaffoldMessenger: event.scaffoldMessenger,
        );
      }
    }
  }

  void _activityNotificationReset(
    ActivityNotificationReset event,
    Emitter<ActivityNotificationState> emit,
  ) async {
    return emit(ActivityNotificationInitial());
  }
}
