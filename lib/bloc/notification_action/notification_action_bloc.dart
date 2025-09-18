import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/notification/notification_bloc.dart';
import 'package:settlenow/data/repository/notification_repository.dart';

part 'notification_action_event.dart';
part 'notification_action_state.dart';

class NotificationActionBloc
    extends Bloc<NotificationActionEvent, NotificationActionState> {
  final NotificationBloc notificationBloc;
  final NotificationRepository notificationRepository;

  NotificationActionBloc(this.notificationBloc, this.notificationRepository)
    : super(NotificationActionState()) {
    on<NotificationActionAcceptRequested>(_notificationActionAcceptRequested);
    on<NotificationActionDeclineRequested>(_notificationActionDeclineRequested);
    on<NotificationActionReset>(_notificationActionReset);
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
      await notificationRepository.acceptInvite(event.id, event.authToken);
      oldProcessingIDs.remove(event.id);
      notificationBloc.add(NotificationOnDelete(id: event.id));
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
      await notificationRepository.declineInvite(event.id, event.authToken);
      oldProcessingIDs.remove(event.id);
      notificationBloc.add(NotificationOnDelete(id: event.id));
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
