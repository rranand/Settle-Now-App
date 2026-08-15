import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:settlenow/data/repository/repository_core.dart';
import 'package:settlenow/model/model_core.dart';

part 'lenden_dashboard_event.dart';
part 'lenden_dashboard_state.dart';

class LendenDashboardBloc
    extends Bloc<LendenDashboardEvent, LendenDashboardState> {
  final LendenDashboardRepository repo;

  LendenDashboardBloc(this.repo) : super(LendenDashboardInitial()) {
    on<LendenDashboardFetch>(_lendenDashboardFetch, transformer: droppable());
    on<LendenDashboardOnAddNewRoom>(
      _lendenDashboardOnAddNewRoom,
      transformer: sequential(),
    );
    on<LendenDashboardOnUpdateRoom>(
      _lendenDashboardOnUpdateRoom,
      transformer: sequential(),
    );
    on<LendenDashboardReset>(_lendenDashboardReset, transformer: droppable());
    on<LendenDashboardOnDeleteRoom>(
      _lendenDashboardOnDeleteRoom,
      transformer: droppable(),
    );
  }

  void _lendenDashboardFetch(
    LendenDashboardFetch event,
    Emitter<LendenDashboardState> emit,
  ) async {
    LendenDashboardFetchSuccess? oldState;

    if (!event.isFreshFetch && state is LendenDashboardFetchSuccess) {
      oldState = state as LendenDashboardFetchSuccess;
      if (!oldState.hasMoreData) {
        return;
      }

      emit(oldState.copyWith(isLoadingMore: true, toastMessage: null));
    } else {
      emit(LendenDashboardLoading());
    }

    try {
      final data = await repo.fetchData(
        oldState == null || oldState.dataList.isEmpty
            ? DateTime.now()
            : oldState.dataList.last.createdOn,
      );

      final newData = LinkedHashMap<String, LendenDashboardModel>.fromEntries(
        data.first.map((t) => MapEntry(t.id, t)),
      );

      LinkedHashMap<String, LendenDashboardModel> allRecords = LinkedHashMap();
      allRecords.addAll(oldState?.data ?? <String, LendenDashboardModel>{});
      allRecords.addAll(newData);

      return emit(
        LendenDashboardFetchSuccess(data: allRecords, hasMoreData: data.second),
      );
    } catch (e) {
      if (oldState == null) {
        return emit(LendenDashboardFailure(error: e.toString()));
      } else {
        return emit(
          oldState.copyWith(isLoadingMore: false, toastMessage: e.toString()),
        );
      }
    }
  }

  void _lendenDashboardOnAddNewRoom(
    LendenDashboardOnAddNewRoom event,
    Emitter<LendenDashboardState> emit,
  ) async {
    if (state is! LendenDashboardFetchSuccess) {
      return;
    }
    final oldState = (state as LendenDashboardFetchSuccess);
    LinkedHashMap<String, LendenDashboardModel> data = LinkedHashMap();

    data.addAll({event.data.id: event.data});
    data.addAll(oldState.data);

    if (!event.isLoading) {
      data.remove("");
    }

    return emit(
      LendenDashboardFetchSuccess(
        data: data,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _lendenDashboardOnUpdateRoom(
    LendenDashboardOnUpdateRoom event,
    Emitter<LendenDashboardState> emit,
  ) async {
    if (state is! LendenDashboardFetchSuccess) {
      return;
    }

    final oldState = (state as LendenDashboardFetchSuccess);

    final updated = LinkedHashMap<String, LendenDashboardModel>.from(
      oldState.data,
    )..[event.data.id] = event.data;

    return emit(
      LendenDashboardFetchSuccess(
        data: updated,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _lendenDashboardOnDeleteRoom(
    LendenDashboardOnDeleteRoom event,
    Emitter<LendenDashboardState> emit,
  ) async {
    if (state is! LendenDashboardFetchSuccess) {
      return;
    }

    final oldState = (state as LendenDashboardFetchSuccess);

    final updated = LinkedHashMap<String, LendenDashboardModel>.from(
      oldState.data,
    )..remove(event.id);

    return emit(
      LendenDashboardFetchSuccess(
        data: updated,
        hasMoreData: oldState.hasMoreData,
      ),
    );
  }

  void _lendenDashboardReset(
    LendenDashboardReset event,
    Emitter<LendenDashboardState> emit,
  ) {
    return emit(LendenDashboardInitial());
  }
}
