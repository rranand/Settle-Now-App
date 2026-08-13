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

    List<ActivityModel> oldData = [];

    if (!forceRefresh && state is RoomActivitySuccess) {
      final oldState = state as RoomActivitySuccess;
      if (oldState.id == id) {
        if (!oldState.hasMoreData) {
          return;
        }

        oldData = [...(oldState.data)];
      }
    }

    emit(RoomActivityLoading(id: id));
    try {
      final pairedData = await repo.fetchActivity(
        id,
        oldData.isEmpty ? DateTime.now() : oldData.last.createdOn,
      );
      final data = pairedData.first;
      Map<String, List<ActivityModel>> transactionWiseActivity = {};

      for (int i = data.length - 1; i >= 0; i--) {
        switch (data[i].entityType) {
          case ActivityType.transactionAdded:
          case ActivityType.transactionUpdated:
          case ActivityType.settlementAdded:
          case ActivityType.settlementUpdated:
            {
              if (transactionWiseActivity.containsKey(data[i].entityId)) {
                transactionWiseActivity[data[i].entityId]!.add(data[i]);
              } else {
                transactionWiseActivity[data[i].entityId] = [data[i]];
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
          data: data,
          transactionWiseActivity: transactionWiseActivity,
          hasMoreData: pairedData.second,
        ),
      );
    } catch (e) {
      return emit(RoomActivityFailure(id: id, error: e.toString()));
    }
  }
}
