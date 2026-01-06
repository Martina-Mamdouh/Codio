class CategoryModel {
  final int id;
  final String name;
  final String? iconName;
  final String? imageUrl;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.imageUrl,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      iconName: json['icon_name'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
