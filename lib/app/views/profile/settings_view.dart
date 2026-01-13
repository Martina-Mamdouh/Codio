import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kodio_app/app/views/profile/rate_codio.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../terms_view.dart';
import 'about_app_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool notificationsEnabled = true;
  bool offersOnlyEnabled = false;

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // ===== قسم عام =====
          Text(
            'عام',
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
                // إشعارات التطبيق
                SwitchListTile(
                  activeColor: AppTheme.kElectricLime,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 0,
                  ),
                  title: const Text(
                    'استلام الإشعارات',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'استقبل تنبيهات العروض الجديدة والتحديثات',
                    style: TextStyle(color: Colors.white54),
                  ),
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() => notificationsEnabled = value);
                    // TODO: أربطها فعلياً بـ OneSignal أو خدمة الإشعارات
                  },
                ),
                const Divider(height: 1, color: Colors.white12),

                // إشعارات العروض فقط
                SwitchListTile(
                  activeColor: AppTheme.kElectricLime,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 0,
                  ),
                  title: const Text(
                    'إشعارات العروض فقط',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'استقبل تنبيهات تخص العروض والخصومات فقط',
                    style: TextStyle(color: Colors.white54),
                  ),
                  value: offersOnlyEnabled,
                  onChanged: notificationsEnabled
                      ? (value) {
                          setState(() => offersOnlyEnabled = value);
                        }
                      : null,
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ===== قسم الحساب =====
          Text(
            'الحساب',
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
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: AppTheme.kElectricLime,
                  ),
                  title: const Text(
                    'البيانات الشخصية',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    authVm.currentUser?.fullName ?? 'غير محدد',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    _showEditProfileDialog(context, authVm);
                  },
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blueAccent),
                  title: const Text(
                    'البريد الإلكتروني',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    authVm.currentUser?.email ?? 'غير مسجل',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.orangeAccent),
                  title: const Text(
                    'تغيير كلمة المرور',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    // TODO: شاشة تغيير كلمة المرور
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // ===== قسم التطبيق =====
          Text(
            'التطبيق',
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
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.lightBlue,
                  ),
                  title: const Text(
                    'عن التطبيق',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Colors.orangeAccent,
                  ),
                  title: const Text(
                    'الشروط والأحكام',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsView()),
                    );
                  },
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.star_rate, color: Colors.amber),
                  title: const Text(
                    'قيّم التطبيق',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'ساعدنا بتقييم تجربتك على المتجر',
                    style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () async {
                    try {
                      await StoreService.openStorePage();
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تعذّر فتح صفحة المتجر'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthViewModel authVm) {
    final user = authVm.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final professionController = TextEditingController(text: user.profession);
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: AppTheme.kLightBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              'تعديل البيانات الشخصية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: nameController,
                      enabled: !isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: AppTheme.kElectricLime,
                        ),
                        filled: true,
                        fillColor: AppTheme.kDarkBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: AppTheme.kElectricLime,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    // Profession Field
                    TextFormField(
                      controller: professionController,
                      enabled: !isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'المهنة',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.work_outline,
                          color: AppTheme.kElectricLime,
                        ),
                        filled: true,
                        fillColor: AppTheme.kDarkBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(
                            color: AppTheme.kElectricLime,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: isLoading ? Colors.white30 : Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setState(() => isLoading = true);

                        final success = await authVm.updateProfile(
                          fullName: nameController.text.trim(),
                          profession: professionController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'تم تحديث البيانات بنجاح'
                                    : 'حدث خطأ أثناء التحديث',
                              ),
                              backgroundColor:
                                  success ? Colors.green : Colors.redAccent,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kElectricLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        'حفظ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
