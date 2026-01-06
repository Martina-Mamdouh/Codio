class NotificationModel {
  final int id;
  final String userId; // auth.users.id
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final int? dealId; // Optional: reference to a deal for deep-linking

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.dealId, // Optional parameter
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      dealId: json['deal_id'] as int?, // Nullable - may not exist
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      if (dealId != null) 'deal_id': dealId, // Only include if present
    };
  }

  NotificationModel copyWith({bool? isRead, int? dealId}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      dealId: dealId ?? this.dealId,
    );
  }
}
