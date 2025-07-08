part of 'notification_action_bloc.dart';

class NotificationActionState {
  Set<String> processingNotification;
  String? error;

  NotificationActionState({this.processingNotification = const {}, this.error});

  NotificationActionState copyWith({
    Set<String>? processingNotification,
    String? error,
  }) {
    return NotificationActionState(
      processingNotification:
          processingNotification ?? this.processingNotification,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'NotificationActionState(NotificationIDs: $processingNotification)';
  }
}
