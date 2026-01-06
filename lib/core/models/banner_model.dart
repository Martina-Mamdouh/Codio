class BannerModel {
  final int id;
  final String imageUrl;
  final int? dealId;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.dealId,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      imageUrl: json['image_url'] as String,
      dealId: json['deal_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'deal_id': dealId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
