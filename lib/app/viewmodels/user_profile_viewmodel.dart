import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/company_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/auth_service.dart';

class UserProfileViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AuthService _authService = AuthService();

  // مفضّلات العروض (IDs فقط حالياً)
  final Set<int> _favoriteDealIds = {};
  List<DealModel> favoriteDeals = [];

  // الشركات المتابعة
  List<CompanyModel> followedCompanies = [];
  int followedCompaniesCount = 0;

  bool isLoadingFavorites = false;
  String? errorMessage;

  // ===== Getters =====

  Set<int> get favoriteDealIds => _favoriteDealIds;

  bool get isAuthenticated => _authService.isAuthenticated;

  bool isDealFavorite(int dealId) => _favoriteDealIds.contains(dealId);

  // ===== Actions =====

  /// تحميل بيانات البروفايل (المفضلات + الشركات المتابعة)
  Future<void> loadProfileData() async {
    if (!isAuthenticated) {
      _favoriteDealIds.clear();
      favoriteDeals = [];
      followedCompanies = [];
      followedCompaniesCount = 0;
      if (hasListeners) {
        notifyListeners();
      }
      return;
    }

    await Future.wait([loadFavoriteDeals(), loadFollowedCompanies()]);
  }

  /// تحميل مفضّلات المستخدم من Supabase
  Future<void> loadFavoriteDeals() async {
    if (!isAuthenticated) {
      _favoriteDealIds.clear();
      favoriteDeals = [];
      if (hasListeners) notifyListeners();
      return;
    }

    isLoadingFavorites = true;
    errorMessage = null;
    notifyListeners();

    try {
      favoriteDeals = await _supabaseService.getFavoriteDeals();
      _favoriteDealIds
        ..clear()
        ..addAll(favoriteDeals.map((d) => d.id));
    } catch (e) {
      errorMessage = 'خطأ في تحميل المفضّلات: $e';
      debugPrint('❌ Error loading favorite deals: $e');
    } finally {
      isLoadingFavorites = false;
      notifyListeners();
    }
  }

  /// تحميل الشركات المتابعة من Supabase
  Future<void> loadFollowedCompanies() async {
    if (!isAuthenticated) {
       followedCompanies = [];
       followedCompaniesCount = 0;
       notifyListeners();
       return;
    }

    try {
      // Load full company objects
      followedCompanies = await _supabaseService.getFollowedCompanies();
      followedCompaniesCount = followedCompanies.length;
    } catch (e) {
      errorMessage = 'خطأ في تحميل الشركات: $e';
      debugPrint('❌ Error loading followed companies: $e');
      followedCompanies = [];
      followedCompaniesCount = 0;
    } finally {
      notifyListeners();
    }
  }

  /// مسح كل المفضّلات والمتابعات من الذاكرة (مثلاً عند تسجيل خروج)
  void clearFavorites() {
    _favoriteDealIds.clear();
    favoriteDeals = [];
    followedCompanies = [];
    followedCompaniesCount = 0;
    if (hasListeners) {
      notifyListeners();
    }
  }

  /// Run diagnostics
  Future<String> runDiagnostics() async {
    return _supabaseService.runDiagnostics();
  }

  /// Toggle لمفضّلة عرض واحد (مع تحديث الحالة محلياً)
  Future<bool> toggleFavoriteForDeal(int dealId) async {
    if (!isAuthenticated) {
      debugPrint('❌ Cannot toggle favorite: user not authenticated');
      return false;
    }

    final wasFavorite = _favoriteDealIds.contains(dealId);

    // Optimistic update
    if (wasFavorite) {
      _favoriteDealIds.remove(dealId);
      favoriteDeals.removeWhere((d) => d.id == dealId);
      notifyListeners();
    } else {
      _favoriteDealIds.add(dealId);
      notifyListeners();
      
      // Attempt to fetch the deal to add to the list
      try {
         final deal = await _supabaseService.getDealById(dealId);
         if (deal != null) {
           // check if still favorited (user might have toggled back quickly)
           if (_favoriteDealIds.contains(dealId) && !favoriteDeals.any((d) => d.id == dealId)) {
             favoriteDeals.add(deal);
             notifyListeners();
           }
         }
      } catch (e) {
        debugPrint('⚠️ Error fetching deal for favorite list sync: $e');
      }
    }

    final success = await _supabaseService.toggleDealFavorite(dealId);

    if (!success) {
      // Revert if DB fail
      if (wasFavorite) {
        _favoriteDealIds.add(dealId);
        // We can't easily restore the deleted deal object unless we cached it. 
        // For now, reload whole list or just ignore deep restore.
        await loadFavoriteDeals(); 
      } else {
        _favoriteDealIds.remove(dealId);
        favoriteDeals.removeWhere((d) => d.id == dealId);
      }
      notifyListeners();
    }

    return success;
  }

  /// Toggle لمتابعة شركة
  Future<bool> toggleCompanyFollow(int companyId, {CompanyModel? company}) async {
    if (!isAuthenticated) return false;

    // Optimistic check: is it currently in our list?
    final exists = followedCompanies.any((c) => c.id == companyId);

    if (exists) {
      followedCompanies.removeWhere((c) => c.id == companyId);
      followedCompaniesCount = followedCompanies.length;
      notifyListeners();
    } else {
      // Adding
      if (company != null) {
        followedCompanies.add(company);
        followedCompaniesCount = followedCompanies.length;
        notifyListeners();
      }
      // If company is null, we can't add optimistically to the list (unless we fetch it)
      // We will rely on loadFollowedCompanies below, or we could fetch it here similarly to deal.
    }

    try {
      final isFollowedNow = await _supabaseService.toggleCompanyFollow(companyId);
      
      // Sync with server to be safe
      // If we didn't have the company model to add optimistically, this load will pop it in.
      await loadFollowedCompanies();
      
      return isFollowedNow;
    } catch (e) {
      await loadFollowedCompanies(); // Revert on error
      return exists; // Return original state
    }
  }
}
