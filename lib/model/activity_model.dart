import 'package:settlenow/util/util_core.dart';

class ActivityModel {
  bool hasData = true;
  String id = "";
  String user = "";
  ActivityType type = ActivityType.roomCreated;
  String entityId = "";
  DateTime createdOn = DateTime.now();
  ActivityDetails? details;

  ActivityModel({
    required this.id,
    required this.user,
    required this.type,
    required this.createdOn,
    required this.entityId,
    this.details,
  });

  ActivityModel.empty({this.hasData = false});

  ActivityModel copyWith({
    String? id,
    String? user,
    DateTime? createdOn,
    ActivityType? type,
    String? entityId,
    ActivityDetails? details,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      user: user ?? this.user,
      type: type ?? this.type,
      createdOn: createdOn ?? this.createdOn,
      entityId: entityId ?? this.entityId,
      details: details ?? this.details,
    );
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      user: map['user'],
      type: activityTypeFromApi(map['type']),
      createdOn: DateTime.parse(map['created_on']).toLocal(),
      entityId: map['entityId'],
      details:
          map['details'] != null
              ? ActivityDetails.fromMap(map['details'] as Map<String, dynamic>)
              : null,
    );
  }

  @override
  String toString() {
    return 'ActivityModel(id: $id, user: $user, type: $type, entityId: $entityId, details: $details)';
  }

  @override
  bool operator ==(covariant ActivityModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.user == user &&
        other.type == type &&
        other.createdOn == createdOn &&
        other.entityId == entityId &&
        other.details == details;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        user.hashCode ^
        type.hashCode ^
        createdOn.hashCode ^
        entityId.hashCode ^
        details.hashCode;
  }
}

class ActivityDetails {
  ActivityDetailValue? oldValue;
  ActivityDetailValue? newValue;

  ActivityDetails({this.oldValue, this.newValue});

  ActivityDetails copyWith({
    ActivityDetailValue? oldValue,
    ActivityDetailValue? newValue,
  }) {
    return ActivityDetails(
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
    );
  }

  factory ActivityDetails.fromMap(Map<String, dynamic> map) {
    return ActivityDetails(
      oldValue:
          map['oldValue'] != null
              ? ActivityDetailValue.fromMap(map['oldValue'])
              : null,
      newValue:
          map['newValue'] != null
              ? ActivityDetailValue.fromMap(map['newValue'])
              : null,
    );
  }

  @override
  bool operator ==(covariant ActivityDetails other) {
    if (identical(this, other)) return true;

    return other.oldValue == oldValue && other.newValue == newValue;
  }

  @override
  int get hashCode => oldValue.hashCode ^ newValue.hashCode;
}

class ActivityDetailValue {
  String? description;
  double? amount;
  String? user;

  ActivityDetailValue({this.description, this.amount, this.user});

  ActivityDetailValue copyWith({
    String? description,
    double? amount,
    String? user,
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
      user: map['user'],
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
  int get hashCode => description.hashCode ^ amount.hashCode ^ user.hashCode;
}
