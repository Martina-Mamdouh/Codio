import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'notifications_view.dart';
import 'map_view.dart';
import 'widgets/home_banner_slider.dart';
import 'widgets/ads_slider.dart';
import 'widgets/deal_section.dart';
import 'widgets/state_widgets.dart';
import 'widgets/shimmer_loading.dart';
import 'search_view.dart';
import 'view_all_deals_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceType = getDeviceType(MediaQuery.of(context).size);
    final isTablet = deviceType == DeviceScreenType.tablet;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.kDarkBackground,
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return _buildLoadingState();
          }

          if (viewModel.errorMessage != null) {
            return ErrorState(
              message: viewModel.errorMessage!,
              onRetry: viewModel.fetchAllData,
            );
          }

          final isLandscape =
              MediaQuery.of(context).orientation == Orientation.landscape;

          // Match YellowScaffold's header height for visual consistency
          final baseHeight = isLandscape ? 140.h : 128.h;
          final headerHeight = isTablet
              ? baseHeight * 1.35
              : baseHeight;

          return RefreshIndicator(
            onRefresh: viewModel.fetchAllData,
            color: AppTheme.kElectricLime,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: headerHeight + 30.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background
                        Container(
                          width: double.infinity,
                          height: headerHeight,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5FF17),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(18),
                            ),
                          ),
                        ),

                        // Logo & Notifications
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: isTablet ? 12.h : 8.h,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/slogan.png',
                                    width: isTablet ? 150.w : 120.w,
                                    height: isTablet ? 70.h : 50.h,
                                    fit: BoxFit.contain,
                                  ),
                                  const Spacer(),
                                  Consumer<NotificationsViewModel>(
                                    builder: (context, notificationsVm, _) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                                AppTheme.spacing12),
                                            decoration: BoxDecoration(
                                              color: AppTheme.kElectricLime,
                                              shape: BoxShape.circle,
                                              boxShadow: AppTheme.glowLime,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.notifications_none,
                                                color: Colors.black,
                                                size: AppTheme.iconMd,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                    const NotificationsView(),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          if (notificationsVm
                                              .newNotifications.isNotEmpty)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                width: 10.w,
                                                height: 10.w,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppTheme.kElectricLime,
                                                    width: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Search Bar
                        Positioned(
                          top: headerHeight - (isTablet ? 35.h : 25.h),                          left: 0,
                          right: 0,
                          child: Center(child: _buildSearchBar(context)),
                        ),
                      ],
                    ),
                  ),

                  // ✅ FIX 2: Extra spacing after search (tablet only)
                  SizedBox(height: isTablet ? 36.h : 12.h),

                  HomeBannerSlider(banners: viewModel.banners),
                  SizedBox(height: 16.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _DiscoverNearbyCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MapView(startNearby: true),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 8.h),

                  if (viewModel.nearbyDeals.isNotEmpty) ...[
                    DealSection(
                      title: 'عروض قريبة منك',
                      deals: viewModel.nearbyDeals,
                      isNearby: true,
                      onSeeAllTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewAllDealsScreen(
                              title: 'عروض قريبة منك',
                              deals: viewModel.allNearbyDeals,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 8.h),
                  ],

                  DealSection(
                    title: 'عروض جديدة',
                    deals: viewModel.newDeals,
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllDealsScreen(
                            title: 'عروض جديدة',
                            deals: viewModel.allNewDeals,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  DealSection(
                    title: 'تنتهي قريباً',
                    deals: viewModel.expiringDeals,
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllDealsScreen(
                            title: 'تنتهي قريباً',
                            deals: viewModel.allExpiringDeals,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 12.h),

                  DealSection(
                    title: 'عروض مميزة',
                    deals: viewModel.featuredDeals,
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllDealsScreen(
                            title: 'عروض مميزة',
                            deals: viewModel.allFeaturedDeals,
                          ),
                        ),
                      );
                    },
                  ),

                  // ✅ FIX 3: Better spacing before Ads (tablet only)
                  // لكي تتساوى المسافة (16) مع المسافة السفلية التي تحتوي على (4) + (12 من بادينج القسم)
                  SizedBox(height: isTablet ? 40.h : 16.h),

                  AdsSlider(fullBleed: true),

                  // 4.h + 12.h (DealSection header vertical padding) = 16.h total visual space
                  SizedBox(height: isTablet ? 16.h : 4.h),

                  DealSection(
                    title: 'عروض الطلاب',
                    deals: viewModel.studentDeals,
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllDealsScreen(
                            title: 'عروض الطلاب',
                            deals: viewModel.allStudentDeals,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 10.h),

                  DealSection(
                    title: 'عروض الأنشطة الترفيهية',
                    deals: viewModel.entertainmentDeals,
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewAllDealsScreen(
                            title: 'عروض الأنشطة الترفيهية',
                            deals: viewModel.allEntertainmentDeals,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: isTablet ? 80.h : 120.h,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Hero(
      tag: 'search_bar',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchView()),
            );
          },
          borderRadius: BorderRadius.circular(14.r),
          child: Ink(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppTheme.kLightBackground,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.kElectricLime),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'ابحث عن المتاجر والعروض...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(); // unchanged
  }
}

class _DiscoverNearbyCard extends StatefulWidget {
  final VoidCallback onTap;
  const _DiscoverNearbyCard({required this.onTap});

  @override
  State<_DiscoverNearbyCard> createState() => _DiscoverNearbyCardState();
}

class _DiscoverNearbyCardState extends State<_DiscoverNearbyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.durationFast,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            gradient: LinearGradient(
              colors: [
                AppTheme.kLightBackground,
                AppTheme.kElevatedBackground,
              ],
            ),
            border: Border.all(
              color: AppTheme.kElectricLime.withValues(alpha: 0.3),
            ),
            boxShadow: AppTheme.shadowMd,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.kElectricLime,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.glowLime,
                ),
                child: Icon(
                  Icons.map_outlined,
                  color: Colors.black,
                  size: AppTheme.iconMd,
                ),
              ),
              SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اكتشف العروض القريبة منك',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      'شاهد جميع العروض والخصومات بالقرب منك على الخريطة',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 18.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}