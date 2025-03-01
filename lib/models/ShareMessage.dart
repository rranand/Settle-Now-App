class ShareMessage {
  final String title;
  final String subject;
  final String photo;
  final String web;
  final String playstore;

  ShareMessage(
      {required this.title,
      required this.subject,
      required this.photo,
      required this.web,
      required this.playstore});

  factory ShareMessage.fromJson(Map<String, dynamic> json) {
    return ShareMessage(
      title: json['title'],
      subject: json['subject'],
      photo: json['photo'],
      web: json['web'],
      playstore: json['playstore'],
    );
  }
}
