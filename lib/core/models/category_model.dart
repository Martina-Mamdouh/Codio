import 'package:flutter/foundation.dart';
import '../utils/url_utils.dart';

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
    try {
      return CategoryModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? 'No Category',
        iconName: json['icon_name'] as String?,
        imageUrl: UrlUtils.constructFullUrl(json['image_url'] as String?),
        createdAt: json['created_at'] != null 
            ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      return CategoryModel(
        id: 0,
        name: 'Parsing Error',
        createdAt: DateTime.now(),
      );
    }
  }
}
