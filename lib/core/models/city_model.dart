class CityModel {
  final int id;
  final String nameEn;
  final String nameAr;

  CityModel({
    required this.id,
    required this.nameEn,
    required this.nameAr,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int,
      nameEn: json['name_en'] as String? ?? 'Unknown',
      nameAr: json['name_ar'] as String? ?? 'غير معروف',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
    };
  }
}

