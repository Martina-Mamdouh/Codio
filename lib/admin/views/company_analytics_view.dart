import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/company_analytics_viewmodel.dart';

class CompanyAnalyticsView extends StatelessWidget {
  final int companyId;
  final String companyName;
  final String? companyLogoUrl;

  const CompanyAnalyticsView({
    super.key,
    required this.companyId,
    required this.companyName,
    this.companyLogoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyAnalyticsViewModel(
        companyId: companyId,
        companyName: companyName,
        companyLogoUrl: companyLogoUrl,
      ),
      child: const _CompanyAnalyticsBody(),
    );
  }
}

class _CompanyAnalyticsBody extends StatelessWidget {
  const _CompanyAnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyAnalyticsViewModel>();
    final reportDate = intl.DateFormat('dd/MM/yyyy – hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _buildHeader(context, vm, reportDate),

          // ── Filter Buttons ───────────────────────────────────────────────
          _buildFilterBar(context, vm),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: vm.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.kElectricLime,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: vm.loadData,
                    color: AppTheme.kElectricLime,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCards(context, vm),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    CompanyAnalyticsViewModel vm,
    String reportDate,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.kElectricLime.withAlpha(51),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
            tooltip: 'رجوع',
          ),
          const SizedBox(width: 8),

          // Logo
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppTheme.kElectricLime,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: vm.companyLogoUrl != null &&
                      vm.companyLogoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: vm.companyLogoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.store,
                        color: Colors.black87,
                        size: 24,
                      ),
                    )
                  : const Icon(Icons.store, color: Colors.black87, size: 24),
            ),
          ),
          const SizedBox(width: 12),

          // Name + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.companyName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'تقرير بتاريخ: $reportDate',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.kElectricLime),
            onPressed: vm.loadData,
            tooltip: 'تحديث',
          ),
        ],
      ),
    );
  }

  // ── Filter Bar ────────────────────────────────────────────────────────────
  Widget _buildFilterBar(BuildContext context, CompanyAnalyticsViewModel vm) {
    final filters = [
      (AnalyticsFilter.today, 'اليوم'),
      (AnalyticsFilter.week, 'الأسبوع'),
      (AnalyticsFilter.month, 'الشهر'),
      (AnalyticsFilter.all, 'كل الوقت'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.kLightBackground,
      child: Row(
        children: filters.map((entry) {
          final (filter, label) = entry;
          final isSelected = vm.selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.changeFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.kElectricLime
                      : AppTheme.kDarkBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.kElectricLime
                        : Colors.white12,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Summary Cards ─────────────────────────────────────────────────────────
  Widget _buildSummaryCards(
    BuildContext context,
    CompanyAnalyticsViewModel vm,
  ) {
    final stats = vm.companyStats;
    final cards = [
      _CardData(
        title: 'زيارات الصفحة',
        total: stats['page_views'] as int? ?? 0,
        unique: stats['unique_viewers'] as int? ?? 0,
        icon: Icons.visibility_rounded,
        color: Colors.blueAccent,
      ),
      _CardData(
        title: 'نقرات التواصل',
        total: stats['social_clicks'] as int? ?? 0,
        unique: stats['unique_social_clickers'] as int? ?? 0,
        icon: Icons.share_rounded,
        color: Colors.purpleAccent,
      ),
      _CardData(
        title: 'نقرات الخريطة',
        total: stats['map_clicks'] as int? ?? 0,
        unique: stats['unique_map_clickers'] as int? ?? 0,
        icon: Icons.map_rounded,
        color: Colors.tealAccent,
      ),
      _CardData(
        title: 'نقرات الهاتف',
        total: stats['phone_clicks'] as int? ?? 0,
        unique: stats['unique_phone_clickers'] as int? ?? 0,
        icon: Icons.phone_rounded,
        color: Colors.greenAccent,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final crossAxisCount = isWide ? 4 : 2;
        final aspectRatio = isWide ? 2.2 : 1.5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, i) => _buildStatCard(cards[i]),
        );
      },
    );
  }

  Widget _buildStatCard(_CardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(data.icon, color: data.color, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.title,
                  style: const TextStyle(
                    color: AppTheme.kSubtleText,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.total.toString(),
                style: TextStyle(
                  color: data.color,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${data.unique} شخص فريد',
                style: const TextStyle(
                  color: AppTheme.kSubtleText,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

// Simple data holder for summary cards
class _CardData {
  final String title;
  final int total;
  final int unique;
  final IconData icon;
  final Color color;

  const _CardData({
    required this.title,
    required this.total,
    required this.unique,
    required this.icon,
    required this.color,
  });
}
