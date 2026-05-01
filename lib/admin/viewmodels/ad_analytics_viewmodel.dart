import 'package:flutter/foundation.dart';
import '../../core/services/analytics_service.dart';

enum AdAnalyticsFilter { today, week, month, all }

class AdAnalyticsViewModel extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  final int adId;
  final String adImageLink;
  final bool isActive;

  AdAnalyticsViewModel({
    required this.adId,
    required this.adImageLink,
    required this.isActive,
  }) {
    loadData();
  }

  bool isLoading = false;
  String? errorMessage;

  AdAnalyticsFilter selectedFilter = AdAnalyticsFilter.all;

  // Ad stats
  Map<String, dynamic> adStats = {};

  /// Human-readable label for selected filter
  String get filterLabel {
    switch (selectedFilter) {
      case AdAnalyticsFilter.today:
        return 'اليوم';
      case AdAnalyticsFilter.week:
        return 'هذا الأسبوع';
      case AdAnalyticsFilter.month:
        return 'هذا الشهر';
      case AdAnalyticsFilter.all:
        return 'كل الوقت';
    }
  }

  /// Date threshold for current filter (null = no filter).
  DateTime? get _fromDate {
    final now = DateTime.now(); // local time of user's device
    switch (selectedFilter) {
      case AdAnalyticsFilter.today:
        return DateTime(now.year, now.month, now.day); // midnight local
      case AdAnalyticsFilter.week:
        return now.subtract(const Duration(days: 7));
      case AdAnalyticsFilter.month:
        return now.subtract(const Duration(days: 30));
      case AdAnalyticsFilter.all:
        return null;
    }
  }

  Future<void> loadData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      adStats = await _analyticsService.getAdFilteredStats(adId, from: _fromDate);
    } catch (e) {
      errorMessage = 'حدث خطأ في تحميل البيانات';
      debugPrint('❌ AdAnalyticsViewModel error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeFilter(AdAnalyticsFilter filter) async {
    if (selectedFilter == filter) return;
    selectedFilter = filter;
    
    isLoading = true;
    notifyListeners();
    try {
      adStats = await _analyticsService.getAdFilteredStats(
        adId,
        from: _fromDate,
      );
    } catch (e) {
      debugPrint('❌ Error changing filter: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
