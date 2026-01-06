import 'package:flutter/foundation.dart';

class CompanyModel {
  final int id;
  final String name;
  final String? logoUrl;
  final String? coverImageUrl;
  final double lat;
  final double lng;
  final String? description;
  final String? phone;
  final String? website;
  final String? email;
  final String? address;
  final String? workingHours;
  final int? followersCount;
  final double? rating;
  final int? reviewsCount;
  final DateTime? createdAt;
  final int? dealCount;
  final int? categoryId; // Kept for backward compatibility
  final String? categoryName;
  final Map<String, dynamic>? socialLinks;
  final List<int>? categoryIds; // ✅ New Field
  final int? primaryCategoryId; // ✅ New Field
  final String? instagramUrl; // ✅ New Field

  CompanyModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.coverImageUrl,
    required this.lat,
    required this.lng,
    this.description,
    this.phone,
    this.website,
    this.email,
    this.address,
    this.workingHours,
    this.followersCount,
    this.rating,
    this.reviewsCount,
    this.createdAt,
    this.dealCount,
    this.categoryId,
    this.categoryName,
    this.socialLinks,
    this.categoryIds, // ✅ New Field
    this.primaryCategoryId, // ✅ New Field
    this.instagramUrl, // ✅ New Field
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    try {
      return CompanyModel(
        id: json['company_id'] ?? json['id'],
        name: json['company_name'] ?? json['name'] ?? 'No Name',
        logoUrl: json['company_logo_url'] ?? json['logo_url'],
        coverImageUrl:
            json['company_cover_image_url'] ?? json['cover_image_url'],
        lat: (json['company_lat'] ?? json['lat'] as num?)?.toDouble() ?? 0.0,
        lng: (json['company_lng'] ?? json['lng'] as num?)?.toDouble() ?? 0.0,
        description: json['company_description'] ?? json['description'],
        phone: json['company_phone'] ?? json['phone'],
        website: json['company_website'] ?? json['website'],
        email: json['company_email'] ?? json['email'],
        address: json['company_address'] ?? json['address'],
        workingHours: json['company_working_hours'] ?? json['working_hours'],
        followersCount:
            (json['company_followers_count'] ?? json['followers_count'] as num?)
                ?.toInt(),
        rating: (json['company_rating'] ?? json['rating'] as num?)?.toDouble(),
        reviewsCount:
            (json['company_reviews_count'] ?? json['reviews_count'] as num?)
                ?.toInt(),
        createdAt: json['company_created_at'] != null
            ? DateTime.tryParse(json['company_created_at'])
            : json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        dealCount: (json['deal_count'] as num?)?.toInt(),
        categoryId: json['category_id'] as int?,
        categoryName:
            json['category_name'] as String? ??
            json['categories']?['name'] as String?,
        socialLinks: json['social_links'],
        categoryIds: (json['category_ids'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(), // ✅ New Field
        primaryCategoryId: json['primary_category_id'] as int?, // ✅ New Field
        instagramUrl: json['instagram_url'], // ✅ New Field
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing CompanyModel: $e');
        print('Failed JSON: $json');
      }
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'lat': lat,
      'lng': lng,
      'description': description,
      'phone': phone,
      'website': website,
      'email': email,
      'address': address,
      'working_hours': workingHours,
      'followers_count': followersCount,
      'rating': rating,
      'reviews_count': reviewsCount,
      'created_at': createdAt?.toIso8601String(),
      'deal_count': dealCount,
      'social_links': socialLinks,
      'category_ids': categoryIds, // ✅ New Field
      'primary_category_id': primaryCategoryId, // ✅ New Field
      'instagram_url': instagramUrl, // ✅ New Field
    };
  }

  CompanyModel copyWith({
    int? id,
    String? name,
    String? description,
    String? logoUrl,
    String? coverImageUrl,
    String? website,
    String? phone,
    String? email,
    String? address,
    double? lat,
    double? lng,
    String? workingHours,
    int? followersCount,
    double? rating,
    int? reviewsCount,
    DateTime? createdAt,
    int? dealCount,
    int? categoryId,
    String? categoryName,
    Map<String, dynamic>? socialLinks,
    List<int>? categoryIds, // ✅ New Field
    int? primaryCategoryId, // ✅ New Field
    String? instagramUrl, // ✅ New Field
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      website: website ?? this.website,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      workingHours: workingHours ?? this.workingHours,
      followersCount: followersCount ?? this.followersCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      createdAt: createdAt ?? this.createdAt,
      dealCount: dealCount ?? this.dealCount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      socialLinks: socialLinks ?? this.socialLinks,
      categoryIds: categoryIds ?? this.categoryIds, // ✅ New Field
      primaryCategoryId:
          primaryCategoryId ?? this.primaryCategoryId, // ✅ New Field
      instagramUrl: instagramUrl ?? this.instagramUrl, // ✅ New Field
    );
  }
}
