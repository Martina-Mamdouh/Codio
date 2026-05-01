import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';

class DashboardViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  bool isLoading = false;
  List<Map<String, dynamic>> topDeals = [];
  List<Map<String, dynamic>> companyPerformance = [];
  List<Map<String, dynamic>> bannerPerformance = [];
  List<Map<String, dynamic>> adPerformance = [];
  List<Map<String, dynamic>> socialBreakdown = [];

  List<Map<String, dynamic>> get topMapCompanies {
    final list = List<Map<String, dynamic>>.from(companyPerformance);
    list.sort((a, b) {
      final clicksA = a['map_click_count'] as int? ?? 0;
      final clicksB = b['map_click_count'] as int? ?? 0;
      return clicksB.compareTo(clicksA);
    });
    return list;
  }

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
        _analyticsService.getTopDealsByViews(limit: 100),
        _analyticsService.getCompanyPerformance(),
        _analyticsService.getBannerPerformance(),
        _analyticsService.getSocialPlatformBreakdown(),
        _analyticsService.getUniqueAnalytics(),
        _analyticsService.getAdPerformance(),
      ]);

      final rawTopDeals = results[0];
      final rawCompanyPerformance = results[1];
      socialBreakdown = results[3];
      final uniqueStats = results[4];
      final rawBannerPerformance = results[2];
      final rawAdPerformance = results[5];

      // Merge unique stats dynamically to avoid breaking existing DB schemas via dropped views
      topDeals = rawTopDeals.map((rawDeal) {
        final deal = Map<String, dynamic>.from(rawDeal);
        final dealId = deal['deal_id'] ?? deal['id'];
        if (dealId != null) {
          final viewStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'deal' &&
                s['entity_id'] == dealId &&
                s['event_type'] == 'deal_view',
          );
          deal['unique_viewers'] = viewStats.isNotEmpty
              ? viewStats.first['unique_users']
              : 0;

          final copyStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'deal' &&
                s['entity_id'] == dealId &&
                s['event_type'] == 'code_copy',
          );
          deal['unique_copiers'] = copyStats.isNotEmpty
              ? copyStats.first['unique_users']
              : 0;

          final linkStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'deal' &&
                s['entity_id'] == dealId &&
                s['event_type'] == 'link_open',
          );
          deal['unique_link_openers'] = linkStats.isNotEmpty
              ? linkStats.first['unique_users']
              : 0;
        }
        return deal;
      }).toList();

      companyPerformance = rawCompanyPerformance.map((rawCompany) {
        final company = Map<String, dynamic>.from(rawCompany);
        final companyId = company['id'];
        if (companyId != null) {
          final viewStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'company' &&
                s['entity_id'] == companyId &&
                s['event_type'] == 'company_view',
          );
          company['unique_page_viewers'] = viewStats.isNotEmpty
              ? viewStats.first['unique_users']
              : 0;

          final mapClickStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'company' &&
                s['entity_id'] == companyId &&
                s['event_type'] == 'map_click',
          );
          company['unique_map_clickers'] = mapClickStats.isNotEmpty
              ? mapClickStats.first['unique_users']
              : 0;
        }
        return company;
      }).toList();

      bannerPerformance = rawBannerPerformance.map((rawBanner) {
        final banner = Map<String, dynamic>.from(rawBanner);
        final bannerId = banner['banner_id'];
        if (bannerId != null) {
          final viewStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'banner' &&
                s['entity_id'] == bannerId &&
                s['event_type'] == 'banner_impression',
          );
          banner['unique_viewers'] = viewStats.isNotEmpty
              ? viewStats.first['unique_users']
              : 0;

          final clickStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'banner' &&
                s['entity_id'] == bannerId &&
                s['event_type'] == 'banner_click',
          );
          banner['unique_clickers'] = clickStats.isNotEmpty
              ? clickStats.first['unique_users']
              : 0;
        }
        return banner;
      }).toList();

      adPerformance = rawAdPerformance.map((rawAd) {
        final ad = Map<String, dynamic>.from(rawAd);
        final adId = ad['ad_id'];
        if (adId != null) {
          final viewStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'ad' &&
                s['entity_id'] == adId &&
                s['event_type'] == 'ad_impression',
          );
          ad['unique_viewers'] = viewStats.isNotEmpty
              ? viewStats.first['unique_users']
              : 0;

          final clickStats = uniqueStats.where(
            (s) =>
                s['entity_type'] == 'ad' &&
                s['entity_id'] == adId &&
                s['event_type'] == 'ad_click',
          );
          ad['unique_clickers'] = clickStats.isNotEmpty
              ? clickStats.first['unique_users']
              : 0;
        }
        return ad;
      }).toList();

      // Calculate simple totals from performance if needed
      totalViews = companyPerformance.fold(
        0,
        (sum, item) => sum + (item['page_views'] as int? ?? 0),
      );

      // Total Clicks includes all types of company level clicks
      int companyClicks = companyPerformance.fold(
        0,
        (sum, item) =>
            sum +
            (item['social_clicks'] as int? ?? 0) +
            (item['website_click_count'] as int? ?? 0) +
            (item['phone_click_count'] as int? ?? 0),
      );

      int bannerClicks = bannerPerformance.fold(
        0,
        (sum, item) => sum + (item['clicks'] as int? ?? 0),
      );

      int adClicks = adPerformance.fold(
        0,
        (sum, item) => sum + (item['clicks'] as int? ?? 0),
      );

      totalClicks = companyClicks + bannerClicks + adClicks;

      totalMapClicks = companyPerformance.fold(
        0,
        (sum, item) => sum + (item['map_click_count'] as int? ?? 0),
      );

      // Get copy totals from top deals (as an approximation or better query)
      totalCopies = topDeals.fold(
        0,
        (sum, item) => sum + (item['code_copies'] as int? ?? 0),
      );
    } catch (e) {
      debugPrint('❌ Error loading dashboard analytics: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

