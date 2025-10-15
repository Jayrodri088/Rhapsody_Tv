class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? link;
  final String? linkText;
  final bool isActive;
  final String createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.link,
    this.linkText,
    required this.isActive,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      link: json['link']?.isEmpty == true ? null : json['link'],
      linkText: json['link_text']?.isEmpty == true ? null : json['link_text'],
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'link': link ?? '',
      'link_text': linkText ?? '',
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  bool get hasLink => link != null && link!.isNotEmpty;
}
