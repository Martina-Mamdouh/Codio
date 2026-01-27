import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../viewmodels/home_view_model.dart';
import 'notifications_view.dart';
import 'map_view.dart';
import 'widgets/home_banner_slider.dart';
import 'widgets/deal_section.dart';
import 'search_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.kElectricLime),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48.w),
                  SizedBox(height: 8.h),
                  Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: viewModel.fetchAllData,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.fetchAllData,
            color: AppTheme.kElectricLime,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Stack(
                children: [
                  // الخلفية الصفراء مع نصف استدارة من الأسفل
                  Container(
                    width: double.infinity,
                    height: 140.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5FF17),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(18),
                      ),
                    ),
                  ),
                  // الشعار والنوتيفيكيشن فوق الخلفية
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/slogan.png',
                              width: 120.w,
                              height: 60.h,
                              fit: BoxFit.contain,
                            ),
                            const Spacer(),
                            // IconButton(
                            //   icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
                            //   onPressed: () {
                            //     debugPrint('Notifications tapped');
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(builder: (_) => const NotificationsView()),
                            //     );
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // باقي الصفحة
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // search bar في منتصف الحد الفاصل بين الخلفيتين
                      SizedBox(height: 110.h),
                      Align(
                        alignment: Alignment.center,
                        child: Hero(
                          tag: 'search_bar',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation, secondaryAnimation) =>
                                            const SearchView(),
                                    transitionDuration: const Duration(
                                      milliseconds: 400,
                                    ),
                                    reverseTransitionDuration: const Duration(
                                      milliseconds: 300,
                                    ),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          // الشاشة تنزلق من تحت لفوق
                                          const begin = Offset(0.0, 1.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOutCubic;

                                          var tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));
                                          var offsetAnimation = animation.drive(
                                            tween,
                                          );

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14.r),
                              child: Ink(
                                width: MediaQuery.of(context).size.width * 0.88,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.kLightBackground,
                                  borderRadius: BorderRadius.circular(14.r),
                                  border: Border.all(color: Colors.white10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search,
                                      color: AppTheme.kElectricLime,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        'ابحث عن المتاجر والعروض...',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 15.sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 28.h),
                      HomeBannerSlider(banners: viewModel.banners),
                      SizedBox(height: 20.h),
                      /*
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _DiscoverNearbyCard(
                          onTap: () {
                            // TODO: Temporarily disabled - Coming Soon
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => const MapView(startNearby: true),
                            //   ),
                            // );
                            
                            // Show coming soon dialog
                            showDialog(
                              context: context,
                              builder: (context) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: AlertDialog(
                                  backgroundColor: AppTheme.kDarkBackground,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    side: BorderSide(color: AppTheme.kElectricLime.withOpacity(0.3)),
                                  ),
                                  title: Row(
                                    children: [
                                      Icon(Icons.schedule, color: AppTheme.kElectricLime, size: 28.w),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'قريباً',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    'هذه الميزة قيد التطوير وستكون متاحة قريباً!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'حسناً',
                                        style: TextStyle(
                                          color: AppTheme.kElectricLime,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      */
                      SizedBox(height: 6.h),
                      DealSection(
                        title: 'عروض جديدة',
                        deals: viewModel.newDeals,
                        onSeeAllTap: () {
                          debugPrint('See all new deals tapped');
                        },
                      ),
                      SizedBox(height: 8.h),
                      DealSection(
                        title: 'تنتهي قريباً',
                        deals: viewModel.expiringDeals,
                        onSeeAllTap: () {
                          debugPrint('See all expiring deals tapped');
                        },
                      ),
                      SizedBox(height: 8.h),
                      DealSection(
                        title: 'عروض مميزة',
                        deals: viewModel.featuredDeals,
                        onSeeAllTap: () {
                          debugPrint('See all featured deals tapped');
                        },
                      ),
                      SizedBox(height: 8.h),
                      DealSection(
                        title: 'عروض الطلاب',
                        deals: viewModel.studentDeals,
                        onSeeAllTap: () {
                          debugPrint('See all student deals tapped');
                        },
                      ),
                      SizedBox(height: 6.h),
                      DealSection(
                        title: 'عروض الأنشطة الترفيهية',
                        deals: viewModel.entertainmentDeals,
                        onSeeAllTap: () {
                          debugPrint('See all entertainment deals tapped');
                        },
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DiscoverNearbyCard extends StatelessWidget {
  final VoidCallback onTap;
  const _DiscoverNearbyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF2D2D2D), Color(0xFF3A3A3A)],
          ),
          border: Border.all(color: AppTheme.kElectricLime.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppTheme.kElectricLime,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_outlined, color: Colors.black),
            ),
            SizedBox(width: 12.w),
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
                  SizedBox(height: 4.h),
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
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 18.w),
          ],
        ),
      ),
    );
  }
}
