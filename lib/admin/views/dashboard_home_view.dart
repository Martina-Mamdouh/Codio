import 'package:flutter/material.dart';
import 'package:kodio_app/admin/viewmodels/deals_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/companies_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/banners_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/categories_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/dashboard_viewmodel.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class DashboardHomeView extends StatefulWidget {
  final Function(int) onNavigate;

  const DashboardHomeView({super.key, required this.onNavigate});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  // Expansion States
  bool _showAllTopDeals = false;
  bool _showAllCompanyPerformance = false;
  bool _showAllBanners = false;
  bool _showAllRecentDeals = false;

  @override
  Widget build(BuildContext context) {
    final dealsVM = context.watch<DealsManagementViewModel>();
    final companiesVM = context.watch<CompaniesManagementViewModel>();
    final bannersVM = context.watch<BannersManagementViewModel>();
    final categoriesVM = context.watch<CategoriesManagementViewModel>();
    final dashboardVM = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header محسّن
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.kElectricLime.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: AppTheme.kElectricLime,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'لوحة تحكم كوديو 🚀',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: AppTheme.kLightText,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'إحصائيات مباشرة وتحليلات الأداء',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.kSubtleText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: AppTheme.kElectricLime,
                  ),
                  onPressed: () => dashboardVM.loadDashboardData(),
                  tooltip: 'تحديث البيانات',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stat Cards (Live Aggregates)
            _buildStatCards(
              dealsVM,
              companiesVM,
              bannersVM,
              categoriesVM,
              dashboardVM,
            ),
            const SizedBox(height: 32),

            _buildTopDealsTable(context, dashboardVM),
            const SizedBox(height: 32),

            _buildSocialBreakdown(context, dashboardVM),
            const SizedBox(height: 32),

            _buildCompanyPerformanceTable(context, dashboardVM),
            const SizedBox(height: 32),

            _buildBannerManagementTable(context, dashboardVM),
            const SizedBox(height: 32),

            // Recent Deals
            _buildRecentDeals(context, dealsVM),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(
    DealsManagementViewModel dealsVM,
    CompaniesManagementViewModel companiesVM,
    BannersManagementViewModel bannersVM,
    CategoriesManagementViewModel categoriesVM,
    DashboardViewModel dashboardVM,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          title: 'إجمالي العروض',
          value: dealsVM.isLoading ? '...' : dealsVM.deals.length.toString(),
          icon: Icons.local_offer_rounded,
          color: AppTheme.kElectricLime,
          gradient: LinearGradient(
            colors: [
              AppTheme.kElectricLime.withAlpha(51),
              AppTheme.kElectricLime.withAlpha(26),
            ],
          ),
        ),
        _StatCard(
          title: 'إجمالي الشركات',
          value: companiesVM.isLoading
              ? '...'
              : companiesVM.companies.length.toString(),
          icon: Icons.business_center_rounded,
          color: Colors.cyanAccent,
          gradient: LinearGradient(
            colors: [
              Colors.cyanAccent.withAlpha(51),
              Colors.cyanAccent.withAlpha(26),
            ],
          ),
        ),
        _StatCard(
          title: 'إجمالي البنرات',
          value: bannersVM.isLoading
              ? '...'
              : bannersVM.banners.length.toString(),
          icon: Icons.view_carousel_rounded,
          color: Colors.pinkAccent,
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent.withAlpha(51),
              Colors.pinkAccent.withAlpha(26),
            ],
          ),
        ),
        _StatCard(
          title: 'إجمالي الفئات',
          value: categoriesVM.isLoading
              ? '...'
              : categoriesVM.categories.length.toString(),
          icon: Icons.category_rounded,
          color: Colors.amberAccent,
          gradient: LinearGradient(
            colors: [
              Colors.amberAccent.withAlpha(51),
              Colors.amberAccent.withAlpha(26),
            ],
          ),
        ),
        _StatCard(
          title: 'إجمالي الزيارات',
          value: dashboardVM.isLoading
              ? '...'
              : dashboardVM.totalViews.toString(),
          icon: Icons.visibility_rounded,
          color: Colors.blueAccent,
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withAlpha(51),
              Colors.blueAccent.withAlpha(26),
            ],
          ),
        ),
        _StatCard(
          title: 'نقرات الخريطة',
          value: dashboardVM.isLoading
              ? '...'
              : dashboardVM.totalMapClicks.toString(),
          icon: Icons.map_rounded,
          color: Colors.tealAccent,
          gradient: LinearGradient(
            colors: [
              Colors.tealAccent.withAlpha(51),
              Colors.tealAccent.withAlpha(26),
            ],
          ),
        ),
        _StatCard(
          title: 'عمليات النسخ',
          value: dashboardVM.isLoading
              ? '...'
              : dashboardVM.totalCopies.toString(),
          icon: Icons.content_copy_rounded,
          color: Colors.orangeAccent,
          gradient: LinearGradient(
            colors: [
              Colors.orangeAccent.withAlpha(51),
              Colors.orangeAccent.withAlpha(26),
            ],
          ),
        ),
        _StatCard(
          title: 'نقرات التواصل',
          value: dashboardVM.isLoading
              ? '...'
              : dashboardVM.totalClicks.toString(),
          icon: Icons.touch_app_rounded,
          color: Colors.purpleAccent,
          gradient: LinearGradient(
            colors: [
              Colors.purpleAccent.withAlpha(51),
              Colors.purpleAccent.withAlpha(26),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialBreakdown(BuildContext context, DashboardViewModel vm) {
    // Ensure all platforms exist in the display list, even with 0 clicks
    final platforms = ['whatsapp', 'facebook', 'instagram'];
    final Map<String, int> counts = {for (var p in platforms) p: 0};

    for (var item in vm.socialBreakdown) {
      final p = item['platform']?.toString().toLowerCase();
      if (p != null && counts.containsKey(p)) {
        counts[p] = (item['click_count'] as num? ?? 0).toInt();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.pie_chart_rounded,
              color: AppTheme.kElectricLime,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'توزيع منصات التواصل الاجتماعي',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.kLightText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(26)),
          ),
          child: Column(
            children: platforms.map((p) {
              String name = p;
              if (p == 'whatsapp') name = 'واتساب';
              if (p == 'facebook') name = 'فيسبوك';
              if (p == 'instagram') name = 'انستجرام';

              final count = counts[p] ?? 0;
              final total = vm.totalClicks > 0 ? vm.totalClicks : 1;
              final percentage = (count / total);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '$count نقرة',
                          style: const TextStyle(
                            color: AppTheme.kElectricLime,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.white.withAlpha(26),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.kElectricLime,
                      ),
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDealsTable(BuildContext context, DashboardViewModel vm) {
    final displayDeals = _showAllTopDeals
        ? vm.topDeals
        : vm.topDeals.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppTheme.kElectricLime,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'أفضل العروض أداءً (إحصائيات النجاح)',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.kLightText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            _buildSentimentLegend(),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(26)),
          ),
          child: vm.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.kElectricLime,
                    ),
                  ),
                )
              : vm.topDeals.isEmpty
              ? _buildEmptyState('لا توجد بيانات للعروض حالياً')
              : Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppTheme.kDarkBackground.withAlpha(51),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'العرض',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الشركة',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'المشاهدات',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'النسخ',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الروابط',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'شغّال (تقييم)',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'تقييم المستخدمين',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: displayDeals.map((deal) {
                          // Extract emoji feedback data if available
                          final happyCount =
                              deal['emoji_happy_count'] as int? ?? 0;
                          final neutralCount =
                              deal['emoji_neutral_count'] as int? ?? 0;
                          final sadCount = deal['emoji_sad_count'] as int? ?? 0;
                          final totalEmoji =
                              happyCount + neutralCount + sadCount;

                          // Extract engagement interactions from table
                          final copyCount =
                              deal['code_copies'] as int? ?? 0;
                          final linkCount =
                              deal['link_opens'] as int? ?? 0;
                          final dealViews =
                              deal['views'] as int? ?? 0;

                          // Local flutter calc for success rate that matches mobile deal_details_view_model algorithm
                          double successRate = 100.0;
                          if (totalEmoji > 0) {
                            final avg = ((happyCount * 5) + (neutralCount * 3) + (sadCount * 1)) / totalEmoji;
                            
                            double bonus = 0.0;
                            if (avg < 5.0 && dealViews > 0) {
                              bonus = ((copyCount + linkCount) / dealViews).clamp(0.0, 1.0);
                            }
                            
                            final finalRating = (avg + bonus).clamp(0.0, 5.0);
                            successRate = (finalRating / 5) * 100;
                          }

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  deal['title'] ?? '',
                                  style: const TextStyle(
                                    color: AppTheme.kLightText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  deal['company_name'] ?? '',
                                  style: const TextStyle(
                                    color: AppTheme.kSubtleText,
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deal['views']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    if (deal['unique_viewers'] != null)
                                      Text(
                                        '(${deal['unique_viewers']} أشخاص)',
                                        style: const TextStyle(
                                          color: AppTheme.kSubtleText,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deal['code_copies']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                    if (deal['unique_copiers'] != null)
                                      Text(
                                        '(${deal['unique_copiers']} أشخاص)',
                                        style: const TextStyle(
                                          color: AppTheme.kSubtleText,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deal['link_opens']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: Colors.tealAccent,
                                      ),
                                    ),
                                    if (deal['unique_link_openers'] != null)
                                      Text(
                                        '(${deal['unique_link_openers']} أشخاص)',
                                        style: const TextStyle(
                                          color: AppTheme.kSubtleText,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(_buildStarRatingBadge(successRate)),
                              DataCell(
                                _buildEmojiBreakdown(
                                  happyCount,
                                  neutralCount,
                                  sadCount,
                                  totalEmoji,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    if (vm.topDeals.length > 5)
                      _buildShowMoreButton(
                        isExpanded: _showAllTopDeals,
                        onToggle: () => setState(
                          () => _showAllTopDeals = !_showAllTopDeals,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildCompanyPerformanceTable(
    BuildContext context,
    DashboardViewModel vm,
  ) {
    final displayCompanies = _showAllCompanyPerformance
        ? vm.companyPerformance
        : vm.companyPerformance.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.business_center_rounded,
              color: AppTheme.kElectricLime,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'أداء الشركات بالتفصيل',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.kLightText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(26)),
          ),
          child: vm.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.kElectricLime,
                    ),
                  ),
                )
              : vm.companyPerformance.isEmpty
              ? _buildEmptyState('لا توجد بيانات للشركات حالياً')
              : Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppTheme.kDarkBackground.withAlpha(51),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'الشركة',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'زيارات الصفحة',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'نقرات التواصل',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'نقرات الخريطة',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'نقرات الموقع',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'نقرات الهاتف',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: displayCompanies.map((company) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  company['name'] ?? '',
                                  style: const TextStyle(
                                    color: AppTheme.kLightText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      company['page_views']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    if (company['unique_page_viewers'] != null)
                                      Text(
                                        '(${company['unique_page_viewers']} أشخاص)',
                                        style: const TextStyle(
                                          color: AppTheme.kSubtleText,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  company['social_clicks']?.toString() ?? '0',
                                  style: const TextStyle(
                                    color: Colors.purpleAccent,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  company['map_click_count']?.toString() ?? '0',
                                  style: const TextStyle(
                                    color: Colors.tealAccent,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  company['website_click_count']?.toString() ??
                                      '0',
                                  style: const TextStyle(
                                    color: Colors.amberAccent,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  company['phone_click_count']?.toString() ??
                                      '0',
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    if (vm.companyPerformance.length > 5)
                      _buildShowMoreButton(
                        isExpanded: _showAllCompanyPerformance,
                        onToggle: () => setState(
                          () => _showAllCompanyPerformance =
                              !_showAllCompanyPerformance,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildBannerManagementTable(
    BuildContext context,
    DashboardViewModel vm,
  ) {
    final displayBanners = _showAllBanners
        ? vm.bannerPerformance
        : vm.bannerPerformance.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.ads_click_rounded,
              color: AppTheme.kElectricLime,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'تحليل أداء البانرات الإعلانية',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.kLightText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(26)),
          ),
          child: vm.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.kElectricLime,
                    ),
                  ),
                )
              : vm.bannerPerformance.isEmpty
              ? _buildEmptyState('لا توجد بيانات للبانرات حالياً')
              : Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppTheme.kDarkBackground.withAlpha(51),
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'البانر (ID)',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'المشاهدات',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'النقرات',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'CTR %',
                              style: TextStyle(
                                color: AppTheme.kElectricLime,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        rows: displayBanners.map((banner) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '#${banner['banner_id']}',
                                  style: const TextStyle(
                                    color: AppTheme.kLightText,
                                  ),
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      banner['impressions']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    if (banner['unique_viewers'] != null && banner['unique_viewers'] > 0)
                                      Text(
                                        '(${banner['unique_viewers']} أشخاص)',
                                        style: const TextStyle(
                                          color: AppTheme.kSubtleText,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      banner['clicks']?.toString() ?? '0',
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                    if (banner['unique_clickers'] != null && banner['unique_clickers'] > 0)
                                      Text(
                                        '(${banner['unique_clickers']} أشخاص)',
                                        style: const TextStyle(
                                          color: AppTheme.kSubtleText,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(51),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${banner['ctr_percentage']}%',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    if (vm.bannerPerformance.length > 5)
                      _buildShowMoreButton(
                        isExpanded: _showAllBanners,
                        onToggle: () =>
                            setState(() => _showAllBanners = !_showAllBanners),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildStarRatingBadge(double rate) {
    // Calculate stars from 0 to 5 based on percentage
    final double rating = (rate / 100) * 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentLegend() {
    return Row(
      children: [
        _legendItem(
          'ممتاز',
          Icons.sentiment_very_satisfied_rounded,
          Colors.greenAccent,
        ),
        const SizedBox(width: 12),
        _legendItem(
          'جيد',
          Icons.sentiment_satisfied_alt_rounded,
          Colors.blueAccent,
        ),
        const SizedBox(width: 12),
        _legendItem(
          'متوسط',
          Icons.sentiment_neutral_rounded,
          Colors.orangeAccent,
        ),
      ],
    );
  }

  Widget _legendItem(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.kSubtleText, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmojiBreakdown(
    int happyCount,
    int neutralCount,
    int sadCount,
    int total,
  ) {
    if (total == 0) {
      return const Text(
        'لا توجد تقييمات',
        style: TextStyle(
          color: AppTheme.kSubtleText,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    final happyPct = (happyCount / total * 100).toInt();
    final neutralPct = (neutralCount / total * 100).toInt();
    final sadPct = (sadCount / total * 100).toInt();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (happyCount > 0) ...[
            Text(
              '😊 $happyPct%',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (neutralCount > 0) ...[
            Text(
              '😐 $neutralPct%',
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (sadCount > 0) ...[
            Text(
              '😞 $sadPct%',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(width: 4),
          Text(
            '($total)',
            style: const TextStyle(color: AppTheme.kSubtleText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 48,
              color: AppTheme.kSubtleText,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppTheme.kSubtleText, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDeals(BuildContext context, DealsManagementViewModel vm) {
    // Determine the list to show based on state
    final displayList = _showAllRecentDeals
        ? vm.deals
        : vm.deals.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppTheme.kElectricLime,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'أحدث العروض المضافة (الكل)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.kLightText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(26)),
          ),
          child: vm.isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.kElectricLime,
                    ),
                  ),
                )
              : displayList.isEmpty
              ? _buildEmptyState('لا توجد عروض حالياً')
              : Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayList.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: AppTheme.kSubtleText.withAlpha(26),
                      ),
                      itemBuilder: (context, index) {
                        final deal = displayList[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.kElectricLime.withAlpha(26),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.local_offer_rounded,
                              color: AppTheme.kElectricLime,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            deal.title,
                            style: const TextStyle(
                              color: AppTheme.kLightText,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              deal.companyName ?? 'غير معروف',
                              style: TextStyle(
                                color: AppTheme.kSubtleText,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.kElectricLime.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              deal.dealType,
                              style: const TextStyle(
                                color: AppTheme.kElectricLime,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (vm.deals.length > 5)
                      _buildShowMoreButton(
                        isExpanded: _showAllRecentDeals,
                        onToggle: () => setState(
                          () => _showAllRecentDeals = !_showAllRecentDeals,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  // ✨ زرار عرض المزيد / الأقل
  Widget _buildShowMoreButton({
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.kDarkBackground.withAlpha(26),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isExpanded ? 'عرض أقل' : 'عرض المزيد',
              style: const TextStyle(
                color: AppTheme.kElectricLime,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: AppTheme.kElectricLime,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 250,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.color.withAlpha(128)
                : AppTheme.kSubtleText.withAlpha(26),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withAlpha(51),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, size: 28, color: widget.color),
            ),
            const SizedBox(height: 16),
            Text(
              widget.value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.kLightText,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.kSubtleText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
