import 'package:flutter/material.dart';
import '../../core/models/city_model.dart';
import '../../core/services/supabase_service.dart';

class CitiesManagementViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CityModel> _cities = [];
  bool _isLoading = true;

  List<CityModel> get cities => _cities;
  bool get isLoading => _isLoading;

  CitiesManagementViewModel() {
    loadCities();
  }

  Future<void> loadCities() async {
    _isLoading = true;
    notifyListeners();

    try {
      _cities = await _supabaseService.getCities();
    } catch (e) {
      debugPrint('Error loading cities: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCity(Map<String, dynamic> data) async {
    try {
      await _supabaseService.addCity(data);
      await loadCities();
    } catch (e) {
      throw Exception('فشلت إضافة المدينة: $e');
    }
  }

  Future<void> updateCity(int id, Map<String, dynamic> data) async {
    try {
      await _supabaseService.updateCity(id, data);
      await loadCities();
    } catch (e) {
      throw Exception('فشل تحديث المدينة: $e');
    }
  }

  Future<void> deleteCity(int id) async {
    try {
      await _supabaseService.deleteCity(id);
      await loadCities();
    } catch (e) {
      throw Exception('فشل حذف المدينة: $e');
    }
  }
}

