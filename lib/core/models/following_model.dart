class FollowingModel {
  final int id;
  final String userId;
  final int companyId;
  final bool notificationEnabled; // ⭐ حقل جديد
  final DateTime createdAt;

  // بيانات الشركة (من join)
  final String? companyName;
  final String? companyLogo;

  FollowingModel({
    required this.id,
    required this.userId,
    required this.companyId,
    this.notificationEnabled = true,
    required this.createdAt,
    this.companyName,
    this.companyLogo,
  });

  factory FollowingModel.fromJson(Map<String, dynamic> json) {
    return FollowingModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      companyId: json['company_id'] as int,
      notificationEnabled: json['notification_enabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      // بيانات الشركة من join مع جدول companies
      companyName: json['companies']?['name'] as String?,
      companyLogo: json['companies']?['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'company_id': companyId,
      'notification_enabled': notificationEnabled,
    };
  }

  // Helper: نسخ مع تعديل notification
  FollowingModel copyWith({bool? notificationEnabled}) {
    return FollowingModel(
      id: id,
      userId: userId,
      companyId: companyId,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt,
      companyName: companyName,
      companyLogo: companyLogo,
    );
  }
}
