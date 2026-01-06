import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/models/company_model.dart';
import '../../core/models/category_model.dart';
import '../../core/services/supabase_service.dart';

class CompaniesManagementViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CompanyModel> _companies = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  CompanyModel? _selectedCompany;
  bool _isEditorVisible = false;

  List<CompanyModel> get companies => _companies;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CompanyModel? get selectedCompany => _selectedCompany;
  bool get isEditorVisible => _isEditorVisible;

  CompaniesManagementViewModel() {
    fetchCompanies();
    fetchCategories();
  }

  void showEditorForNewCompany() {
    _selectedCompany = null;
    _isEditorVisible = true;
    notifyListeners();
  }

  void selectCompanyForEdit(CompanyModel company) {
    _selectedCompany = company;
    _isEditorVisible = true;
    notifyListeners();
  }

  void hideEditor() {
    _selectedCompany = null;
    _isEditorVisible = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _supabaseService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companies = await _supabaseService.getCompanies();
    } catch (e) {
      _errorMessage = 'Failed to load companies. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ عدّلت: أضفت coverBytes parameter
  Future<void> addCompany(
    Map<String, dynamic> companyData,
    Uint8List? logoBytes,
    Uint8List? coverBytes, // ✅ جديد
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (logoBytes == null) {
        throw Exception('Logo image is required.');
      }

      // رفع اللوجو
      final logoPath = 'logos/${DateTime.now().millisecondsSinceEpoch}.png';
      final logoUrl = await _supabaseService.uploadImageBytes(
        logoBytes,
        logoPath,
      );
      companyData['logo_url'] = logoUrl;

      // ✅ رفع الـ Cover لو موجود
      if (coverBytes != null) {
        final coverPath = 'covers/${DateTime.now().millisecondsSinceEpoch}.png';
        final coverUrl = await _supabaseService.uploadImageBytes(
          coverBytes,
          coverPath,
        );
        companyData['cover_image_url'] = coverUrl;
      }

      await _supabaseService.addCompany(companyData);
      _companies = await _supabaseService.getCompanies();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ عدّلت: أضفت coverBytes parameter
  Future<void> updateCompany(
    int id,
    Map<String, dynamic> companyData,
    Uint8List? logoBytes,
    Uint8List? coverBytes, // ✅ جديد
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // رفع لوجو جديد لو اتغيّر
      if (logoBytes != null) {
        final logoPath = 'logos/${DateTime.now().millisecondsSinceEpoch}.png';
        final logoUrl = await _supabaseService.uploadImageBytes(
          logoBytes,
          logoPath,
        );
        companyData['logo_url'] = logoUrl;
      }

      // ✅ رفع cover جديد لو اتغيّر
      if (coverBytes != null) {
        final coverPath = 'covers/${DateTime.now().millisecondsSinceEpoch}.png';
        final coverUrl = await _supabaseService.uploadImageBytes(
          coverBytes,
          coverPath,
        );
        companyData['cover_image_url'] = coverUrl;
      }

      await _supabaseService.updateCompany(id, companyData);
      _companies = await _supabaseService.getCompanies();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCompany(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteCompany(id);
      _companies = await _supabaseService.getCompanies();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
