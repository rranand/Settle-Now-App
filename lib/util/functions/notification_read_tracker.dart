import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settlenow/bloc/bloc_core.dart';
import 'package:settlenow/util/util_core.dart';

class NotificationReadTracker {
  static final NotificationReadTracker _instance =
      NotificationReadTracker._internal();

  factory NotificationReadTracker() => _instance;

  NotificationReadTracker._internal();

  static const Duration _debounceDuration = Duration(seconds: 3);

  final Set<String> _pendingNotificationIds = {};

  Timer? _debounceTimer;

  void markAsRead(String notificationId, BuildContext context) {
    _pendingNotificationIds.add(notificationId);
    _startDebounceTimer(context);
  }

  bool isPending(String notificationId) {
    return _pendingNotificationIds.contains(notificationId);
  }

  void removeAll(Iterable<String> notificationIds) {
    _pendingNotificationIds.removeAll(notificationIds);
  }

  void _startDebounceTimer(BuildContext context) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(
      _debounceDuration,
      () => _onDebounceComplete(context),
    );
  }

  void _onDebounceComplete(BuildContext context) {
    if (_pendingNotificationIds.isEmpty) {
      return;
    }

    List<String> idsToMarkAsRead = List<String>.from(_pendingNotificationIds);

    try {
      context.read<ActivityNotificationBloc>().add(
        ActivityNotificationMarkAsRead(ids: idsToMarkAsRead),
      );
      _pendingNotificationIds.removeAll(idsToMarkAsRead);
    } catch (e) {
      logDebug('Failed to mark notifications as read: $e');
    }
  }

  void clear() {
    _pendingNotificationIds.clear();
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void dispose() {
    clear();
  }
}
