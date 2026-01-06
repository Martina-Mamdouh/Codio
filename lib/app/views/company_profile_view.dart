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

class CompanyProfileView extends StatelessWidget {
  final int companyId;
  const CompanyProfileView({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyProfileViewModel(companyId),
      child: const _CompanyProfileScaffold(),
    );
  }
}

class _CompanyProfileScaffold extends StatelessWidget {
  const _CompanyProfileScaffold();

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        initialIndex: 0, // Changed to 0 to show "العروض" first
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

              return Column(
                children: [
                  // Fixed Header Section
                  Container(
                    color: AppTheme.kDarkBackground,
                    child: Column(
                      children: [
                        // Cover Image + Back Button
                        SizedBox(
                          height: 200.h,
                          child: Stack(
                            children: [
                              // Cover Image (مؤقتاً بيضاء)
                              Container(
                                width: double.infinity,
                                height: 200.h,
                                color: Colors.white,
                                child:
                                    vm.company!.coverImageUrl != null &&
                                        vm.company!.coverImageUrl!.isNotEmpty
                                    ? Image.network(
                                        vm.company!.coverImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                          Container(color: Colors.white),
                                      )
                                    : null,
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
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child:
                                        vm.company!.logoUrl != null &&
                                            vm.company!.logoUrl!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
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
                                        Text(
                                          vm.company!.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Cairo',
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
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Follow Button
                                  InkWell(
                                    onTap: vm.isFollowLoading
                                        ? null
                                        : () {
                                            if (auth.currentUser != null) {
                                              vm.toggleFollow();
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.info_outline,
                                                        color: Colors.white,
                                                        size: 24.w,
                                                      ),
                                                      SizedBox(width: 8.w),
                                                      Expanded(
                                                        child: Text(
                                                          'يجب تسجيل الدخول لمتابعة الشركات',
                                                          style: TextStyle(
                                                            fontFamily: 'Cairo',
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              AppTheme
                                                                  .kElectricLime,
                                                          foregroundColor:
                                                              Colors.black,
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    12.w,
                                                                vertical: 8.h,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8.r,
                                                                ),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  const LoginScreen(),
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).removeCurrentSnackBar();
                                                        },
                                                        child: Text(
                                                          'تسجيل الدخول',
                                                          style: TextStyle(
                                                            fontFamily: 'Cairo',
                                                            fontSize: 12.sp,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor:
                                                      AppTheme.kDarkBackground,
                                                  elevation: 6,
                                                  duration: const Duration(
                                                    seconds: 3,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.all(16.w),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.r,
                                                        ),
                                                    side: BorderSide(
                                                      color: AppTheme
                                                          .kElectricLime
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
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
                                                color: AppTheme.kElectricLime,
                                                width: 1.5,
                                              ),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: vm.isFollowLoading
                                          ? SizedBox(
                                              height: 16.w,
                                              width: 16.w,
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
                                                FaIcon(
                                                  vm.isFollowed
                                                      ? FontAwesomeIcons.check
                                                      : FontAwesomeIcons.plus,
                                                  size: 14.sp,
                                                  color: vm.isFollowed
                                                      ? Colors.black
                                                      : AppTheme.kElectricLime,
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
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Cairo',
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
                                          // Track phone click (safe-guarded)
                                          context.read<AnalyticsService>().trackPhoneClick(
                                            vm.companyId, 
                                            phone: vm.company!.phone
                                          );
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
                                        _showNotAvailable(
                                          context,
                                          'الموقع الإلكتروني',
                                        );
                                      } else {
                                        try {
                                          // Track website click (safe-guarded)
                                          context.read<AnalyticsService>().trackWebsiteClick(
                                            vm.companyId, 
                                            url: vm.company!.website
                                          );
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

                        // TabBar
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
                            fontFamily: 'Cairo',
                          ),
                          tabs: const [
                            Tab(text: 'العروض'),
                            Tab(text: 'معلومات'),
                            Tab(text: 'مراجعات'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // TabBarView (Scrollable Content)
                  Expanded(
                    child: TabBarView(
                      children: [
                        CompanyDealsTab(viewModel: vm),
                        CompanyInfoTab(viewModel: vm),
                        ReviewsTab(companyId: vm.companyId),
                      ],
                    ),
                  ),
                ],
              );
            },
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
