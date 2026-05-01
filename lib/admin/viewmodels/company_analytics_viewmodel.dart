import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';

enum AnalyticsFilter { today, week, month, all }

class CompanyAnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  final int companyId;
  final String companyName;
  final String? companyLogoUrl;

  CompanyAnalyticsViewModel({
    required this.companyId,
    required this.companyName,
    this.companyLogoUrl,
  }) {
    loadData();
  }

  bool isLoading = false;
  String? errorMessage;

  AnalyticsFilter selectedFilter = AnalyticsFilter.all;

  // Company stats
  Map<String, dynamic> companyStats = {};

  // Deals analytics
  List<Map<String, dynamic>> dealsAnalytics = [];

  /// Human-readable label for selected filter
  String get filterLabel {
    switch (selectedFilter) {
      case AnalyticsFilter.today:
        return 'اليوم';
      case AnalyticsFilter.week:
        return 'هذا الأسبوع';
      case AnalyticsFilter.month:
        return 'هذا الشهر';
      case AnalyticsFilter.all:
        return 'كل الوقت';
    }
  }

  /// Date threshold for current filter (null = no filter).
  /// Dates are in LOCAL time — the service converts to UTC before querying.
  /// This means "today" = today in Baghdad, Turkey, etc. automatically.
  DateTime? get _fromDate {
    final now = DateTime.now(); // local time of user's device
    switch (selectedFilter) {
      case AnalyticsFilter.today:
        return DateTime(now.year, now.month, now.day); // midnight local
      case AnalyticsFilter.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsFilter.month:
        return now.subtract(const Duration(days: 30));
      case AnalyticsFilter.all:
        return null;
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _analyticsService.getCompanyFilteredStats(companyId, from: _fromDate),
        _analyticsService.getCompanyDealsFilteredStats(companyId, from: _fromDate),
      ]);

      companyStats = results[0] as Map<String, dynamic>;
      dealsAnalytics = List<Map<String, dynamic>>.from(results[1] as List);
    } catch (e) {
      errorMessage = 'حدث خطأ في تحميل البيانات';
      debugPrint('❌ CompanyAnalyticsViewModel error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeFilter(AnalyticsFilter filter) async {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    // Only company stats depend on time filter — reload those
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _analyticsService.getCompanyFilteredStats(companyId, from: _fromDate),
        _analyticsService.getCompanyDealsFilteredStats(companyId, from: _fromDate),
      ]);

      companyStats = results[0] as Map<String, dynamic>;
      dealsAnalytics = List<Map<String, dynamic>>.from(results[1] as List);
    } catch (e) {
      debugPrint('❌ Error changing filter: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
