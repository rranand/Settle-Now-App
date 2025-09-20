import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/data/repository/room/each_room/room_repository.dart';
import 'package:settlenow/model/activity_model.dart';

part 'room_activity_state.dart';

class RoomActivityCubit extends Cubit<RoomActivityState> {
  final RoomRepository repo;
  RoomActivityCubit(this.repo) : super(RoomActivityInitial());

  void fetchData(
    String id,
    String authToken, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh &&
        state is RoomActivityLoading &&
        (state as RoomActivityLoading).id == id) {
      return;
    }
    emit(RoomActivityLoading(id));
    try {
      List<ActivityModel> data = await repo.fetchActivity(id, authToken);
      return emit(RoomActivitySuccess(id, data));
    } catch (e) {
      return emit(RoomActivityFailure(id, e.toString()));
    }
  }
}
