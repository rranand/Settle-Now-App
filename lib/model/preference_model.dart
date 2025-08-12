// ignore_for_file: public_member_api_docs, sort_constructors_first
class PreferenceModel {
  bool hasData = true;
  PreferenceSection room = PreferenceSection.empty();
  PreferenceSection quicksplit = PreferenceSection.empty();
  PreferenceSection lenden = PreferenceSection.empty();
  String theme = 'system';

  PreferenceModel({
    required this.room,
    required this.quicksplit,
    required this.lenden,
    required this.theme,
  });

  PreferenceModel.empty({this.hasData = false});

  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      room: PreferenceSection.fromJson(json['room']),
      quicksplit: PreferenceSection.fromJson(json['quicksplit']),
      lenden: PreferenceSection.fromJson(json['lenden']),
      theme: json['theme'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room.toJson(),
      'quicksplit': quicksplit.toJson(),
      'lenden': lenden.toJson(),
      'theme': theme,
    };
  }

  @override
  bool operator ==(covariant PreferenceModel other) {
    if (identical(this, other)) return true;

    return other.room == room &&
        other.quicksplit == quicksplit &&
        other.lenden == lenden &&
        other.theme == theme;
  }

  @override
  int get hashCode {
    return room.hashCode ^
        quicksplit.hashCode ^
        lenden.hashCode ^
        theme.hashCode;
  }

  PreferenceModel copyWith({
    PreferenceSection? room,
    PreferenceSection? quicksplit,
    PreferenceSection? lenden,
    String? theme,
  }) {
    return PreferenceModel(
      room: room ?? this.room,
      quicksplit: quicksplit ?? this.quicksplit,
      lenden: lenden ?? this.lenden,
      theme: theme ?? this.theme,
    );
  }
}

class PreferenceSection {
  bool hasData = true;
  bool isSettled = true;
  bool isNotSettled = true;

  PreferenceSection({required this.isSettled, required this.isNotSettled});

  PreferenceSection.empty({this.hasData = false});

  factory PreferenceSection.fromJson(Map<String, dynamic> json) {
    return PreferenceSection(
      isSettled: json['isSettled'] ?? false,
      isNotSettled: json['isNotSettled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'isSettled': isSettled, 'isNotSettled': isNotSettled};
  }

  @override
  bool operator ==(covariant PreferenceSection other) {
    if (identical(this, other)) return true;

    return other.isSettled == isSettled && other.isNotSettled == isNotSettled;
  }

  @override
  int get hashCode => isSettled.hashCode ^ isNotSettled.hashCode;

  PreferenceSection copyWith({bool? isSettled, bool? isNotSettled}) {
    return PreferenceSection(
      isSettled: isSettled ?? this.isSettled,
      isNotSettled: isNotSettled ?? this.isNotSettled,
    );
  }
}
