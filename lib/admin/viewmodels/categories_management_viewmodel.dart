import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/models/category_model.dart';
import '../../core/services/supabase_service.dart';

class CategoriesManagementViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  CategoryModel? _selectedCategory;
  bool _isEditorVisible = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CategoryModel? get selectedCategory => _selectedCategory;
  bool get isEditorVisible => _isEditorVisible;

  CategoriesManagementViewModel() {
    fetchCategories();
  }

  void showEditorForNewCategory() {
    _selectedCategory = null;
    _isEditorVisible = true;
    notifyListeners();
  }

  void selectCategoryForEdit(CategoryModel category) {
    _selectedCategory = category;
    _isEditorVisible = true;
    notifyListeners();
  }

  void hideEditor() {
    _selectedCategory = null;
    _isEditorVisible = false;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _supabaseService.getCategories();
    } catch (e) {
      _errorMessage = 'Failed to load categories. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(
    Map<String, dynamic> categoryData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // رفع الصورة (اختياري)
      if (imageBytes != null) {
        final imagePath =
            'categories/${DateTime.now().millisecondsSinceEpoch}.png';
        final imageUrl = await _supabaseService.uploadImageBytes(
          imageBytes,
          imagePath,
        );
        categoryData['image_url'] = imageUrl;
      }

      await _supabaseService.addCategory(categoryData);
      _categories = await _supabaseService.getCategories();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(
    int id,
    Map<String, dynamic> categoryData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // رفع صورة جديدة (لو موجودة)
      if (imageBytes != null) {
        final imagePath =
            'categories/${DateTime.now().millisecondsSinceEpoch}.png';
        final imageUrl = await _supabaseService.uploadImageBytes(
          imageBytes,
          imagePath,
        );
        categoryData['image_url'] = imageUrl;
      }

      await _supabaseService.updateCategory(id, categoryData);
      _categories = await _supabaseService.getCategories();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteCategory(id);
      _categories = await _supabaseService.getCategories();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
