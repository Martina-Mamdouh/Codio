import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kodio_app/app/views/widgets/company_deals_tab.dart';
import 'package:kodio_app/app/views/widgets/company_info_tab.dart';
import 'package:kodio_app/app/views/widgets/company_reviews_tab.dart';
import 'package:kodio_app/app/views/widgets/app_snackbar.dart';
import 'package:kodio_app/app/views/widgets/shimmer_loading.dart';
import 'package:kodio_app/app/views/widgets/state_widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../viewmodels/company_profile_view_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/services/analytics_service.dart';
import 'auth/login_screen.dart';
import '../viewmodels/user_profile_viewmodel.dart';
import '../../core/models/company_model.dart';

class CompanyProfileView extends StatelessWidget {
  final int companyId;
  final CompanyModel? company; // Instant Load Data

  const CompanyProfileView({super.key, required this.companyId, this.company});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          CompanyProfileViewModel(companyId, initialCompany: company),
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
              return const ShimmerCompanyProfile();
            }
            if (vm.errorMessage != null || vm.company == null) {
              return ErrorState(
                message: vm.errorMessage ?? 'حدث خطأ غير متوقع',
                onRetry: () {
                  // Trigger refresh
                  context.read<CompanyProfileViewModel>().refresh();
                },
              );
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Sync with global user profile state
              final userVm = context.read<UserProfileViewModel>();
              if (vm.company != null) {
                final isGlobalFollowed = userVm.followedCompanies.any(
                  (c) => c.id == vm.companyId,
                );
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
                                    child:
                                        vm.company!.coverImageUrl != null &&
                                            vm
                                                .company!
                                                .coverImageUrl!
                                                .isNotEmpty
                                        ? Image.network(
                                            vm.company!.coverImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stack) =>
                                                    Container(
                                                      color: Colors.white,
                                                    ),
                                          )
                                        : null,
                                  ),
                                ),
                                // Back Button
                                Positioned(
                                  top: 40.h,
                                  right: 16.w,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black.withValues(
                                      alpha: 0.6,
                                    ),
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
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child:
                                          vm.company!.logoUrl != null &&
                                              vm.company!.logoUrl!.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              child: Image.network(
                                                vm.company!.logoUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stack) =>
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  vm.company!.name,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (vm.company!.isPartner == true) ...[
                                                SizedBox(width: 4.w),
                                                Icon(
                                                  Icons.verified,
                                                  color: AppTheme.kElectricLime,
                                                  size: 16.sp,
                                                ),
                                              ],
                                            ],
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${vm.company!.followersCount ?? 0} متابع',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12.sp,
                                              //  // Inherited
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Follow Button
                                    GestureDetector(
                                      onTap: vm.isFollowLoading
                                          ? null
                                          : () async {
                                              HapticFeedback.lightImpact();
                                              if (auth.currentUser != null) {
                                                // 1. Calculate Optimistic State
                                                final bool isCurrentlyFollowed =
                                                    vm.isFollowed;
                                                final bool willBeFollowed =
                                                    !isCurrentlyFollowed;

                                                // 2. Update Global State IMMEDIATELY (Optimistic)
                                                if (context.mounted &&
                                                    vm.company != null) {
                                                  context
                                                      .read<
                                                        UserProfileViewModel
                                                      >()
                                                      .updateFollowStatusLocal(
                                                        vm.company!,
                                                        willBeFollowed,
                                                      );
                                                }

                                                // 3. Perform Network Request & Local State Update
                                                final success = await vm
                                                    .toggleFollow();

                                                // 4. Revert if failed
                                                if (!success &&
                                                    context.mounted &&
                                                    vm.company != null) {
                                                  context
                                                      .read<
                                                        UserProfileViewModel
                                                      >()
                                                      .updateFollowStatusLocal(
                                                        vm.company!,
                                                        isCurrentlyFollowed,
                                                      );
                                                  AppSnackbar.error(
                                                    context,
                                                    'فشل في تحديث المتابعة',
                                                  );
                                                }
                                              } else {
                                                // No user (guest or not logged in)
                                                AppSnackbar.loginRequired(
                                                  context,
                                                  onLogin: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const LoginScreen(),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                      child: AnimatedContainer(
                                        duration: AppTheme.durationNormal,
                                        curve: AppTheme.curveDefault,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppTheme.spacing20,
                                          vertical: AppTheme.spacing10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: vm.isFollowed
                                              ? AppTheme.kElectricLime
                                              : Colors.transparent,
                                          border: vm.isFollowed
                                              ? null
                                              : Border.all(
                                                  color: AppTheme.kElectricLime,
                                                  width: 1.5,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusFull,
                                          ),
                                          boxShadow: vm.isFollowed
                                              ? AppTheme.glowLime
                                              : null,
                                        ),
                                        child: vm.isFollowLoading
                                            ? SizedBox(
                                                width: 18.w,
                                                height: 18.w,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: vm.isFollowed
                                                      ? Colors.black
                                                      : AppTheme.kElectricLime,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  AnimatedSwitcher(
                                                    duration: AppTheme.durationFast,
                                                    child: FaIcon(
                                                      vm.isFollowed
                                                          ? FontAwesomeIcons.check
                                                          : FontAwesomeIcons.plus,
                                                      key: ValueKey(vm.isFollowed),
                                                      size: 14.sp,
                                                      color: vm.isFollowed
                                                          ? Colors.black
                                                          : AppTheme.kElectricLime,
                                                    ),
                                                  ),
                                                  SizedBox(width: AppTheme.spacing8),
                                                  Text(
                                                    vm.isFollowed
                                                        ? 'متابَع'
                                                        : 'متابعة',
                                                    style: TextStyle(
                                                      color: vm.isFollowed
                                                          ? Colors.black
                                                          : AppTheme.kElectricLime,
                                                      fontSize: 13.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (vm.company!.description != null &&
                                    vm.company!.description!.isNotEmpty) ...[
                                  SizedBox(height: 16.h),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: AppTheme.kLightBackground,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Colors.white10),
                                    ),
                                    child: Text(
                                      vm.company!.description!,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12.sp,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 24.h),
                                // 3 Action Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                          _showNotAvailable(
                                            context,
                                            'رقم الهاتف',
                                          );
                                        } else {
                                          try {
                                            context
                                                .read<AnalyticsService>()
                                                .trackPhoneClick(
                                                  vm.companyId,
                                                  phone: vm.company!.phone,
                                                );
                                          } catch (e) {
                                            debugPrint(
                                              '⚠️ Analytics Error (Phone): $e',
                                            );
                                          }
                                          _callPhone(vm.company!.phone);
                                        }
                                      },
                                    ),
                                    _ActionButton(
                                      icon: Icons.language,
                                      label: 'الموقع الالكتروني',
                                      onTap: () {
                                        if ((vm.company!.website ?? '')
                                            .isEmpty) {
                                          _showNotAvailable(
                                            context,
                                            'الموقع الإلكتروني',
                                          );
                                        } else {
                                          try {
                                            context
                                                .read<AnalyticsService>()
                                                .trackWebsiteClick(
                                                  vm.companyId,
                                                  url: vm.company!.website,
                                                );
                                          } catch (e) {
                                            debugPrint(
                                              '⚠️ Analytics Error (Website): $e',
                                            );
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
                          //  // Inherited
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
  AppSnackbar.warning(context, '$item غير متوفر');
}

// Action Button Widget
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
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
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          decoration: BoxDecoration(
            color: AppTheme.kLightBackground,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppTheme.kCardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: AppTheme.kElectricLime,
                size: AppTheme.iconMd,
              ),
              SizedBox(height: AppTheme.spacing6),
              Text(
                widget.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
    return Container(color: AppTheme.kDarkBackground, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
