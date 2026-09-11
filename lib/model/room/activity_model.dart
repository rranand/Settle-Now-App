import 'package:settlenow/model/model_core.dart';
import 'package:settlenow/util/util_core.dart';

class ActivityModel {
  bool hasData = true;
  BaseUserModel user = BaseUserModel.empty();
  ActivityType entityType = ActivityType.roomCreated;
  String entityId = "";
  DateTime createdOn = DateTime.now();
  ActivityDetailValue? oldValue;
  ActivityDetailValue? newValue;

  ActivityModel({
    required this.user,
    required this.entityType,
    required this.createdOn,
    required this.entityId,
    this.oldValue,
    this.newValue,
  });

  ActivityModel.empty({this.hasData = false});

  ActivityModel copyWith({
    BaseUserModel? user,
    String? entityId,
    ActivityType? entityType,
    DateTime? createdOn,
    ActivityDetailValue? oldValue,
    ActivityDetailValue? newValue,
  }) {
    return ActivityModel(
      user: user ?? this.user,
      entityType: entityType ?? this.entityType,
      createdOn: createdOn ?? this.createdOn,
      entityId: entityId ?? this.entityId,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
    );
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    final baseUser = UserResolver.instance.resolve(map['user_id']);

    return ActivityModel(
      user: baseUser,
      entityId: map['entity_id'],
      entityType: activityTypeFromString(map['entity_type']),
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      oldValue:
          map['old_value'] != null
              ? ActivityDetailValue.fromMap(
                map['old_value'] as Map<String, dynamic>,
              )
              : null,
      newValue:
          map['new_value'] != null
              ? ActivityDetailValue.fromMap(
                map['new_value'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  @override
  String toString() {
    return 'ActivityModel(user: $user, entityType: $entityType, entityId: $entityId, createdOn: $createdOn)';
  }

  @override
  bool operator ==(covariant ActivityModel other) {
    if (identical(this, other)) return true;

    return other.user == user &&
        other.entityId == entityId &&
        other.entityType == entityType &&
        other.createdOn == createdOn &&
        other.oldValue == oldValue &&
        other.newValue == newValue;
  }

  @override
  int get hashCode {
    return user.hashCode ^
        entityId.hashCode ^
        entityType.hashCode ^
        createdOn.hashCode ^
        oldValue.hashCode ^
        newValue.hashCode;
  }
}

class ActivityDetailValue {
  String? description;
  double? amount;
  BaseUserModel? user;

  ActivityDetailValue({this.description, this.amount, this.user});

  ActivityDetailValue copyWith({
    String? description,
    double? amount,
    BaseUserModel? user,
  }) {
    return ActivityDetailValue(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      user: user ?? this.user,
    );
  }

  factory ActivityDetailValue.fromMap(Map<String, dynamic> map) {
    return ActivityDetailValue(
      description: map['description'],
      amount:
          map['amount'] != null ? double.parse(map['amount'].toString()) : null,
      user:
          map['user_id'] != null
              ? UserResolver.instance.resolve(map['user_id'])
              : null,
    );
  }

  @override
  bool operator ==(covariant ActivityDetailValue other) {
    if (identical(this, other)) return true;

    return other.description == description &&
        other.amount == amount &&
        other.user == user;
  }

  @override
  String toString() {
    return 'ActivityDetailValue(description: $description, amount: $amount, user: $user)';
  }

  @override
  int get hashCode => description.hashCode ^ amount.hashCode ^ user.hashCode;
}
