part of 'notification_action_bloc.dart';

class NotificationActionState {
  Set<String> processingNotification;

  NotificationActionState({this.processingNotification = const {}});

  NotificationActionState copyWith({Set<String>? processingNotification}) {
    return NotificationActionState(
      processingNotification:
          processingNotification ?? this.processingNotification,
    );
  }

  @override
  String toString() {
    return 'NotificationActionState(NotificationIDs: $processingNotification)';
  }
}
