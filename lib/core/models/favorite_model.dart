class FavoriteModel {
  final int id;
  final String userId;
  final int dealId;
  final DateTime createdAt;

  // بيانات العرض (من join)
  final String? dealTitle;
  final String? dealImage;
  final String? dealValue;
  final DateTime? dealExpiresAt;
  final String? companyName;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.dealId,
    required this.createdAt,
    this.dealTitle,
    this.dealImage,
    this.dealValue,
    this.dealExpiresAt,
    this.companyName,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      dealId: json['deal_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      // بيانات العرض من join مع جدول deals
      dealTitle: json['deals']?['title'] as String?,
      dealImage: json['deals']?['image_url'] as String?,
      dealValue: json['deals']?['deal_value'] as String?,
      dealExpiresAt: json['deals']?['expires_at'] != null
          ? DateTime.parse(json['deals']['expires_at'] as String)
          : null,
      // بيانات الشركة من nested join
      companyName: json['deals']?['companies']?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'deal_id': dealId};
  }
}
