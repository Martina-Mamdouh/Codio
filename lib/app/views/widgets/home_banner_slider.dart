import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    return CarouselSlider.builder(
      itemCount: banners.length,
      options: CarouselOptions(
        height: 160.0.h,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
        viewportFraction: 0.9,
        onPageChanged: (index, reason) {
          // Track banner impression
          if (index < banners.length) {
            context.read<AnalyticsService>().trackBannerImpression(
              banners[index].id!,
              position: index,
            );
          }
        },
      ),
      itemBuilder: (context, index, realIndex) {
        final banner = banners[index];
        return GestureDetector(
          onTap: () async {
            debugPrint('🖱️ Banner tapped: ${banner.id}');
            try {
              // Track banner click (safe-guarded)
              context.read<AnalyticsService>().trackBannerClick(
                banner.id!,
                position: index,
              );
            } catch (e) {
              debugPrint('⚠️ Analytics Error in Banner: $e');
            }

            final DealModel? deal = await SupabaseService().getDealById(
              banner.dealId!,
            );

            if (deal != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DealDetailsView(deal: deal),
                ),
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
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.kLightBackground,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
