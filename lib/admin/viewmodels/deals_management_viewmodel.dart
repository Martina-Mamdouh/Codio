import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/models/deal_model.dart';
import '../../core/models/category_model.dart';
import '../../core/services/supabase_service.dart';

class DealsManagementViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<DealModel> _deals = [];
  List<CategoryModel> _categories = []; // ✨ جديد
  bool _isLoading = false;
  String? _errorMessage;
  DealModel? _selectedDeal;
  bool _isEditorVisible = false;

  List<DealModel> get deals => _deals;
  List<CategoryModel> get categories => _categories; // ✨ جديد
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DealModel? get selectedDeal => _selectedDeal;
  bool get isEditorVisible => _isEditorVisible;

  DealsManagementViewModel() {
    fetchDeals();
    fetchCategories(); // ✨ جديد
  }

  void showEditorForNewDeal() {
    _selectedDeal = null;
    _isEditorVisible = true;
    notifyListeners();
  }

  void selectDealForEdit(DealModel deal) {
    _selectedDeal = deal;
    _isEditorVisible = true;
    notifyListeners();
  }

  void hideEditor() {
    _selectedDeal = null;
    _isEditorVisible = false;
    notifyListeners();
  }

  // ✨ جلب الفئات للـ dropdown
  Future<void> fetchCategories() async {
    try {
      _categories = await _supabaseService.getCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchDeals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _deals = await _supabaseService.getDeals();
    } catch (e) {
      _errorMessage = 'Failed to load deals. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeal(
    Map<String, dynamic> dealData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (imageBytes == null) {
        throw Exception('Image is required.');
      }

      final imagePath = 'deals/${DateTime.now().millisecondsSinceEpoch}.png';
      final imageUrl = await _supabaseService.uploadImageBytes(
        imageBytes,
        imagePath,
      );
      dealData['image_url'] = imageUrl;

      await _supabaseService.addDeal(dealData);
      _deals = await _supabaseService.getDeals();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDeal(
    int id,
    Map<String, dynamic> dealData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (imageBytes != null) {
        final imagePath = 'deals/${DateTime.now().millisecondsSinceEpoch}.png';
        final imageUrl = await _supabaseService.uploadImageBytes(
          imageBytes,
          imagePath,
        );
        dealData['image_url'] = imageUrl;
      }

      await _supabaseService.updateDeal(id, dealData);
      _deals = await _supabaseService.getDeals();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDeal(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteDeal(id);
      _deals = await _supabaseService.getDeals();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
