import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/banner_model.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../core/services/analytics_service.dart';
import '../deal_details_view.dart';

class HomeBannerSlider extends StatelessWidget {
  final List<BannerModel> banners;

  const HomeBannerSlider({super.key, required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isTabletPortrait = isTablet && !isLandscape;
    return CarouselSlider.builder(
      itemCount: banners.length,
      options: CarouselOptions(
        height: isTabletPortrait
            ? 320.h   // key fix: controlled, not huge
            : isTablet
            ? (isLandscape ? 640.h : 480.h)
            : (isLandscape ? 160.h : 180.h),
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        aspectRatio: isTablet ? 16 / 7 : 16 / 9,
        viewportFraction: isTablet ? 0.65 : 0.9,
        onPageChanged: (index, reason) {
          // Track banner impression
          if (index < banners.length) {
            context.read<AnalyticsService>().trackBannerImpression(
              banners[index].id,
              position: index,
            );
          }
        },
      ),
      itemBuilder: (context, index, realIndex) {
        final banner = banners[index];
        if (kDebugMode) {
          print('📸 Banner Image URL: [${banner.imageUrl}]');
        }
        return GestureDetector(
          onTap: () async {
            debugPrint('🖱️ Banner tapped: ${banner.id}');
            try {
              // Track banner click (safe-guarded)
              context.read<AnalyticsService>().trackBannerClick(
                banner.id,
                position: index,
              );
            } catch (e) {
              debugPrint('⚠️ Analytics Error in Banner: $e');
            }

            // 1. Check for Link URL First
            if (banner.linkUrl != null && banner.linkUrl!.trim().isNotEmpty) {
              final uri = Uri.tryParse(banner.linkUrl!.trim());
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return; // Stop here, link opened successfully
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تعذّر فتح الرابط المرفق بالبانر'),
                    ),
                  );
                }
              }
            }

            // 2. Fallback to Deal ID if no link or link failed
            if (banner.dealId == null) return;

            final DealModel? deal = await SupabaseService().getDealById(
              banner.dealId!,
            );

            if (deal != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DealDetailsView(deal: deal)),
              );
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(horizontal: 5.0.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 5.w,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                placeholder: (context, url) => Container(
                  color: AppTheme.kLightBackground,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.kElectricLime,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  if (kDebugMode) {
                    print('❌ Banner Image Error: $error for URL: [$url]');
                  }
                  return Container(
                    color: AppTheme.kLightBackground,
                    child: const Icon(Icons.broken_image, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
