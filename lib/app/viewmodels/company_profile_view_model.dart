import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/company_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/models/category_model.dart'; // ✅ Import CategoryModel
import '../../core/services/supabase_service.dart';

class CompanyProfileViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
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

  void incrementSocialClicks() {
    socialClicks++;
    notifyListeners();
  }

  void incrementMapClicks() {
    mapClicks++;
    notifyListeners();
  }

  void incrementCompanyPageViews() {
    companyPageViews++;
    notifyListeners();
  }

  // قناة Realtime
  RealtimeChannel? _companyChannel;

  CompanyProfileViewModel(this.companyId) {
    if (kDebugMode) {
      print('CompanyProfileViewModel created with companyId: $companyId');
    }
    incrementCompanyPageViews();
    loadCompanyData();
  }

  Future<void> loadCompanyData() async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      // بيانات الشركة (من الـ Service اللي بيرجع category_name و deal_count)
      company = await _supabaseService.getCompanyById(companyId);
      if (kDebugMode) {
        print('loadCompanyData: company loaded: ${company?.name ?? 'null'} for id $companyId');
      }

      // ✅ جلب كل التصنيفات عشان نعرض ال tags
      allCategories = await _supabaseService.getCategories();

      if (company == null) {
        errorMessage = 'لم يتم العثور على هذه الشركة';
        isLoading = false;
        if (hasListeners) {
          notifyListeners();
        }
        return;
      }

      // عروض الشركة
      deals = await _supabaseService.getCompanyDeals(companyId);
      if (kDebugMode) {
        print('loadCompanyData: loaded ${deals.length} deals for company ${company!.name}');
      }

      // حالة المتابعة
      isFollowed = await _supabaseService.isCompanyFollowed(companyId);

      // اشترك في Realtime بعد التحميل
      _subscribeToCompany();
    } catch (e) {
      if (kDebugMode) {
        print('Error loadCompanyData: $e');
      }
      errorMessage = 'حدث خطأ أثناء تحميل بيانات الشركة';
    } finally {
      isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
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

  Future<void> toggleFollow() async {
    if (company == null) return;

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
      }

      if (hasListeners) {
        notifyListeners();
      }
      // Realtime + التريجر هيأكدوا القيمة من السيرفر بعد كده
    } catch (e) {
      debugPrint('خطأ في المتابعة: $e');
      // اختياري: أعد التحميل من السيرفر عند فشل
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
