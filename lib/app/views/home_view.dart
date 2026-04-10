import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/home_view_model.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'notifications_view.dart';
import 'map_view.dart';
import 'widgets/home_banner_slider.dart';
import 'widgets/deal_section.dart';
import 'widgets/state_widgets.dart';
import 'widgets/shimmer_loading.dart';
import 'search_view.dart';
import 'view_all_deals_screen.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          return RefreshIndicator(
            onRefresh: viewModel.fetchAllData,
            color: AppTheme.kElectricLime,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height:
                        (MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? 160.h
                            : 140.h) +
                        30.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background
                        Container(
                          width: double.infinity,
                          height:
                              MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 160.h
                              : 140.h,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5FF17),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(18),
                            ),
                          ),
                        ),
                        // Logo & Notifs
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/slogan.png',
                                    width: 120.w,
                                    height: 50.h,
                                    fit: BoxFit.contain,
                                  ),
                                  const Spacer(),
                                   Consumer<NotificationsViewModel>(
                                     builder: (context, notificationsVm, _) {
                                       return Stack(
                                         clipBehavior: Clip.none,
                                         children: [
                                           // Make the notification icon use the same
                                           // circular lime background & sizing used
                                           // elsewhere for visual consistency.
                                           Container(
                                             padding: EdgeInsets.all(AppTheme.spacing12),
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
                                                     builder: (_) => const NotificationsView(),
                                                   ),
                                                 );
                                               },
                                             ),
                                           ),
                                           if (notificationsVm.newNotifications.isNotEmpty)
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
                        // Search Bar Positioned to straddle
                        Positioned(
                          top: (MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? 160.h
                                  : 140.h) -
                              25.h,
                          left: 0,
                          right: 0,
                          child: Center(child: _buildSearchBar(context)),
                        ),
                      ],
                    ),
                  ),

                  // Rest of the content following the header
                  SizedBox(height: 12.h), // Further reduced space for search bar overlap

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
                  SizedBox(height: 4.h), // Further reduced gap between Discover card and next section


                  // Nearby Slider Section ✅
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
                    SizedBox(height: 4.h), // Reduced and consistent spacing
                  ],

                  SizedBox(height: 4.h), // Consistent small gap when nearby section is absent
                  
                  // Nearby Banner button moved here ✅


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
                  SizedBox(height: 8.h),
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
                  SizedBox(height: 8.h),
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
                  SizedBox(height: 8.h),
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
                  SizedBox(height: 6.h),
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
                  
                  // ✅ Added extra space at the end of the scroll to clear the floating nav bar
                  SizedBox(height: 120.h),
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
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const SearchView(),
                transitionDuration: const Duration(milliseconds: 300), reverseTransitionDuration: const Duration(milliseconds: 250),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(
                        0.0,
                        0.05,
                      ); // Subtle lift instead of full slide
                      const end = Offset.zero;
                      const curve = Curves.easeOutCubic;
                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var fadeTween = Tween<double>(begin: 0.0, end: 1.0);

                      return FadeTransition(
                        opacity: animation.drive(fadeTween),
                        child: SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        ),
                      );
                    },
              ),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppTheme.kElectricLime),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'ابحث عن المتاجر والعروض...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 15.sp),
                    overflow: TextOverflow.ellipsis,
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
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Header shimmer
          Container(
            width: double.infinity,
            height: 170.h,
            decoration: BoxDecoration(
              color: AppTheme.kElectricLime.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacing48),

          // Banner shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: ShimmerLoading(
              child: ShimmerBox(
                width: double.infinity,
                height: 160.h,
                borderRadius: AppTheme.radiusLg,
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacing24),

          // Discover nearby shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
            child: ShimmerLoading(
              child: ShimmerBox(
                width: double.infinity,
                height: 80.h,
                borderRadius: AppTheme.radiusLg,
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacing24),

          // Deal sections shimmer
          for (int i = 0; i < 3; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerLoading(
                    child: ShimmerBox(width: 100.w, height: 20.h),
                  ),
                  ShimmerLoading(
                    child: ShimmerBox(width: 60.w, height: 16.h),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacing12),
            SizedBox(
              height: 220.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                itemCount: 3,
                separatorBuilder: (_, __) =>
                    SizedBox(width: AppTheme.spacing12),
                itemBuilder: (_, __) => const ShimmerDealCard(),
              ),
            ),
            SizedBox(height: AppTheme.spacing24),
          ],
        ],
      ),
    );
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
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
              colors: [AppTheme.kLightBackground, AppTheme.kElevatedBackground],
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
                      style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18.w),
            ],
          ),
        ),
      ),
    );
  }
}
