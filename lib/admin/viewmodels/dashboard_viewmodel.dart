import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  bool isLoading = false;
  List<Map<String, dynamic>> topDeals = [];
  List<Map<String, dynamic>> companyPerformance = [];
  List<Map<String, dynamic>> bannerPerformance = [];
  List<Map<String, dynamic>> socialBreakdown = [];
  
  // Aggregate stats
  int totalViews = 0;
  int totalCopies = 0;
  int totalClicks = 0;
  int totalMapClicks = 0;

  DashboardViewModel() {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch everything in parallel
      final results = await Future.wait([
        _analyticsService.getTopDealsByViews(limit: 5),
        _analyticsService.getCompanyPerformance(),
        _analyticsService.getBannerPerformance(),
        _analyticsService.getSocialPlatformBreakdown(),
      ]);

      topDeals = results[0];
      companyPerformance = results[1];
      bannerPerformance = results[2];
      socialBreakdown = results[3];

      // Calculate simple totals from performance if needed
      totalViews = companyPerformance.fold(0, (sum, item) => sum + (item['page_views'] as int? ?? 0));
      
      // Total Clicks includes all types of company level clicks
      int companyClicks = companyPerformance.fold(0, (sum, item) => 
        sum + (item['social_clicks'] as int? ?? 0) + 
        (item['website_click_count'] as int? ?? 0) + 
        (item['phone_click_count'] as int? ?? 0)
      );
      
      int bannerClicks = bannerPerformance.fold(0, (sum, item) => sum + (item['clicks'] as int? ?? 0));
      
      totalClicks = companyClicks + bannerClicks;

      totalMapClicks = companyPerformance.fold(0, (sum, item) => sum + (item['map_click_count'] as int? ?? 0));
      
      // Get copy totals from top deals (as an approximation or better query)
      totalCopies = topDeals.fold(0, (sum, item) => sum + (item['code_copies'] as int? ?? 0));

    } catch (e) {
      debugPrint('❌ Error loading dashboard analytics: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
