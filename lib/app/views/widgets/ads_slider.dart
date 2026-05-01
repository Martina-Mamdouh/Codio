import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/ad_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_theme.dart';
import '../deal_details_view.dart';

class AdsSlider extends StatefulWidget {
  final bool fullBleed;
  const AdsSlider({super.key, this.fullBleed = false});

  @override
  State<AdsSlider> createState() => _AdsSliderState();
}

class _AdsSliderState extends State<AdsSlider> {
  final SupabaseService _supabaseService = SupabaseService();
  final AnalyticsService _analyticsService = AnalyticsService();
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

    if (_ads.isNotEmpty) {
      _analyticsService.trackAdImpression(_ads[0].id, position: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_ads.isEmpty) return const SizedBox.shrink();

    // Compute a fixed height for the slider from the available width and
    // the ad aspect ratio so the widget always occupies the same vertical
    // space. This ensures the ad appears visually centered between the
    // content above and below it regardless of surrounding layout.
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = widget.fullBleed ? 0.w : 12.w; // total (6.w each side)
    final availableWidth = screenWidth - horizontalPadding;
    final adAspect = 2032 / 512;
    final sliderHeight = availableWidth / adAspect;

    return SizedBox(
      height: sliderHeight,
      width: double.infinity,
      child: CarouselSlider.builder(
        itemCount: _ads.length,
        options: CarouselOptions(
          // Use the same aspect ratio as the uploaded ad images (2032x512)
          // so the image is not cropped. Let the slider compute height
          // from available width. Make each slide occupy the full
          // available width inside its horizontal padding.
          aspectRatio: adAspect,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 6),
          enlargeCenterPage: false,
          viewportFraction: 1.0,
          onPageChanged: (index, reason) {
            _analyticsService.trackAdImpression(_ads[index].id, position: index);
          },
        ),
        itemBuilder: (context, index, realIndex) {
          final ad = _ads[index];
          return GestureDetector(
            onTap: () async {
              _analyticsService.trackAdClick(ad.id, position: index);

              if (ad.linkUrl != null && ad.linkUrl!.trim().isNotEmpty) {
                final uri = Uri.tryParse(ad.linkUrl!.trim());
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } else if (ad.dealId != null) {
                final deal = await _supabaseService.getDealById(ad.dealId!);
                if (deal != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DealDetailsView(deal: deal)),
                  );
                }
              }
            },
            child: Container(
              // keep the same horizontal inset used previously; the slider
              // overall has a fixed height so the image will be centered
              // vertically in the layout.
              margin: widget.fullBleed
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.fullBleed ? 0 : 10.r),
                // Use a centered shadow (offset 0,0) so the visual weight is
                // equal above and below the ad. Previously the shadow used a
                // downward offset which made the ad appear shifted downwards
                // and created unequal empty space above/below.
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6.w,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.fullBleed ? 0 : 10.r),
                child: AspectRatio(
                  // Preserve uploaded ad aspect ratio so the image won't be cropped
                  aspectRatio: adAspect,
                  child: CachedNetworkImage(
                    imageUrl: ad.imageLink,
                    // Use cover inside an AspectRatio matching the image so no cropping occurs
                    fit: BoxFit.cover,
                    memCacheWidth: 1600,
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
            ),
          );
        },
      ),
    );
  }
}


