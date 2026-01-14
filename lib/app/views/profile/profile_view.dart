import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kodio_app/app/views/profile/settings_view.dart';
import 'package:provider/provider.dart';
import '../../main_layout.dart';
import '../widgets/yellow_scaffold.dart';

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
                                // fontFamily: 'Cairo', // Inherited
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
                                    // fontFamily: 'Cairo', // Inherited
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
      onRefresh: profileVm.loadProfileData,
      color: AppTheme.kElectricLime,
      child: ListView(
        padding: EdgeInsets.all(24.w),
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
                  // subtitle: Text(
                  //   '${profileVm.favoriteDealIds.length} عرض',
                  //   style: const TextStyle(color: Colors.white54),
                  // ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // await profileVm.loadFavoriteDeals();
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
