// lib/core/models/review_model.dart
class ReviewModel {
  final int id;
  final String userId;
  final int companyId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? userName;
  final String? userAvatar;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // غيّر من user_profile إلى user
    final user = json['user'];

    return ReviewModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      companyId: json['company_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: user?['full_name'] as String?,
      userAvatar: user?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_id': companyId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    int? id,
    String? userId,
    int? companyId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }
}
