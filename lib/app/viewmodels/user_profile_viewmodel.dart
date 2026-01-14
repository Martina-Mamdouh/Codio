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

  bool get isLoadingProfile => _isLoadingProfile;

  // ===== Actions =====

  bool _isLoadingProfile = false;

  /// تحميل بيانات البروفايل (المفضلات + الشركات المتابعة)
  Future<void> loadProfileData() async {
    if (_isLoadingProfile) return; // Prevent concurrent loads
    
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

    _isLoadingProfile = true;
    try {
      await Future.wait([loadFavoriteDeals(), loadFollowedCompanies()]);
    } finally {
      _isLoadingProfile = false;
    }
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

  // Pending optimistic changes to handle race conditions with slow loads
  final Map<int, CompanyModel> _pendingAdds = {};
  final Set<int> _pendingRemovals = {};

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
      var fetched = await _supabaseService.getFollowedCompanies();
      
      // Merge with pending optimistic changes
      // 1. Remove what was locally removed
      if (_pendingRemovals.isNotEmpty) {
        fetched.removeWhere((c) => _pendingRemovals.contains(c.id));
      }
      
      // 2. Add what was locally added (if not already in fetch)
      if (_pendingAdds.isNotEmpty) {
        for (final pending in _pendingAdds.values) {
          if (!fetched.any((c) => c.id == pending.id)) {
            fetched.add(pending);
          }
        }
      }
      
      // Clear pending queues now that we've synced?
      // Actually, to be safe against very fast subsequent loads, keep them until we are sure?
      // For now, clearing them is standard "Sync complete" logic. 
      // But if the server fetch didn't catch the latest insert yet, clearing them might lose the optimistic state on NEXT load?
      // No, because NEXT load will catch it. The race is usually against the *first* in-flight load.
      _pendingAdds.clear();
      _pendingRemovals.clear();

      followedCompanies = fetched;
      followedCompaniesCount = followedCompanies.length;
    } catch (e) {
      errorMessage = 'خطأ في تحميل الشركات: $e';
      debugPrint('❌ Error loading followed companies: $e');
      // On error, we arguably keep the local state which is `followedCompanies` currently.
    } finally {
      notifyListeners();
    }
  }

  /// مسح كل المفضّلات والمتابعات من الذاكرة
  void clearFavorites() {
    _favoriteDealIds.clear();
    favoriteDeals = [];
    followedCompanies = [];
    followedCompaniesCount = 0;
    _pendingAdds.clear();
    _pendingRemovals.clear();
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
        // For now, load whole list.
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

    final exists = followedCompanies.any((c) => c.id == companyId);

    if (exists) {
      // Unfollow
      followedCompanies.removeWhere((c) => c.id == companyId);
      followedCompaniesCount = followedCompanies.length;
      
      _pendingAdds.remove(companyId);
      _pendingRemovals.add(companyId);
      
      notifyListeners();
    } else {
      // Follow
      if (company != null) {
        followedCompanies.add(company);
        followedCompaniesCount = followedCompanies.length;
        
        _pendingRemovals.remove(companyId);
        _pendingAdds[companyId] = company;
        
        notifyListeners();
      }
    }

    try {
      final isFollowedNow = await _supabaseService.toggleCompanyFollow(companyId);
      return isFollowedNow;
    } catch (e) {
       await loadFollowedCompanies(); 
       return exists;
    }
  }

  /// تحديث الحالة محلياً فقط 
  void updateFollowStatusLocal(CompanyModel company, bool isFollowing) {
    final exists = followedCompanies.any((c) => c.id == company.id);

    if (isFollowing && !exists) {
      followedCompanies.add(company);
      followedCompaniesCount = followedCompanies.length;
      
      _pendingRemovals.remove(company.id);
      _pendingAdds[company.id] = company;
      
      notifyListeners();
    } else if (!isFollowing && exists) {
      followedCompanies.removeWhere((c) => c.id == company.id);
      followedCompaniesCount = followedCompanies.length;
      
      _pendingAdds.remove(company.id);
      _pendingRemovals.add(company.id);
      
      notifyListeners();
    }
  }
}
