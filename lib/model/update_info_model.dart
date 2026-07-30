import 'dart:convert';

class UpdateInfoModel {
  bool hasData = true;
  String version = "";
  String link = "";
  String description = "";
  bool important = false;
  bool maintenance = false;
  String currentVersion = "";

  UpdateInfoModel({
    required this.version,
    required this.link,
    required this.description,
    required this.important,
    required this.maintenance,
    required this.currentVersion,
  });

  UpdateInfoModel.empty({this.hasData = false});

  UpdateInfoModel copyWith({
    String? version,
    String? link,
    String? description,
    bool? important,
    bool? maintenance,
    String? currentVersion,
  }) {
    return UpdateInfoModel(
      version: version ?? this.version,
      link: link ?? this.link,
      description: description ?? this.description,
      important: important ?? this.important,
      maintenance: maintenance ?? this.maintenance,
      currentVersion: currentVersion ?? this.currentVersion,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'version': version,
      'link': link,
      'description': description,
      'important': important,
      'maintenance': maintenance,
      'current_version': currentVersion,
    };
  }

  factory UpdateInfoModel.fromMap(
    Map<String, dynamic> map,
    String currentVersion,
  ) {
    return UpdateInfoModel(
      version: map['version'],
      link: map['link'],
      description: map['description'],
      important: map['important'],
      maintenance: map['maintenance'],
      currentVersion: currentVersion,
    );
  }

  factory UpdateInfoModel.fromAPI(
    Map<String, dynamic> map,
    String currentVersion,
  ) {
    return UpdateInfoModel(
      version: map['version'],
      link: map['link'],
      description: map['description'],
      important: map['important'],
      maintenance: map['maintenance'],
      currentVersion: currentVersion,
    );
  }

  bool isUpdateRequired() {
    List<int> splitVersion(String version) {
      final parts = version.split('+');
      final versionParts = parts[0].split('.').map(int.parse).toList();

      if (parts.length > 1) {
        versionParts.add(int.parse(parts[1]));
      } else {
        versionParts.add(0);
      }

      return versionParts;
    }

    final current = splitVersion(currentVersion);
    final latest = splitVersion(version);

    for (int i = 0; i < current.length; i++) {
      if (current[i] < latest[i]) return true;
      if (current[i] > latest[i]) return false;
    }

    return false;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UpdateInfoModel(version: $version, currentVersion: $currentVersion, link: $link, description: $description, important: $important, maintenance: $maintenance)';
  }

  @override
  bool operator ==(covariant UpdateInfoModel other) {
    if (identical(this, other)) return true;

    return other.version == version &&
        other.link == link &&
        other.description == description &&
        other.important == important &&
        other.maintenance == maintenance &&
        other.currentVersion == currentVersion;
  }

  @override
  int get hashCode {
    return version.hashCode ^
        link.hashCode ^
        description.hashCode ^
        important.hashCode ^
        maintenance.hashCode ^
        currentVersion.hashCode;
  }
}
