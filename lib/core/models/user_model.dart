class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String profession;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.profession,
    required this.createdAt,
  });

  /// ---------------------------------------------------------
  /// FROM JSON — supports both:
  /// 1) Normal user table
  /// 2) Joined users from: reviews.select("*, users(*)")
  /// ---------------------------------------------------------
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // If response came from joined users (users: {...})
    final userData = json['users'] ?? json;

    return UserModel(
      id: userData['id'] ?? '',
      email: userData['email'] ?? '',
      fullName:
          userData['full_name'] ??
          userData['display_name'] ??
          '', // fallback for joined users
      avatarUrl: userData['avatar_url'],
      profession: userData['profession'] ?? '',
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'])
          : DateTime.now(),
    );
  }

  /// ---------------------------------------------------------
  /// TO JSON (Used mainly for updates)
  /// ---------------------------------------------------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'profession': profession,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// ---------------------------------------------------------
  /// CopyWith
  /// ---------------------------------------------------------
  UserModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? profession,
  }) {
    return UserModel(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      profession: profession ?? this.profession,
      createdAt: createdAt,
    );
  }

  /// ---------------------------------------------------------
  /// Display name (fallback to email)
  /// ---------------------------------------------------------
  String get displayName =>
      fullName.isNotEmpty ? fullName : email.split('@')[0];

  /// ---------------------------------------------------------
  /// User initials (for Avatar)
  /// ---------------------------------------------------------
  String get initials {
    if (fullName.trim().isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : "?";
    }

    final parts = fullName.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }

    return fullName[0].toUpperCase();
  }
}
