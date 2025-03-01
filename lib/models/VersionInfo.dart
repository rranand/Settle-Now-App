class VersionInfo {
  final String version;
  final String link;
  final String description;

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
        version: json['version'],
        link: json['link'],
        description: json['description']);
  }

  VersionInfo(
      {required this.version, required this.link, required this.description});
}
