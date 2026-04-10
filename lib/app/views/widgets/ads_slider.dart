import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/ad_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../deal_details_view.dart';

class AdsSlider extends StatefulWidget {
  const AdsSlider({super.key});

  @override
  State<AdsSlider> createState() => _AdsSliderState();
}

class _AdsSliderState extends State<AdsSlider> {
  final SupabaseService _supabaseService = SupabaseService();
  List<AdModel> _ads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    setState(() => _isLoading = true);
    final ads = await _supabaseService.getAds();
    setState(() {
      _ads = ads.where((a) => a.isActive).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_ads.isEmpty) return const SizedBox.shrink();

    return CarouselSlider.builder(
      itemCount: _ads.length,
      options: CarouselOptions(
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? (MediaQuery.of(context).size.width > 600 ? 160.h : 140.h)
            : 120.h,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 6),
        enlargeCenterPage: true,
        viewportFraction: MediaQuery.of(context).size.width > 600 ? 0.7 : 0.9,
      ),
      itemBuilder: (context, index, realIndex) {
        final ad = _ads[index];
        return GestureDetector(
          onTap: () async {
            final deal = await _supabaseService.getDealById(ad.dealId);
            if (deal != null && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DealDetailsView(deal: deal)),
              );
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6.w,
                  offset: Offset(0, 3.h),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: ad.imageLink,
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
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


