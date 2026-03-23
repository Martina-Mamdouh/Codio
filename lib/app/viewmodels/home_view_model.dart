import 'package:flutter/material.dart';
import '../../core/models/banner_model.dart';
import '../../core/models/deal_model.dart';
import '../../core/services/supabase_service.dart';

class HomeViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<BannerModel> banners = [];
  List<DealModel> newDeals = [];
  List<DealModel> allNewDeals = [];

  List<DealModel> featuredDeals = [];
  List<DealModel> allFeaturedDeals = [];

  List<DealModel> expiringDeals = [];
  List<DealModel> allExpiringDeals = [];

  List<DealModel> studentDeals = [];
  List<DealModel> allStudentDeals = [];

  List<DealModel> entertainmentDeals = [];
  List<DealModel> allEntertainmentDeals = [];

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
      allStudentDeals = [];
      allExpiringDeals = [];
      allFeaturedDeals = [];
      allNewDeals = [];
      allEntertainmentDeals = [];

      // 3. Define Logic Helpers
      final now = DateTime.now();
      final sevenDaysLater = now.add(const Duration(days: 7));

      bool isEndingSoon(DealModel d) {
        return d.expiresAt.isAfter(now) && d.expiresAt.isBefore(sevenDaysLater);
      }

      final Set<int> usedDealIds = {};

      // 4. Apply Display Priority (Highest -> Lowest)

      // Priority 1: Student Deals
      // Condition: is_for_students = true
      allStudentDeals = allDeals.where((d) => d.isForStudents).toList();
      // Sort student deals if needed (e.g. by created_at)
      allStudentDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Mark as used
      usedDealIds.addAll(allStudentDeals.map((d) => d.id));

      // Priority 1.5: Entertainment Deals
      // Condition: category_name == 'ترفيه' or 'أنشطة ترفيهية'
      allEntertainmentDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        final cat = d.categoryName?.toLowerCase() ?? '';
        return cat.contains('ترفيه') || cat.contains('أنشطة');
      }).toList();
      allEntertainmentDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      usedDealIds.addAll(allEntertainmentDeals.map((d) => d.id));

      // Priority 2: Ending Soon Deals
      // Condition: expires_at within threshold
      // Deduplication: Must not be already shown (i.e. not in student deals)
      allExpiringDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        return isEndingSoon(d);
      }).toList();
      // Sort by expiration (soonest first)
      allExpiringDeals.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
      // Mark as used
      usedDealIds.addAll(allExpiringDeals.map((d) => d.id));

      // Priority 3: Featured Deals
      // Condition: is_featured = true AND is_for_students = false
      // Deduplication: Must not be already shown
      allFeaturedDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        // User Rule: EXCLUDE student deals (already handled by priority but explicit check matches rule)
        if (d.isForStudents) return false;
        return d.isFeatured;
      }).toList();
      // Sort by created_at
      allFeaturedDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Mark as used
      usedDealIds.addAll(allFeaturedDeals.map((d) => d.id));

      // Priority 4: New Deals
      // Condition: is_new = true (Assuming "New" means recent/all remaining) AND is_for_students = false
      // Deduplication: Must not be already shown
      allNewDeals = allDeals.where((d) {
        if (usedDealIds.contains(d.id)) return false;
        if (d.isForStudents) return false;
        // Ideally we check implicit "is_new" or just take remaining recent ones
        return true;
      }).toList();
      // Sort by created_at
      allNewDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // 5. Limited Display (Limit to 5)
      // Note: We apply limit AFTER filtering/sorting to get the best 5 for each section
      studentDeals = allStudentDeals.take(5).toList();
      entertainmentDeals = allEntertainmentDeals.take(5).toList();
      expiringDeals = allExpiringDeals.take(5).toList();
      featuredDeals = allFeaturedDeals.take(5).toList();
      newDeals = allNewDeals.take(5).toList();
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
