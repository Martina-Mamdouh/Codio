import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/company_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/models/category_model.dart'; // ✅ Import CategoryModel
import '../../core/services/supabase_service.dart';
import '../../core/services/analytics_service.dart';

class CompanyProfileViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final int companyId;

  CompanyModel? company;
  List<DealModel> deals = [];
  List<CategoryModel> allCategories = []; // ✅ قائمة بكل التصنيفات

  bool isLoading = false;
  bool isDealsLoading = false;
  bool isFollowLoading = false;
  bool isFollowed = false;
  String? errorMessage;

  // Counters for interaction tracking
  int socialClicks = 0;
  int mapClicks = 0;
  int companyPageViews = 0;

  void incrementSocialClicks([String? platform]) {
    socialClicks++;
    _analyticsService.trackSocialClick(companyId, platform: platform);
    notifyListeners();
  }

  void incrementMapClicks() {
    mapClicks++;
    _analyticsService.trackMapClick(companyId);
    notifyListeners();
  }

  void incrementCompanyPageViews() {
    companyPageViews++;
    _analyticsService.trackCompanyView(companyId);
    notifyListeners();
  }

  // قناة Realtime
  RealtimeChannel? _companyChannel;

  CompanyProfileViewModel(this.companyId, {CompanyModel? initialCompany}) {
    if (initialCompany != null) {
      company = initialCompany;
      // We rely on loadCompanyData or local check for isFollowed
    }
    
    if (kDebugMode) {
      print('CompanyProfileViewModel created with companyId: $companyId');
    }
    incrementCompanyPageViews();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    // If we have initial data, don't show full screen loader
    if (company == null) {
      isLoading = true;
      notifyListeners();
    }
    
    errorMessage = null;

    try {
      // ✅ Fetch company, deal count, and category name in one optimized call
      company = await _supabaseService.getCompanyById(companyId);
      
      // Fetch all categories for tags
      allCategories = await _supabaseService.getCategories();

      if (company == null) {
        errorMessage = 'لم يتم العثور على هذه الشركة';
        return;
      }

      // Fetch deals and check follow status concurrently
      final results = await Future.wait([
        _supabaseService.getCompanyDeals(companyId),
        _supabaseService.isCompanyFollowed(companyId),
      ]);

      deals = results[0] as List<DealModel>;
      isFollowed = results[1] as bool;

      // Update local click counts without extra notify
      final stats = await _analyticsService.getCompanyAnalytics(companyId);
      if (stats != null) {
        companyPageViews = stats['page_view_count'] ?? 0;
        socialClicks = stats['social_click_count'] ?? 0;
        mapClicks = stats['map_click_count'] ?? 0;
      }

      
      // ... existing code ...

      _subscribeToCompany();
    } catch (e) {
      // ... error handling ...
    } finally {
      isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  // ✅ Call this from View to sync with global UserProfile state
  void checkFollowStatus(bool isGloballyFollowed) {
    if (isFollowed != isGloballyFollowed) {
       isFollowed = isGloballyFollowed;
       // Simply update the local flag without triggering a full reload or notify unless changed
       // actually we should notify if it changes visual state
       notifyListeners();
    }
  }

  // جلب الإحصائيات الحقيقية من قاعدة البيانات
  Future<void> loadCompanyStats() async {
    try {
      final stats = await _analyticsService.getCompanyAnalytics(companyId);
      if (stats != null) {
        companyPageViews = stats['page_view_count'] ?? 0;
        socialClicks = stats['social_click_count'] ?? 0;
        mapClicks = stats['map_click_count'] ?? 0;
        if (hasListeners) notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading company stats: $e');
    }
  }

  // اشتراك Realtime
  void _subscribeToCompany() {
    // إلغاء الاشتراك القديم لو موجود
    if (_companyChannel != null) {
      Supabase.instance.client.removeChannel(_companyChannel!);
    }

    _companyChannel = Supabase.instance.client
        .channel('company_$companyId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'companies',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: companyId,
          ),
          callback: (payload) async {
            if (kDebugMode) {
              print('🔄 Realtime update for company $companyId');
            }

            // بدل ما نعتمد على newRecord الناقص، نعيد تحميل الشركة من الـ Service
            try {
              final refreshed = await _supabaseService.getCompanyById(
                companyId,
              );
              if (refreshed != null) {
                company = refreshed;
                if (hasListeners) {
                  notifyListeners();
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error refreshing company from Realtime: $e');
              }
            }
          },
        )
        .subscribe();
  }

  Future<void> refreshDeals() async {
    if (company == null) return;

    isDealsLoading = true;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      deals = await _supabaseService.getCompanyDeals(companyId);
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshDeals: $e');
      }
    } finally {
      isDealsLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  Future<void> loadDeals() async {
    if (company == null) return;

    try {
      deals = await _supabaseService.getCompanyDeals(companyId);
      if (kDebugMode) {
        print('loadDeals: loaded ${deals.length} deals for company ${company!.name}');
      }
      if (hasListeners) {
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loadDeals: $e');
      }
    }
  }

  Future<bool> toggleFollow() async {
    if (company == null) return false;

    isFollowLoading = true;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('غير مسجل دخول');

      if (isFollowed) {
        // إلغاء المتابعة
        await Supabase.instance.client
            .from('following')
            .delete()
            .eq('user_id', userId)
            .eq('company_id', company!.id);

        isFollowed = false;
        // حدّث العداد محلياً (فوري)
        company = company!.copyWith(
          followersCount: (company!.followersCount ?? 1) - 1,
        );
        
        // Track unfollow
        await _analyticsService.trackCompanyFollow(company!.id, isFollowed: false);
      } else {
        // متابعة
        await Supabase.instance.client.from('following').insert({
          'user_id': userId,
          'company_id': company!.id,
        });

        isFollowed = true;
        // حدّث العداد محلياً (فوري)
        company = company!.copyWith(
          followersCount: (company!.followersCount ?? 0) + 1,
        );
        
        // Track follow
        await _analyticsService.trackCompanyFollow(company!.id, isFollowed: true);
      }

      if (hasListeners) {
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('خطأ في المتابعة: $e');
      return false;
    } finally {
      isFollowLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    // إلغاء اشتراك Realtime (مهم جداً!)
    if (_companyChannel != null) {
      Supabase.instance.client.removeChannel(_companyChannel!);
      _companyChannel = null;
    }
    super.dispose();
  }

  // ✅ Helper to get category names (Sorted: Primary First)
  List<String> getCompanyCategoryNames() {
    if (company == null ||
        company!.categoryIds == null ||
        company!.categoryIds!.isEmpty) {
      return [];
    }

    final matchingCategories = allCategories
        .where((cat) => company!.categoryIds!.contains(cat.id))
        .toList();

    // Sort: Primary category comes first
    if (company!.primaryCategoryId != null) {
      matchingCategories.sort((a, b) {
        if (a.id == company!.primaryCategoryId) return -1;
        if (b.id == company!.primaryCategoryId) return 1;
        return 0;
      });
    }

    return matchingCategories.map((cat) => cat.name).toList();
  }
}
