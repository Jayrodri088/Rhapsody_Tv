class Category {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final int order;
  final String createdAt;
  final String? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.order,
    required this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'] ?? '📺',
      order: json['order'] ?? 1,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'order': order,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
