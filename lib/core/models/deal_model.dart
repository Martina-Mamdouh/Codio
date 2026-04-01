import 'package:flutter/foundation.dart';
import '../utils/url_utils.dart';

class DealModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String dealType;
  final String dealValue;
  final DateTime expiresAt;
  final int companyId;
  final DateTime createdAt;
  final String termsConditions;
  final DateTime startsAt;
  final String publishLocation;
  final bool isFeatured;
  final bool showInMap; // ✅ New Field
  final String discountValue;
  final bool isForStudents;
  final String? companyName;
  final String? companyLogo;
  final bool companyIsPartner; // ✅ Partner Mark
  final String? linkUrl;
  
  // ✅ New Fields for distance calculation
  final double? companyLat;
  final double? companyLng;

  // ✨ الحقول الجديدة
  final int? categoryId;
  final String? categoryName;

  // Dynamic feedback and success rate
  final double? successRate;
  final double? feedbackHappy;
  final double? feedbackNeutral;
  final double? feedbackSad;

  // Multi-image support
  final List<String> imageUrls;

  /// Returns all images: primary image + additional images
  List<String> get allImages {
    final List<String> images = [];
    if (imageUrl.isNotEmpty) images.add(imageUrl);
    images.addAll(imageUrls.where((url) => url.isNotEmpty));
    return images;
  }

  DealModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.dealType,
    required this.dealValue,
    required this.expiresAt,
    required this.companyId,
    required this.createdAt,
    required this.termsConditions,
    required this.startsAt,
    required this.publishLocation,
    this.companyLogo,
    this.isFeatured = false,
    this.showInMap = false,
    this.discountValue = '',
    this.isForStudents = false,
    this.companyName,
    this.companyIsPartner = false, // ✅ Partner Mark
    this.linkUrl,
    this.companyLat,
    this.companyLng,
    this.categoryId,
    this.categoryName,
    this.successRate,
    this.feedbackHappy,
    this.feedbackNeutral,
    this.feedbackSad,
    this.imageUrls = const [],
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    try {
      final companyData = json['companies'];
      
      return DealModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] ?? 'No Title',
        description: json['description'] ?? '',
        imageUrl: UrlUtils.constructFullUrl(json['image_url'] as String?),
        dealType: json['deal_type'] ?? 'unknown',
        dealValue: json['deal_value'] ?? '',
        expiresAt:
            DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
        companyId: (json['company_id'] as num?)?.toInt() ?? 0,
        createdAt:
            DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        termsConditions: json['terms_conditions'] ?? '',
        startsAt: DateTime.tryParse(json['starts_at'] ?? '') ?? DateTime.now(),
        publishLocation: json['publish_location'] ?? 'home',
        isFeatured: json['is_featured'] ?? false,
        showInMap: json['show_in_map'] ?? false,
        discountValue: json['discount_value'] ?? '',
        isForStudents: json['is_for_students'] ?? false,
        companyName: companyData != null
            ? (companyData is List
                  ? (companyData as List).isNotEmpty
                        ? (companyData as List).first['name']
                        : null
                  : companyData['name'])
            : null,
        companyLogo: companyData != null
            ? (companyData is List
                  ? (companyData as List).isNotEmpty
                        ? UrlUtils.constructFullUrl(
                            (companyData as List).first['logo_url']
                                as String?,
                          )
                        : null
                  : UrlUtils.constructFullUrl(
                      companyData['logo_url'] as String?,
                    ))
            : null,
        companyIsPartner: companyData != null
            ? (companyData is List
                  ? (companyData as List).isNotEmpty
                        ? (companyData as List).first['is_partner'] == true
                        : false
                  : companyData['is_partner'] == true)
            : false, // ✅ Partner mark
        linkUrl: json['link_url'] as String?,

        // Extract company location for nearby sorting
        companyLat: companyData != null
            ? (companyData is List && companyData.isNotEmpty
                ? (companyData.first['lat'] as num?)?.toDouble()
                : (companyData is Map ? (companyData['lat'] as num?)?.toDouble() : null))
            : null,
        companyLng: companyData != null
            ? (companyData is List && companyData.isNotEmpty
                ? (companyData.first['lng'] as num?)?.toDouble()
                : (companyData is Map ? (companyData['lng'] as num?)?.toDouble() : null))
            : null,

        // ✨ الحقول الجديدة
        categoryId: (json['category_id'] as num?)?.toInt(),
        categoryName: json['categories'] != null
            ? (json['categories'] is List
                  ? (json['categories'] as List).isNotEmpty
                        ? (json['categories'] as List).first['name']
                        : null
                  : json['categories']['name'])
            : json['category_name'] as String?,

        // Dynamic feedback and success rate
        successRate: json['success_rate'] != null
            ? (json['success_rate'] as num).toDouble()
            : null,
        feedbackHappy: json['feedback_happy'] != null
            ? (json['feedback_happy'] as num).toDouble()
            : null,
        feedbackNeutral: json['feedback_neutral'] != null
            ? (json['feedback_neutral'] as num).toDouble()
            : null,
        feedbackSad: json['feedback_sad'] != null
            ? (json['feedback_sad'] as num).toDouble()
            : null,

        // Multi-image support
        imageUrls: json['image_urls'] != null
            ? (json['image_urls'] as List)
                .map((url) => UrlUtils.constructFullUrl(url as String?))
                .where((url) => url.isNotEmpty)
                .toList()
            : [],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing DealModel: $e');
        print('JSON INPUT → $json');
      }
      rethrow;
    }
  }

  // ⭐ copyWith
  DealModel copyWith({
    int? id,
    String? title,
    String? description,
    String? imageUrl,
    String? dealType,
    String? dealValue,
    DateTime? expiresAt,
    int? companyId,
    DateTime? createdAt,
    String? termsConditions,
    DateTime? startsAt,
    String? publishLocation,
    bool? isFeatured,
    bool? showInMap,
    String? discountValue,
    bool? isForStudents,
    String? companyName,
    String? companyLogo,
    bool? companyIsPartner,
    String? linkUrl,
    double? companyLat,
    double? companyLng,
    int? categoryId,
    String? categoryName,
    double? successRate,
    double? feedbackHappy,
    double? feedbackNeutral,
    double? feedbackSad,
    List<String>? imageUrls,
  }) {
    return DealModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      dealType: dealType ?? this.dealType,
      dealValue: dealValue ?? this.dealValue,
      expiresAt: expiresAt ?? this.expiresAt,
      companyId: companyId ?? this.companyId,
      createdAt: createdAt ?? this.createdAt,
      termsConditions: termsConditions ?? this.termsConditions,
      startsAt: startsAt ?? this.startsAt,
      publishLocation: publishLocation ?? this.publishLocation,
      isFeatured: isFeatured ?? this.isFeatured,
      showInMap: showInMap ?? this.showInMap,
      discountValue: discountValue ?? this.discountValue,
      isForStudents: isForStudents ?? this.isForStudents,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      companyIsPartner: companyIsPartner ?? this.companyIsPartner, // ✅
      linkUrl: linkUrl ?? this.linkUrl,
      companyLat: companyLat ?? this.companyLat,
      companyLng: companyLng ?? this.companyLng,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      successRate: successRate ?? this.successRate,
      feedbackHappy: feedbackHappy ?? this.feedbackHappy,
      feedbackNeutral: feedbackNeutral ?? this.feedbackNeutral,
      feedbackSad: feedbackSad ?? this.feedbackSad,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }
}
