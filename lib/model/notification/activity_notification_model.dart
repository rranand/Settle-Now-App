import 'package:settlenow/util/util_core.dart';

class ActivityNotificationModel {
  bool hasData = true;
  final String id;
  final NotificationType type;
  final String entityId;
  final String? relatedEntityId;
  final String title;
  final String body;
  final Map<String, String> data;
  final NotificationChannelType channelType;
  final DateTime createdOn;
  final DateTime? readOn;

  ActivityNotificationModel({
    required this.id,
    required this.type,
    required this.entityId,
    this.relatedEntityId,
    required this.title,
    required this.body,
    required this.data,
    required this.createdOn,
    required this.channelType,
    this.readOn,
  });

  ActivityNotificationModel.empty({this.hasData = false})
    : id = '',
      type = NotificationType.unknown,
      entityId = '',
      relatedEntityId = null,
      title = '',
      body = '',
      data = const {},
      createdOn = DateTime.now(),
      readOn = null,
      channelType = NotificationChannelType.miscellaneous;

  factory ActivityNotificationModel.fromMap(Map<String, dynamic> json) {
    final extraData = (json['data'] as Map<String, dynamic>? ?? {}).map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return ActivityNotificationModel(
      id: json['id'] as String,
      type: NotificationType.fromValue(json['type'] as String),
      entityId: json['entity_id'] as String,
      relatedEntityId: json['related_entity_id'] as String?,
      title: json['title'] as String,
      body: json['body'] as String,
      data: extraData,
      channelType: notificationChannelTypeFromString(extraData['type'] ?? ""),
      createdOn: DateTime.parse(json['created_on'] as String),
      readOn:
          json['read_on'] != null
              ? DateTime.parse(json['read_on'] as String)
              : null,
    );
  }

  ActivityNotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? entityId,
    String? relatedEntityId,
    String? title,
    String? body,
    Map<String, String>? data,
    DateTime? createdOn,
    DateTime? readOn,
    NotificationChannelType? channelType,
  }) {
    return ActivityNotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      entityId: entityId ?? this.entityId,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      createdOn: createdOn ?? this.createdOn,
      readOn: readOn ?? this.readOn,
      channelType: channelType ?? this.channelType,
    );
  }
}
