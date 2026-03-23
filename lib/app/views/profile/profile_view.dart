import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kodio_app/app/views/profile/settings_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main_layout.dart';
import '../widgets/yellow_scaffold.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/user_profile_viewmodel.dart';
import '../auth/login_screen.dart';
import 'favorite_deals_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _initialized = false;
  Map<String, String> _socialLinks = {};

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }

  Future<void> _loadSocialLinks() async {
    final data = await SupabaseService().getAppSettings();
    if (mounted) setState(() => _socialLinks = data);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final authVm = context.read<AuthViewModel>();
        final profileVm = context.read<UserProfileViewModel>();

        if (authVm.currentUser != null) {
          profileVm.loadProfileData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final profileVm = context.watch<UserProfileViewModel>();
    final user = authVm.currentUser;

    return YellowScaffold(
      title: 'الملف الشخصي',
      showBackButton: true,
      onBackTap: () {
        context.findAncestorStateOfType<MainLayoutState>()?.switchToTab(0);
      },
      actions: [],
      body: user == null
          ? _buildGuestView(context)
          : _buildLoggedInView(context, user, profileVm, authVm),
    );
  }

  // لو المستخدم مش مسجّل
  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 80.w, color: Colors.white38),
          SizedBox(height: 16.h),
          Text(
            'قم بتسجيل الدخول لعرض ملفك الشخصي',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16.sp,
              //  // Inherited
            ),
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: 200.w,
            child: ElevatedButton(
              onPressed: () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kElectricLime,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  //  // Inherited
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // لو المستخدم مسجّل
  Widget _buildLoggedInView(
    BuildContext context,
    UserModel user,
    UserProfileViewModel profileVm,
    AuthViewModel authVm,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await profileVm.loadProfileData();
        await _loadSocialLinks();
      },
      color: AppTheme.kElectricLime,
      child: ListView(
        padding: EdgeInsets.only(
          top: 24.w,
          left: 24.w,
          right: 24.w,
          bottom: kBottomNavigationBarHeight + 40.h,
        ),
        children: [
          _buildHeader(user),
          SizedBox(height: 24.h),

          // أزرار القائمة
          Card(
            color: AppTheme.kLightBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.pinkAccent),
                  title: const Text(
                    'العروض المفضّلة',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FavoriteDealsView(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.blueAccent),
                  title: const Text(
                    'الإعدادات',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsView()),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // قسم التواصل الاجتماعي
          _buildSocialLinksCard(),

          SizedBox(height: 24.h),

          ElevatedButton.icon(
            onPressed: () async {
              await authVm.signOut();
              profileVm.clearFavorites();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تسجيل الخروج بنجاح')),
                );
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksCard() {
    // تعريف كل منصة: key في Supabase | label | icon | color
    final platforms = [
      _SocialLink(
        key: 'whatsapp_url',
        label: 'تواصل معنا عبر واتساب',
        icon: FontAwesomeIcons.whatsapp,
        color: const Color(0xFF25D366),
      ),
      _SocialLink(
        key: 'instagram_url',
        label: 'تابعنا على إنستقرام',
        icon: FontAwesomeIcons.instagram,
        color: const Color(0xFFE1306C),
      ),
      _SocialLink(
        key: 'telegram_url',
        label: 'تابعنا على تيليجرام',
        icon: FontAwesomeIcons.telegram,
        color: const Color(0xFF0088CC),
      ),
      _SocialLink(
        key: 'facebook_url',
        label: 'تابعنا على فيسبوك',
        icon: FontAwesomeIcons.facebook,
        color: const Color(0xFF1877F2),
      ),
      _SocialLink(
        key: 'tiktok_url',
        label: 'تابعنا على تيك توك',
        icon: FontAwesomeIcons.tiktok,
        color: Colors.white,
      ),
      _SocialLink(
        key: 'linkedin_url',
        label: 'تابعنا على لينكد إن',
        icon: FontAwesomeIcons.linkedin,
        color: const Color(0xFF0A66C2),
      ),
    ];

    // لو عايزة تشوفي كل الزراير حتى لو اللينك فاضي
    final activeLinks = platforms;

    if (activeLinks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تواصل معنا',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Card(
          color: AppTheme.kLightBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              for (int i = 0; i < activeLinks.length; i++) ...[
                _buildSocialTile(activeLinks[i]),
                if (i < activeLinks.length - 1)
                  const Divider(height: 1, color: Colors.white12),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialTile(_SocialLink link) {
    final url = _socialLinks[link.key] ?? '';
    return ListTile(
      leading: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: link.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: FaIcon(link.icon, color: link.color, size: 20.sp),
        ),
      ),
      title: Text(
        link.label,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
      ),
      trailing: Icon(Icons.open_in_new, color: Colors.white38, size: 18.sp),
      onTap: () async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تعذّر فتح الرابط')));
          }
        }
      },
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32.w,
          backgroundColor: AppTheme.kElectricLime.withValues(alpha: 0.2),
          backgroundImage: user.avatarUrl != null
              ? NetworkImage(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null
              ? Text(
                  _buildInitials(user.fullName),
                  style: TextStyle(
                    color: AppTheme.kElectricLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                )
              : null,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.fullName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                user.email,
                style: TextStyle(color: Colors.white54, fontSize: 14.sp),
              ),
              if (user.profession.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 14.w,
                      color: AppTheme.kElectricLime,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        user.profession,
                        style: TextStyle(
                          color: AppTheme.kElectricLime,
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _buildInitials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

// Helper data class for social links
class _SocialLink {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _SocialLink({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}
