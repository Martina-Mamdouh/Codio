// privacy_policy_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: Colors.white10, width: 1),
        ),
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          // Logo
          Center(
            child: Image.asset(
              'assets/images/logo.jpg',
              width: 120.w,
              height: 120.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 24.h),
          
          Text(
            'هذه سياسة خصوصية مبسّطة ومبدئية لتطبيق كوديو، وتحتاج إلى مراجعة قانونية قبل اعتمادها بشكل نهائي.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '1. البيانات التي نجمعها',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'قد نقوم بجمع بعض البيانات الأساسية مثل البريد الإلكتروني، والاسم، وبيانات الاستخدام العامة للتطبيق '
            'بهدف تحسين الخدمة وتجربة المستخدم.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '2. كيف نستخدم البيانات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'تُستخدم البيانات لتخصيص المحتوى، وإرسال إشعارات بالعروض، وتحسين أداء التطبيق. '
            'لا نقوم ببيع بياناتك الشخصية لأطراف ثالثة.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '3. حقوقك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يمكنك طلب حذف حسابك أو تعديل بياناتك من داخل التطبيق أو عبر التواصل معنا من خلال معلومات الاتصال المتاحة.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
