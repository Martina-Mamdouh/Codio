import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kodio_app/app/views/widgets/company_deals_tab.dart';
import 'package:kodio_app/app/views/widgets/company_info_tab.dart';
import 'package:kodio_app/app/views/widgets/company_reviews_tab.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../viewmodels/company_profile_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/analytics_service.dart';
import 'auth/login_screen.dart';
// ✅ Import UserProfileViewModel
import '../viewmodels/user_profile_viewmodel.dart';
import '../../core/models/company_model.dart';

class CompanyProfileView extends StatelessWidget {
  final int companyId;
  final CompanyModel? company; // Instant Load Data
  
  const CompanyProfileView({
    super.key, 
    required this.companyId, 
    this.company,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyProfileViewModel(companyId, initialCompany: company),
      child: const _CompanyProfileScaffold(),
    );
  }
}

class _CompanyProfileScaffold extends StatelessWidget {
  const _CompanyProfileScaffold();

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: AppTheme.kDarkBackground,
        body: Consumer<CompanyProfileViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.kElectricLime,
                ),
              );
            }
            if (vm.errorMessage != null || vm.company == null) {
              return Center(
                child: Text(
                  vm.errorMessage ?? 'حدث خطأ غير متوقع',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
               // Sync with global user profile state
               final userVm = context.read<UserProfileViewModel>();
               if (vm.company != null) {
                  final isGlobalFollowed = userVm.followedCompanies.any((c) => c.id == vm.companyId);
                  vm.checkFollowStatus(isGlobalFollowed);
               }
            });

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Container(
                      color: AppTheme.kDarkBackground,
                      child: Column(
                        children: [
                          // Cover Image + Back Button
                          SizedBox(
                            // height: 200.h, // Removed fixed height to allow AspectRatio to control height
                            child: Stack(
                              children: [
                                // Cover Image
                                  AspectRatio(
                                    aspectRatio: 1280 / 700,
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.white,
                                      child: vm.company!.coverImageUrl != null &&
                                              vm.company!.coverImageUrl!.isNotEmpty
                                          ? Image.network(
                                              vm.company!.coverImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stack) =>
                                                  Container(color: Colors.white),
                                            )
                                          : null,
                                    ),
                                  ),
                                // Back Button
                                Positioned(
                                  top: 40.h,
                                  right: 16.w,
                                  child: CircleAvatar(
                                    backgroundColor:
                                        Colors.black.withOpacity(0.6),
                                    radius: 20.w,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                        size: 18.w,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Company Info Section
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                // Name, Followers, Follow Button
                                Row(
                                  children: [
                                    // Logo
                                    Container(
                                      width: 60.w,
                                      height: 60.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: vm.company!.logoUrl != null &&
                                              vm.company!.logoUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12.r),
                                              child: Image.network(
                                                vm.company!.logoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stack) =>
                                                    Icon(
                                                  Icons.business,
                                                  color: Colors.grey,
                                                  size: 30.w,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.business,
                                              color: Colors.grey,
                                              size: 30.w,
                                            ),
                                    ),
                                    SizedBox(width: 12.w),
                                    // Name and Followers
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vm.company!.name,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                                                          // fontFamily: 'Cairo', // Inherited
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${vm.company!.followersCount ?? 0} متابع',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12.sp,
                                                                          // fontFamily: 'Cairo', // Inherited
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Follow Button
                                    InkWell(
                                      onTap: vm.isFollowLoading
                                          ? null
                                          : () async {
                                              if (auth.currentUser != null) {
                                                // 1. Calculate Optimistic State
                                                final bool isCurrentlyFollowed = vm.isFollowed;
                                                final bool willBeFollowed = !isCurrentlyFollowed;

                                                // 2. Update Global State IMMEDIATELY (Optimistic)
                                                // This ensures "Following" page is updated instantly
                                                if (context.mounted &&
                                                    vm.company != null) {
                                                  context
                                                      .read<
                                                          UserProfileViewModel>()
                                                      .updateFollowStatusLocal(
                                                          vm.company!,
                                                          willBeFollowed);
                                                }

                                                // 3. Perform Network Request & Local State Update
                                                final success = await vm.toggleFollow();

                                                // 4. Revert if failed (Optional safety)
                                                if (!success && context.mounted && vm.company != null) {
                                                   context
                                                      .read<
                                                          UserProfileViewModel>()
                                                      .updateFollowStatusLocal(
                                                          vm.company!,
                                                          isCurrentlyFollowed); // Revert to old state
                                                }
                                              } else {
                                                _showLoginSnackBar(context);
                                              }
                                            },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: vm.isFollowed
                                              ? AppTheme.kElectricLime
                                              : Colors.transparent,
                                          border: vm.isFollowed
                                              ? null
                                              : Border.all(
                                                  color:
                                                      AppTheme.kElectricLime,
                                                  width: 1.5,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(20.r),
                                        ),
                                        child: Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  FaIcon(
                                                    vm.isFollowed
                                                        ? FontAwesomeIcons
                                                            .check
                                                        : FontAwesomeIcons
                                                            .plus,
                                                    size: 14.sp,
                                                    color: vm.isFollowed
                                                        ? Colors.black
                                                        : AppTheme
                                                            .kElectricLime,
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Text(
                                                    vm.isFollowed
                                                        ? 'متابَع'
                                                        : 'متابعة',
                                                    style: TextStyle(
                                                      color: vm.isFollowed
                                                          ? Colors.black
                                                          : AppTheme
                                                              .kElectricLime,
                                                      fontSize: 13.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                                                  // fontFamily: 'Cairo', // Inherited
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),
                                // 3 Action Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _ActionButton(
                                      icon: Icons.share_outlined,
                                      label: 'مشاركة',
                                      onTap: () => _shareCompany(
                                        name: vm.company!.name,
                                        website: vm.company!.website,
                                      ),
                                    ),
                                    _ActionButton(
                                      icon: Icons.phone_outlined,
                                      label: 'اتصال',
                                      onTap: () {
                                        if ((vm.company!.phone ?? '').isEmpty) {
                                          _showNotAvailable(context, 'رقم الهاتف');
                                        } else {
                                          try {
                                            context.read<AnalyticsService>().trackPhoneClick(
                                                vm.companyId,
                                                phone: vm.company!.phone);
                                          } catch (e) {
                                            debugPrint('⚠️ Analytics Error (Phone): $e');
                                          }
                                          _callPhone(vm.company!.phone);
                                        }
                                      },
                                    ),
                                    _ActionButton(
                                      icon: Icons.language,
                                      label: 'الموقع الالكتروني',
                                      onTap: () {
                                        if ((vm.company!.website ?? '').isEmpty) {
                                          _showNotAvailable(context, 'الموقع الإلكتروني');
                                        } else {
                                          try {
                                            context.read<AnalyticsService>().trackWebsiteClick(
                                                vm.companyId,
                                                url: vm.company!.website);
                                          } catch (e) {
                                            debugPrint('⚠️ Analytics Error (Website): $e');
                                          }
                                          _openWebsite(vm.company!.website);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverTabBarDelegate(
                      TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: UnderlineTabIndicator(
                          borderSide: const BorderSide(
                            color: AppTheme.kElectricLime,
                            width: 2,
                          ),
                          insets: EdgeInsets.symmetric(horizontal: 14.w),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        labelStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                                                      // fontFamily: 'Cairo', // Inherited
                        ),
                        tabs: const [
                          Tab(text: 'العروض'),
                          Tab(text: 'معلومات'),
                          Tab(text: 'مراجعات'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  CompanyDealsTab(viewModel: vm),
                  CompanyInfoTab(viewModel: vm),
                  ReviewsTab(companyId: vm.companyId),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLoginSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 24.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'يجب تسجيل الدخول لمتابعة الشركات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kElectricLime,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              },
              child: Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.kDarkBackground,
        elevation: 6,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: AppTheme.kElectricLime.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }

  // Helpers
  Uri _normalizeWeb(String url) {
    final u = url.trim();
    if (u.isEmpty) return Uri();
    return u.startsWith('http://') || u.startsWith('https://')
        ? Uri.parse(u)
        : Uri.parse('https://$u');
  }

  Future<void> _openWebsite(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    try {
      final uri = _normalizeWeb(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('لا يمكن فتح $uri');
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.trim().isEmpty) return;
    try {
      final uri = Uri(scheme: 'tel', path: phone.trim());
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('لا يمكن إجراء اتصال');
      }
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _shareCompany({required String name, String? website}) async {
    try {
      // TODO: Update these links when app is published
      const String appLink = 'https://kodio.app'; // موقع التطبيق المؤقت
      // const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.example.kodioapp';
      // const String appStoreLink = 'https://apps.apple.com/app/kodio/id';

      final message =
          '''
✨ $name على تطبيق Codio

🎁 عروض حصرية | 💳 كوبونات خصم | ⚡ صفقات يومية

📲 حمّل التطبيق الآن:
$appLink

${website != null && website.isNotEmpty ? '🔗 $website' : ''}
    '''
              .trim();

      await Share.share(message, subject: 'عروض $name');
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }
}

// Show Not Available SnackBar
void _showNotAvailable(BuildContext context, String item) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$item غير متوفر',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          color: AppTheme.kLightText,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    ),
  );
}

// Action Button Widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24.w),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppTheme.kDarkBackground,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
