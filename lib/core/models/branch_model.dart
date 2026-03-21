class BranchModel {
  final int? id;
  final int companyId;
  final String name;
  final double lat;
  final double lng;
  final String? address;
  final String? phone;
  final String? workingHours;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic>? socialLinks; // ✅ Social Links

  BranchModel({
    this.id,
    required this.companyId,
    required this.name,
    this.lat = 0.0,
    this.lng = 0.0,
    this.address,
    this.phone,
    this.workingHours,
    this.imageUrl,
    this.description,
    this.socialLinks,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: (json['id'] as num?)?.toInt(),
      companyId: (json['company_id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      workingHours: json['working_hours'] as String?,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      socialLinks: json['social_links'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'company_id': companyId,
      'name': name,
      'lat': lat,
      'lng': lng,
      'address': address,
      'phone': phone,
      'working_hours': workingHours,
      'image_url': imageUrl,
      'description': description,
      'social_links': socialLinks,
    };
  }

  BranchModel copyWith({
    int? id,
    int? companyId,
    String? name,
    double? lat,
    double? lng,
    String? address,
    String? phone,
    String? workingHours,
    String? imageUrl,
    String? description,
    Map<String, dynamic>? socialLinks,
  }) {
    return BranchModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      workingHours: workingHours ?? this.workingHours,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }
}
