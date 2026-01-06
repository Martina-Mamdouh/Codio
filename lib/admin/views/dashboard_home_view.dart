import 'package:flutter/material.dart';
import 'package:kodio_app/admin/viewmodels/deals_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/companies_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/banners_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/categories_management_viewmodel.dart';
import 'package:kodio_app/admin/viewmodels/dashboard_viewmodel.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

class DashboardHomeView extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardHomeView({super.key, required this.onNavigate});

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
                  icon: const Icon(Icons.refresh, color: AppTheme.kElectricLime),
                  onPressed: () => dashboardVM.loadDashboardData(),
                  tooltip: 'تحديث البيانات',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Stat Cards (Live Aggregates)
            _buildStatCards(dealsVM, companiesVM, bannersVM, categoriesVM, dashboardVM),
            const SizedBox(height: 32),

            _buildTopDealsTable(context, dashboardVM),
            const SizedBox(height: 32),

            _buildLiveAnalytics(context, dashboardVM),
            const SizedBox(height: 32),

            _buildCompanyPerformanceTable(context, dashboardVM),
            const SizedBox(height: 32),

            _buildBannerManagementTable(context, dashboardVM),
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
          value: companiesVM.isLoading ? '...' : companiesVM.companies.length.toString(),
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
          value: bannersVM.isLoading ? '...' : bannersVM.banners.length.toString(),
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
          value: categoriesVM.isLoading ? '...' : categoriesVM.categories.length.toString(),
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
          value: dashboardVM.isLoading ? '...' : dashboardVM.totalViews.toString(),
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
          value: dashboardVM.isLoading ? '...' : dashboardVM.totalMapClicks.toString(),
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
          value: dashboardVM.isLoading ? '...' : dashboardVM.totalCopies.toString(),
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
          value: dashboardVM.isLoading ? '...' : dashboardVM.totalClicks.toString(),
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

  Widget _buildLiveAnalytics(BuildContext context, DashboardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),

        // Social Media Breakdown (Simplified Bar Chart style)
        Row(
          children: [
            const Icon(
              Icons.pie_chart_rounded,
              color: AppTheme.kElectricLime,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'توزيع منصات التواصل',
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.kSubtleText.withAlpha(26)),
          ),
          child: vm.socialBreakdown.isEmpty
              ? const Center(child: Text('لا توجد بيانات منصات حالياً', style: TextStyle(color: Colors.grey)))
              : Column(
                  children: vm.socialBreakdown.map((platform) {
                    final name = platform['platform'] ?? 'غير معروف';
                    final count = platform['click_count'] ?? 0;
                    final total = vm.totalClicks > 0 ? vm.totalClicks : 1;
                    final percentage = (count / total);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name, style: TextStyle(color: Colors.white70)),
                              Text('$count نقرة', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.white12,
                            color: AppTheme.kElectricLime,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 32),

        // Banner Performance
        Row(
          children: [
            const Icon(
              Icons.view_carousel_rounded,
              color: AppTheme.kElectricLime,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'أداء البانرات الإعلانية',
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
          child: vm.bannerPerformance.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Center(child: Text('لا توجد بيانات بانرات حالياً', style: TextStyle(color: Colors.grey))),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('رقم البانر', style: TextStyle(color: AppTheme.kElectricLime))),
                      DataColumn(label: Text('الظهور', style: TextStyle(color: AppTheme.kElectricLime))),
                      DataColumn(label: Text('النقرات', style: TextStyle(color: AppTheme.kElectricLime))),
                      DataColumn(label: Text('CTR %', style: TextStyle(color: AppTheme.kElectricLime))),
                    ],
                    rows: vm.bannerPerformance.map((b) => DataRow(
                      cells: [
                        DataCell(Text('#${b['banner_id']}', style: TextStyle(color: Colors.white))),
                        DataCell(Text(b['impressions'].toString(), style: TextStyle(color: Colors.white70))),
                        DataCell(Text(b['clicks'].toString(), style: TextStyle(color: Colors.white70))),
                        DataCell(
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.kElectricLime.withAlpha(40),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${b['ctr_percentage']}%', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )).toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTopDealsTable(BuildContext context, DashboardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppTheme.kElectricLime, size: 28),
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
              ? const Center(child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator(color: AppTheme.kElectricLime)))
              : vm.topDeals.isEmpty
                  ? _buildEmptyState('لا توجد بيانات للعروض حالياً')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppTheme.kDarkBackground.withAlpha(51)),
                        columns: const [
                          DataColumn(label: Text('العرض', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('الشركة', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('المشاهدات', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('النسخ', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('الروابط', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('نسبة النجاح', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('الرضا', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                        ],
                        rows: vm.topDeals.map((deal) {
                          final successRate = (deal['success_rate'] as num? ?? 0).toDouble();
                          return DataRow(cells: [
                            DataCell(Text(deal['title'] ?? '', style: const TextStyle(color: AppTheme.kLightText, fontWeight: FontWeight.bold))),
                            DataCell(Text(deal['company_name'] ?? '', style: const TextStyle(color: AppTheme.kSubtleText))),
                            DataCell(Text(deal['views']?.toString() ?? '0', style: const TextStyle(color: Colors.blueAccent))),
                            DataCell(Text(deal['code_copies']?.toString() ?? '0', style: const TextStyle(color: Colors.orangeAccent))),
                            DataCell(Text(deal['link_opens']?.toString() ?? '0', style: const TextStyle(color: Colors.tealAccent))),
                            DataCell(_buildSuccessBadge(successRate)),
                            DataCell(_buildSentimentIcon(successRate)),
                          ]);
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildCompanyPerformanceTable(BuildContext context, DashboardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business_center_rounded, color: AppTheme.kElectricLime, size: 28),
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
              ? const Center(child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator(color: AppTheme.kElectricLime)))
              : vm.companyPerformance.isEmpty
                  ? _buildEmptyState('لا توجد بيانات للشركات حالياً')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppTheme.kDarkBackground.withAlpha(51)),
                        columns: const [
                          DataColumn(label: Text('الشركة', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('زيارات الصفحة', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('نقرات التواصل', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('نقرات الخريطة', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('نقرات الموقع', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('نقرات الهاتف', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                        ],
                        rows: vm.companyPerformance.map((company) {
                          return DataRow(cells: [
                            DataCell(Text(company['name'] ?? '', style: const TextStyle(color: AppTheme.kLightText, fontWeight: FontWeight.bold))),
                            DataCell(Text(company['page_views']?.toString() ?? '0', style: const TextStyle(color: Colors.blueAccent))),
                            DataCell(Text(company['social_clicks']?.toString() ?? '0', style: const TextStyle(color: Colors.purpleAccent))),
                            DataCell(Text(company['map_click_count']?.toString() ?? '0', style: const TextStyle(color: Colors.tealAccent))),
                            DataCell(Text(company['website_click_count']?.toString() ?? '0', style: const TextStyle(color: Colors.amberAccent))),
                            DataCell(Text(company['phone_click_count']?.toString() ?? '0', style: const TextStyle(color: Colors.greenAccent))),
                          ]);
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildBannerManagementTable(BuildContext context, DashboardViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.ads_click_rounded, color: AppTheme.kElectricLime, size: 28),
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
              ? const Center(child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator(color: AppTheme.kElectricLime)))
              : vm.bannerPerformance.isEmpty
                  ? _buildEmptyState('لا توجد بيانات للبانرات حالياً')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppTheme.kDarkBackground.withAlpha(51)),
                        columns: const [
                          DataColumn(label: Text('البانر (ID)', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('المشاهدات', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('النقرات', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('CTR %', style: TextStyle(color: AppTheme.kElectricLime, fontWeight: FontWeight.bold))),
                        ],
                        rows: vm.bannerPerformance.map((banner) {
                          return DataRow(cells: [
                            DataCell(Text('#${banner['banner_id']}', style: const TextStyle(color: AppTheme.kLightText))),
                            DataCell(Text(banner['impressions']?.toString() ?? '0', style: const TextStyle(color: Colors.blueAccent))),
                            DataCell(Text(banner['clicks']?.toString() ?? '0', style: const TextStyle(color: Colors.orangeAccent))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.blue.withAlpha(51), borderRadius: BorderRadius.circular(10)),
                              child: Text('${banner['ctr_percentage']}%', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildSuccessBadge(double rate) {
    Color color = Colors.greenAccent;
    if (rate < 85) color = Colors.orangeAccent;
    if (rate < 75) color = Colors.redAccent;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        '${rate.toInt()}%',
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildSentimentIcon(double rate) {
    if (rate > 90) return const Icon(Icons.sentiment_very_satisfied_rounded, color: Colors.greenAccent);
    if (rate > 80) return const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.blueAccent);
    if (rate > 70) return const Icon(Icons.sentiment_neutral_rounded, color: Colors.orangeAccent);
    return const Icon(Icons.sentiment_very_dissatisfied_rounded, color: Colors.redAccent);
  }

  Widget _buildSentimentLegend() {
    return Row(
      children: [
        _legendItem('ممتاز', Icons.sentiment_very_satisfied_rounded, Colors.greenAccent),
        const SizedBox(width: 12),
        _legendItem('جيد', Icons.sentiment_satisfied_alt_rounded, Colors.blueAccent),
        const SizedBox(width: 12),
        _legendItem('متوسط', Icons.sentiment_neutral_rounded, Colors.orangeAccent),
      ],
    );
  }

  Widget _legendItem(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppTheme.kSubtleText, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            const Icon(Icons.analytics_outlined, size: 48, color: AppTheme.kSubtleText),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppTheme.kSubtleText, fontSize: 16)),
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
