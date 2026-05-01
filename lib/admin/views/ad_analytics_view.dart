import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/ad_analytics_viewmodel.dart';

class AdAnalyticsView extends StatelessWidget {
  final int adId;
  final String adImageLink;
  final bool isActive;
  final String placement;
  final String? categoryName;

  const AdAnalyticsView({
    super.key,
    required this.adId,
    required this.adImageLink,
    required this.isActive,
    this.placement = 'home',
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdAnalyticsViewModel(
        adId: adId,
        adImageLink: adImageLink,
        isActive: isActive,
        placement: placement,
        categoryName: categoryName,
      ),
      child: const _AdAnalyticsBody(),
    );
  }
}

class _AdAnalyticsBody extends StatelessWidget {
  const _AdAnalyticsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdAnalyticsViewModel>();
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
                          const SizedBox(height: 28),
                          _buildCtrCard(context, vm),
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
    AdAnalyticsViewModel vm,
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

          // Ad Image Thumbnail
          Container(
            width: 80,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.kDarkBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: vm.adImageLink,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white54,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'إعلان #${vm.adId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: vm.isActive
                            ? AppTheme.kElectricLime.withAlpha(38)
                            : Colors.redAccent.withAlpha(38),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: vm.isActive ? AppTheme.kElectricLime : Colors.redAccent,
                        ),
                      ),
                      child: Text(
                        vm.isActive ? 'نشط' : 'متوقف',
                        style: TextStyle(
                          color: vm.isActive ? AppTheme.kElectricLime : Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Placement badge
                Row(
                  children: [
                    Icon(
                      vm.placement == 'home' ? Icons.home_rounded : Icons.category_rounded,
                      size: 12,
                      color: vm.placement == 'home' ? Colors.blueAccent : Colors.purpleAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vm.placement == 'home'
                          ? 'الصفحة الرئيسية'
                          : vm.categoryName ?? 'تصنيف',
                      style: TextStyle(
                        color: vm.placement == 'home' ? Colors.blueAccent : Colors.purpleAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $reportDate',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                    ),
                  ],
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
  Widget _buildFilterBar(BuildContext context, AdAnalyticsViewModel vm) {
    final filters = [
      (AdAnalyticsFilter.today, 'اليوم'),
      (AdAnalyticsFilter.week, 'الأسبوع'),
      (AdAnalyticsFilter.month, 'الشهر'),
      (AdAnalyticsFilter.all, 'كل الوقت'),
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
    AdAnalyticsViewModel vm,
  ) {
    final stats = vm.adStats;
    final cards = [
      _CardData(
        title: 'المشاهدات (Impressions)',
        total: stats['impressions'] as int? ?? 0,
        unique: stats['unique_impressions'] as int? ?? 0,
        icon: Icons.visibility_rounded,
        color: Colors.blueAccent,
      ),
      _CardData(
        title: 'النقرات (Clicks)',
        total: stats['clicks'] as int? ?? 0,
        unique: stats['unique_clicks'] as int? ?? 0,
        icon: Icons.touch_app_rounded,
        color: AppTheme.kElectricLime,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final crossAxisCount = isWide ? 2 : 2;
        final aspectRatio = isWide ? 2.5 : 1.5;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
                  fontSize: 28,
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

  // ── CTR Card ──────────────────────────────────────────────────────────────
  Widget _buildCtrCard(BuildContext context, AdAnalyticsViewModel vm) {
    final stats = vm.adStats;
    final impressions = stats['impressions'] as int? ?? 0;
    final clicks = stats['clicks'] as int? ?? 0;

    double ctr = 0.0;
    if (impressions > 0) {
      ctr = (clicks / impressions) * 100;
    }

    // Determine color based on CTR performance (industry average is often ~1-2%)
    Color ctrColor = Colors.redAccent;
    String performanceLabel = 'ضعيف';
    if (ctr >= 5.0) {
      ctrColor = Colors.greenAccent;
      performanceLabel = 'ممتاز';
    } else if (ctr >= 2.0) {
      ctrColor = AppTheme.kElectricLime;
      performanceLabel = 'جيد';
    } else if (ctr >= 0.5) {
      ctrColor = Colors.orangeAccent;
      performanceLabel = 'متوسط';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ctrColor.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ctrColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.analytics_rounded, color: ctrColor, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نسبة النقر للظهور (CTR)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'معدل تحويل المشاهدات إلى نقرات فعلية.',
                  style: TextStyle(color: AppTheme.kSubtleText, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${ctr.toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: ctrColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ctrColor.withAlpha(38),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        performanceLabel,
                        style: TextStyle(
                          color: ctrColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
