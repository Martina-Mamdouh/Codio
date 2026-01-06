// terms_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

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
          'الشروط والأحكام',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          Text(
            'باستخدامك لتطبيق كوديو فإنك توافق على الشروط التالية بصورة عامة. '
            'هذه الشروط نموذجية ويجب مراجعتها قانونياً قبل الإطلاق التجاري.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '1. استخدام التطبيق',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يُسمح لك باستخدام التطبيق لأغراض شخصية فقط، ولا يجوز إساءة استخدام الخدمات أو استخدامها '
            'بطرق غير قانونية أو تضر بالآخرين.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '2. المحتوى والعروض',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'العروض والمحتوى المعروض في التطبيق يقدَّم من قِبل الشركات الشريكة، وقد تتغير أو تُلغى دون إشعار مسبق. '
            'التطبيق لا يضمن توافر أي عرض في كل الأوقات.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            '3. إخلاء المسؤولية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'التطبيق يقدَّم كما هو (AS IS) دون أي ضمانات صريحة أو ضمنية، ويجب عليك التحقق من تفاصيل أي عرض '
            'مباشرةً مع الشركة قبل الاستفادة منه.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
