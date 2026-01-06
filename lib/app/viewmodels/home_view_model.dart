import 'package:flutter/material.dart';
import '../../core/models/banner_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';

class HomeViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<BannerModel> banners = [];
  List<DealModel> newDeals = [];
  List<DealModel> featuredDeals = [];
  List<DealModel> expiringDeals = [];
  List<DealModel> studentDeals = [];
  List<DealModel> entertainmentDeals = [];

  bool isLoading = false;
  String? errorMessage;

  HomeViewModel() {
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading = true;
    errorMessage = null;
    if (hasListeners) {
      notifyListeners();
    }

    try {
      // 1. Fetch Banners and All Deals concurrently
      final results = await Future.wait([
        _supabaseService.getBanners(),
        _supabaseService.getDeals(),
      ]);

      banners = results[0] as List<BannerModel>;
      final allDeals = results[1] as List<DealModel>;

      // 2. Clear lists
      studentDeals = [];
      expiringDeals = [];
      featuredDeals = [];
      newDeals = [];
      entertainmentDeals = [];

      final Set<int> usedDealIds = {};

      // 3. Define Logic Helpers
      final now = DateTime.now();
      final sevenDaysLater = now.add(const Duration(days: 7));

      bool isEndingSoon(DealModel d) {
        return d.expiresAt.isAfter(now) && d.expiresAt.isBefore(sevenDaysLater);
      }

      // 4. Apply Display Priority (Highest -> Lowest)

      // Priority 1: Student Deals
      // Condition: is_for_students = true
      studentDeals = allDeals.where((d) => d.isForStudents).toList();
      // Sort student deals if needed (e.g. by created_at)
      studentDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Mark as used
      usedDealIds.addAll(studentDeals.map((d) => d.id));

      // Priority 1.5: Entertainment Deals
      // Condition: category_name == 'ترفيه' or 'أنشطة ترفيهية'
      entertainmentDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        final cat = d.categoryName?.toLowerCase() ?? '';
        return cat.contains('ترفيه') || cat.contains('أنشطة');
      }).toList();
      entertainmentDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      usedDealIds.addAll(entertainmentDeals.map((d) => d.id));

      // Priority 2: Ending Soon Deals
      // Condition: expires_at within threshold
      // Deduplication: Must not be already shown (i.e. not in student deals)
      expiringDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        return isEndingSoon(d);
      }).toList();
      // Sort by expiration (soonest first)
      expiringDeals.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
      // Mark as used
      usedDealIds.addAll(expiringDeals.map((d) => d.id));

      // Priority 3: Featured Deals
      // Condition: is_featured = true AND is_for_students = false
      // Deduplication: Must not be already shown
      featuredDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        // User Rule: EXCLUDE student deals (already handled by priority but explicit check matches rule)
        if (d.isForStudents) return false;
        return d.isFeatured;
      }).toList();
      // Sort by created_at
      featuredDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Mark as used
      usedDealIds.addAll(featuredDeals.map((d) => d.id));

      // Priority 4: New Deals
      // Condition: is_new = true (Assuming "New" means recent/all remaining) AND is_for_students = false
      // Deduplication: Must not be already shown
      newDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        if (d.isForStudents) return false;
        // Ideally we check implicit "is_new" or just take remaining recent ones
        return true;
      }).toList();
      // Sort by created_at
      newDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 5. Limited Display (Limit to 5)
      // Note: We apply limit AFTER filtering/sorting to get the best 5 for each section
      studentDeals = studentDeals.take(5).toList();
      entertainmentDeals = entertainmentDeals.take(5).toList();
      expiringDeals = expiringDeals.take(5).toList();
      featuredDeals = featuredDeals.take(5).toList();
      newDeals = newDeals.take(5).toList();
    } catch (e) {
      errorMessage = 'حدث خطأ أثناء تحميل البيانات، تأكد من اتصالك بالإنترنت';
      debugPrint('Error in HomeViewModel: $e');
    } finally {
      isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }
}
