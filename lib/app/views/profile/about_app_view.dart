// lib/app/views/settings/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kodio_app/core/constants/app_constants.dart';
import 'package:kodio_app/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/update_service.dart';
import '../../../core/services/version_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.kDarkBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.kDarkBackground,
          title: const Text(
            'حول التطبيق',
            style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // App Logo
              Container(
                width: 140.w,
                height: 140.w,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppTheme.kElectricLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppTheme.kElectricLime.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  width: 120.w,
                  height: 120.h,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 16.h),

              // App Name
              Text(
                AppConstants.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                                    // fontFamily: 'Cairo', // Inherited
                ),
              ),

              SizedBox(height: 8.h),

              // Version
              Text(
                'الإصدار ${VersionService.fullVersion}',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14.sp,
                                    // fontFamily: 'Cairo', // Inherited
                ),
              ),

              SizedBox(height: 32.h),

              //  Description
              Text(
                'تطبيق Codio يوفر لك أفضل العروض والخصومات من مختلف الشركات والمتاجر',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                  height: 1.6,
                                    // fontFamily: 'Cairo', // Inherited
                ),
              ),

              //  Copyright
              Text(
                '© 2025 Codio. جميع الحقوق محفوظة',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12.sp,
                                    // fontFamily: 'Cairo', // Inherited
                ),
              ),

              SizedBox(height: 32.h),

              // Links
              _LinkTile(
                icon: Icons.language,
                title: 'الموقع الإلكتروني',
                onTap: () => _openUrl(AppConstants.appWebsite),
              ),

              _LinkTile(
                icon: Icons.email_outlined,
                title: 'الدعم الفني',
                subtitle: AppConstants.supportEmail,
                onTap: () => _openUrl('mailto:${AppConstants.supportEmail}'),
              ),

              _LinkTile(
                icon: Icons.privacy_tip_outlined,
                title: 'سياسة الخصوصية',
                onTap: () => _openUrl(AppConstants.privacyPolicyUrl),
              ),

              _LinkTile(
                icon: Icons.description_outlined,
                title: 'الشروط والأحكام',
                onTap: () => _openUrl(AppConstants.termsUrl),
              ),

              SizedBox(height: 32.h),

              // Check for Updates Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => UpdateService.checkForUpdate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kElectricLime,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'التحقق من التحديثات',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                                        // fontFamily: 'Cairo', // Inherited
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              // Copyright
              Text(
                '© 2025 Codio. جميع الحقوق محفوظة',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12.sp,
                                    // fontFamily: 'Cairo', // Inherited
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppTheme.kDarkBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.kElectricLime, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                                        // fontFamily: 'Cairo', // Inherited
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12.sp,
                                          // fontFamily: 'Cairo', // Inherited
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16.w),
          ],
        ),
      ),
    );
  }
}
