class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? link;
  final String? linkText;
  final String? channelName;
  final String? channelUrl;
  final String? channelButtonText;
  final bool isActive;
  final String createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.link,
    this.linkText,
    this.channelName,
    this.channelUrl,
    this.channelButtonText,
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
      channelName: json['channel_name']?.isEmpty == true ? null : json['channel_name'],
      channelUrl: json['channel_url']?.isEmpty == true ? null : json['channel_url'],
      channelButtonText: json['channel_button_text']?.isEmpty == true ? null : json['channel_button_text'],
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
      'channel_name': channelName ?? '',
      'channel_url': channelUrl ?? '',
      'channel_button_text': channelButtonText ?? '',
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  bool get hasLink => link != null && link!.isNotEmpty;
  bool get hasChannel => channelName != null && channelName!.isNotEmpty && channelUrl != null && channelUrl!.isNotEmpty;
}
