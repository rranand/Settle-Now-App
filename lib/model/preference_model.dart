// ignore_for_file: public_member_api_docs, sort_constructors_first
class PreferenceModel {
  bool hasData = true;
  PreferenceSection room = PreferenceSection.empty();
  PreferenceSection quicksplit = PreferenceSection.empty();
  PreferenceSection lenden = PreferenceSection.empty();
  EmptyPreferenceSection personalExpense = EmptyPreferenceSection.empty();
  String theme = 'system';

  PreferenceModel({
    required this.room,
    required this.quicksplit,
    required this.lenden,
    required this.personalExpense,
    required this.theme,
  });

  PreferenceModel.empty({this.hasData = false});

  factory PreferenceModel.fromJson(Map<String, dynamic> json) {
    return PreferenceModel(
      room: PreferenceSection.fromJson(json['room']),
      quicksplit: PreferenceSection.fromJson(json['quicksplit']),
      lenden: PreferenceSection.fromJson(json['lenden']),
      personalExpense: EmptyPreferenceSection.fromJson(json['personalExpense']),
      theme: json['theme'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room': room.toJson(),
      'quicksplit': quicksplit.toJson(),
      'lenden': lenden.toJson(),
      'personalExpense': personalExpense.toJson(),
      'theme': theme,
    };
  }

  @override
  bool operator ==(covariant PreferenceModel other) {
    if (identical(this, other)) return true;

    return other.room == room &&
        other.quicksplit == quicksplit &&
        other.lenden == lenden &&
        other.personalExpense == personalExpense &&
        other.theme == theme;
  }

  @override
  int get hashCode {
    return room.hashCode ^
        quicksplit.hashCode ^
        lenden.hashCode ^
        personalExpense.hashCode ^
        theme.hashCode;
  }

  PreferenceModel copyWith({
    PreferenceSection? room,
    PreferenceSection? quicksplit,
    PreferenceSection? lenden,
    EmptyPreferenceSection? personalExpense,
    String? theme,
  }) {
    return PreferenceModel(
      room: room ?? this.room,
      quicksplit: quicksplit ?? this.quicksplit,
      lenden: lenden ?? this.lenden,
      personalExpense: personalExpense ?? this.personalExpense,
      theme: theme ?? this.theme,
    );
  }
}

class PreferenceSection {
  bool hasData = true;
  bool isSettled = true;

  PreferenceSection({required this.isSettled});

  PreferenceSection.empty({this.hasData = false});

  factory PreferenceSection.fromJson(Map<String, dynamic> json) {
    return PreferenceSection(isSettled: json['isSettled'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'isSettled': isSettled};
  }

  @override
  bool operator ==(covariant PreferenceSection other) {
    if (identical(this, other)) return true;

    return other.isSettled == isSettled;
  }

  @override
  int get hashCode => isSettled.hashCode;

  PreferenceSection copyWith({bool? isSettled}) {
    return PreferenceSection(isSettled: isSettled ?? this.isSettled);
  }
}

class EmptyPreferenceSection {
  bool hasData = true;
  bool showEmpty = true;

  EmptyPreferenceSection({required this.showEmpty});

  EmptyPreferenceSection.empty({this.hasData = false});

  factory EmptyPreferenceSection.fromJson(Map<String, dynamic> json) {
    return EmptyPreferenceSection(showEmpty: json['showEmpty'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {'showEmpty': showEmpty};
  }

  @override
  bool operator ==(covariant EmptyPreferenceSection other) {
    if (identical(this, other)) return true;

    return other.showEmpty == showEmpty;
  }

  @override
  int get hashCode => showEmpty.hashCode;

  EmptyPreferenceSection copyWith({bool? showEmpty}) {
    return EmptyPreferenceSection(showEmpty: showEmpty ?? this.showEmpty);
  }
}
