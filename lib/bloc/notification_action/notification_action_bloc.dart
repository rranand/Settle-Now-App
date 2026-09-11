import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/data/repository/repository_core.dart';
part 'notification_action_event.dart';
part 'notification_action_state.dart';

class NotificationActionBloc
    extends Bloc<NotificationActionEvent, NotificationActionState> {
  final NotificationBloc _notificationBloc;
  final NotificationRepository _notificationRepository;

  NotificationActionBloc(this._notificationBloc, this._notificationRepository)
    : super(NotificationActionState()) {
    on<NotificationActionAcceptRequested>(
      _notificationActionAcceptRequested,
      transformer: sequential(),
    );
    on<NotificationActionDeclineRequested>(
      _notificationActionDeclineRequested,
      transformer: sequential(),
    );
    on<NotificationActionReset>(
      _notificationActionReset,
      transformer: droppable(),
    );
  }

  void _notificationActionAcceptRequested(
    NotificationActionAcceptRequested event,
    Emitter<NotificationActionState> emit,
  ) async {
    if (state.processingNotification.contains(event.id)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.processingNotification);
    oldProcessingIDs.add(event.id);
    try {
      emit(
        state.copyWith(processingNotification: oldProcessingIDs, error: null),
      );
      await _notificationRepository.acceptInvite(event.id);
      oldProcessingIDs.remove(event.id);
      _notificationBloc.add(NotificationOnDelete(id: event.id));
      return emit(
        state.copyWith(processingNotification: oldProcessingIDs, error: null),
      );
    } catch (e) {
      oldProcessingIDs.remove(event.id);
      return emit(
        state.copyWith(
          processingNotification: oldProcessingIDs,
          error: e.toString(),
        ),
      );
    }
  }

  void _notificationActionDeclineRequested(
    NotificationActionDeclineRequested event,
    Emitter<NotificationActionState> emit,
  ) async {
    if (state.processingNotification.contains(event.id)) {
      return;
    }
    Set<String> oldProcessingIDs = Set.from(state.processingNotification);
    oldProcessingIDs.add(event.id);
    try {
      emit(
        state.copyWith(processingNotification: oldProcessingIDs, error: null),
      );
      await _notificationRepository.declineInvite(event.id);
      oldProcessingIDs.remove(event.id);
      _notificationBloc.add(NotificationOnDelete(id: event.id));
      return emit(
        state.copyWith(processingNotification: oldProcessingIDs, error: null),
      );
    } catch (e) {
      oldProcessingIDs.remove(event.id);
      return emit(
        state.copyWith(
          processingNotification: oldProcessingIDs,
          error: e.toString(),
        ),
      );
    }
  }

  void _notificationActionReset(
    NotificationActionReset event,
    Emitter<NotificationActionState> emit,
  ) {
    return emit(NotificationActionState());
  }
}
