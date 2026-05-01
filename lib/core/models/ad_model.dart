class AdModel {
  final int id;
  final String imageLink;
  final bool isActive;
  final int? dealId;
  final String? linkUrl;
  final String? dealTitle;
  final String placement; // 'home' or 'category'
  final int? categoryId;
  final String? categoryName;

  AdModel({
    required this.id,
    required this.imageLink,
    required this.isActive,
    this.dealId,
    this.linkUrl,
    this.dealTitle,
    this.placement = 'home',
    this.categoryId,
    this.categoryName,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as int,
      imageLink: json['image_link'] as String,
      isActive: json['is_active'] as bool,
      dealId: json['deal_id'] as int?,
      linkUrl: json['link_url'] as String?,
      dealTitle: json['deals'] != null ? json['deals']['title'] as String? : null,
      placement: json['placement'] as String? ?? 'home',
      categoryId: json['category_id'] as int?,
      categoryName: json['categories'] != null ? json['categories']['name'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_link': imageLink,
      'is_active': isActive,
      'deal_id': dealId,
      'link_url': linkUrl,
      'placement': placement,
      'category_id': categoryId,
    };
  }
}
