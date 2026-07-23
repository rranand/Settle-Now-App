import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow/model/activity_model.dart';
import 'package:settlenow/util/enum/activity_type.dart';

part 'room_activity_state.dart';

class RoomActivityCubit extends Cubit<RoomActivityState> {
  final RoomRepository repo;
  RoomActivityCubit(this.repo) : super(RoomActivityInitial());

  void fetchData(
    String id,
     {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state is RoomActivityLoading &&
        (state as RoomActivityLoading).id == id) {
      return;
    }
    emit(RoomActivityLoading(id));
    try {
      List<ActivityModel> data = await repo.fetchActivity(id, );
      Map<String, List<ActivityModel>> transactionWiseActivity = {};

      for (int i = data.length - 1; i >= 0; i--) {
        switch (data[i].type) {
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
      return emit(RoomActivitySuccess(id, data, transactionWiseActivity));
    } catch (e) {
      return emit(RoomActivityFailure(id, e.toString()));
    }
  }
}
