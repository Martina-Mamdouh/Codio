import '../utils/url_utils.dart';

class BannerModel {
  final int id;
  final String imageUrl;
  final int? dealId;
  final String? linkUrl;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.dealId,
    this.linkUrl,
    required this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    try {
      return BannerModel(
        id: json['id'] as int,
        imageUrl: UrlUtils.constructFullUrl(json['image_url'] as String?),
        dealId: json['deal_id'] as int?,
        linkUrl: json['link_url'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      return BannerModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        imageUrl: json['image_url'] ?? '',
        dealId: (json['deal_id'] as num?)?.toInt(),
        linkUrl: json['link_url'] as String?,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'deal_id': dealId,
      'link_url': linkUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
