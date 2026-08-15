import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

part 'room_activity_state.dart';

class RoomActivityCubit extends Cubit<RoomActivityState> {
  final RoomRepository repo;
  RoomActivityCubit(this.repo) : super(RoomActivityInitial());

  void fetchData(String id, bool forceRefresh) async {
    if (state is RoomActivityLoading &&
        (state as RoomActivityLoading).id == id) {
      return;
    }

    RoomActivitySuccess? oldState;

    if (!forceRefresh && state is RoomActivitySuccess) {
      oldState = state as RoomActivitySuccess;
      if (oldState.id == id) {
        if (!oldState.hasMoreData) {
          return;
        }

        emit(oldState.copyWith(isLoadingMore: true, error: null));
      } else {
        oldState = null;
      }
    }

    if (oldState == null) {
      emit(RoomActivityLoading(id: id));
    }

    try {
      final data = await repo.fetchActivity(
        id,
        oldState?.data.isEmpty ?? true
            ? DateTime.now()
            : oldState!.data.last.createdOn,
      );

      List<ActivityModel> allRecords = <ActivityModel>[];
      allRecords.addAll(oldState?.data ?? <ActivityModel>[]);
      allRecords.addAll(data.first);

      LinkedHashMap<String, List<ActivityModel>> transactionWiseActivity =
          LinkedHashMap<String, List<ActivityModel>>.from(
            oldState?.transactionWiseActivity ??
                <String, List<ActivityModel>>{},
          );

      for (int i = 0; i < data.first.length; i++) {
        ActivityModel eachActivity = data.first[i];

        switch (eachActivity.entityType) {
          case ActivityType.transactionAdded:
          case ActivityType.transactionUpdated:
          case ActivityType.settlementAdded:
          case ActivityType.settlementUpdated:
            {
              if (transactionWiseActivity.containsKey(eachActivity.entityId)) {
                transactionWiseActivity[eachActivity.entityId]!.add(
                  eachActivity,
                );
              } else {
                transactionWiseActivity[eachActivity.entityId] = [eachActivity];
              }
              break;
            }
          default:
            {}
        }
      }
      return emit(
        RoomActivitySuccess(
          id: id,
          data: allRecords,
          transactionWiseActivity: transactionWiseActivity,
          hasMoreData: data.second,
        ),
      );
    } catch (e) {
      if (oldState == null) {
        return emit(RoomActivityFailure(id: id, error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, error: e.toString()),
        );
      }
    }
  }
}
