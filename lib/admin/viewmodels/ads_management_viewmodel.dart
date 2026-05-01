import 'package:flutter/foundation.dart';
import '../../core/models/ad_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';

class AdsManagementViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<AdModel> _ads = [];
  List<DealModel> _deals = [];
  bool _isLoading = false;
  String? _errorMessage;
  AdModel? _selectedAd;
  bool _isEditorVisible = false;

  List<AdModel> get ads => _ads;
  List<DealModel> get deals => _deals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AdModel? get selectedAd => _selectedAd;
  bool get isEditorVisible => _isEditorVisible;

  AdsManagementViewModel() {
    fetchAds();
    fetchDeals();
  }

  void showEditorForNewAd() {
    _selectedAd = null;
    _isEditorVisible = true;
    notifyListeners();
  }

  void selectAdForEdit(AdModel ad) {
    _selectedAd = ad;
    _isEditorVisible = true;
    notifyListeners();
  }

  void hideEditor() {
    _selectedAd = null;
    _isEditorVisible = false;
    notifyListeners();
  }

  String? getDealNameById(int dealId) {
    try {
      return _deals.firstWhere((d) => d.id == dealId).title;
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchDeals() async {
    try {
      _deals = await _supabaseService.getDeals(onlyVisible: false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching deals: $e');
    }
  }

  Future<void> fetchAds() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ads = await _supabaseService.getAds();
    } catch (e) {
      _errorMessage = 'Failed to load ads. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAd(
    Map<String, dynamic> adData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (imageBytes == null) {
        throw Exception('Image is required.');
      }

      final imagePath = 'ads/${DateTime.now().millisecondsSinceEpoch}.png';
      final imageUrl = await _supabaseService.uploadImageBytes(
        imageBytes,
        imagePath,
      );
      adData['image_link'] = imageUrl;

      await _supabaseService.addAd(adData);
      await fetchAds();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAd(
    int id,
    Map<String, dynamic> adData,
    Uint8List? imageBytes,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (imageBytes != null) {
        final imagePath = 'ads/${DateTime.now().millisecondsSinceEpoch}.png';
        final imageUrl = await _supabaseService.uploadImageBytes(
          imageBytes,
          imagePath,
        );
        adData['image_link'] = imageUrl;
      }

      await _supabaseService.updateAd(id, adData);
      await fetchAds();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAd(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.deleteAd(id);
      await fetchAds();
      hideEditor();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
