import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/models/banner_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';

class BannersManagementViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<BannerModel> _banners = [];
  List<DealModel> _deals =
      []; // ✨ جديد (اختياري - للمساعدة في عرض أسماء العروض)
  bool _isLoading = false;
  String? _errorMessage;
  BannerModel? _selectedBanner;
  bool _isEditorVisible = false;

  List<BannerModel> get banners => _banners;
  List<DealModel> get deals => _deals; // ✨ جديد
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  BannerModel? get selectedBanner => _selectedBanner;
  bool get isEditorVisible => _isEditorVisible;

  BannersManagementViewModel() {
    fetchBanners();
    fetchDeals(); // ✨ جديد (اختياري - للمساعدة)
  }

  void showEditorForNewBanner() {
    _selectedBanner = null;
    _isEditorVisible = true;
    notifyListeners();
  }

  void selectBannerForEdit(BannerModel banner) {
    _selectedBanner = banner;
    _isEditorVisible = true;
    notifyListeners();
  }

  void hideEditor() {
    _selectedBanner = null;
    _isEditorVisible = false;
    notifyListeners();
  }

  // ✨ جلب العروض (اختياري - للمساعدة في عرض أسماء العروض)
  Future<void> fetchDeals() async {
    try {
      _deals = await _supabaseService.getDeals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching deals: $e');
    }
  }

  Future<void> fetchBanners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _banners = await _supabaseService.getBanners();
    } catch (e) {
      _errorMessage = 'Failed to load banners. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBanner(
    Map<String, dynamic> bannerData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (imageBytes == null) {
        throw Exception('Image is required.');
      }

      final imagePath = 'banners/${DateTime.now().millisecondsSinceEpoch}.png';
      final imageUrl = await _supabaseService.uploadImageBytes(
        imageBytes,
        imagePath,
      );
      bannerData['image_url'] = imageUrl;

      await _supabaseService.addBanner(bannerData);
      _banners = await _supabaseService.getBanners();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBanner(
    int id,
    Map<String, dynamic> bannerData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (imageBytes != null) {
        final imagePath =
            'banners/${DateTime.now().millisecondsSinceEpoch}.png';
        final imageUrl = await _supabaseService.uploadImageBytes(
          imageBytes,
          imagePath,
        );
        bannerData['image_url'] = imageUrl;
      }

      await _supabaseService.updateBanner(id, bannerData);
      _banners = await _supabaseService.getBanners();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBanner(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteBanner(id);
      _banners = await _supabaseService.getBanners();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✨ Helper method: جلب اسم العرض من الـ ID
  String? getDealNameById(int? dealId) {
    if (dealId == null) return null;
    try {
      return _deals.firstWhere((deal) => deal.id == dealId).title;
    } catch (e) {
      return null;
    }
  }
}
