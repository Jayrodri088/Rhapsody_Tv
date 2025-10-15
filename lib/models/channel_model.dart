class Channel {
  final String id;
  final String name;
  final String streamUrl;
  final String? thumbnail;
  final bool isLive;
  final bool isFeatured;
  final String category;
  final int order;
  final String createdAt;
  final String? updatedAt;

  Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.thumbnail,
    required this.isLive,
    required this.isFeatured,
    required this.category,
    required this.order,
    required this.createdAt,
    this.updatedAt,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      thumbnail: json['thumbnail'],
      isLive: json['is_live'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      category: json['category'] ?? 'main',
      order: json['order'] ?? 1,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stream_url': streamUrl,
      'thumbnail': thumbnail,
      'is_live': isLive,
      'is_featured': isFeatured,
      'category': category,
      'order': order,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
