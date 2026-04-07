class AdModel {
  final int id;
  final String imageLink;
  final bool isActive;
  final int dealId;
  final String? dealTitle; // Optional: For display in admin

  AdModel({
    required this.id,
    required this.imageLink,
    required this.isActive,
    required this.dealId,
    this.dealTitle,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as int,
      imageLink: json['image_link'] as String,
      isActive: json['is_active'] as bool,
      dealId: json['deal_id'] as int,
      dealTitle: json['deals'] != null ? json['deals']['title'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_link': imageLink,
      'is_active': isActive,
      'deal_id': dealId,
    };
  }
}
