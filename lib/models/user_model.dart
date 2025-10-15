class UserModel {
  final String id;
  final String email;
  final String token;
  final String? createdAt;
  final String? lastLogin;
  final String? name; // Changed from username and made final (non-editable)
  String? phoneNumber;
  String? profileImage;

  UserModel({
    required this.id,
    required this.email,
    required this.token,
    this.createdAt,
    this.lastLogin,
    this.name,
    this.phoneNumber,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
      createdAt: json['created_at'],
      lastLogin: json['last_login'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'token': token,
      'created_at': createdAt,
      'last_login': lastLogin,
      'name': name,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? token,
    String? createdAt,
    String? lastLogin,
    String? name,
    String? phoneNumber,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
