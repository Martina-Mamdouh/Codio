// lib/app/views/company_profile/tabs/reviews_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kodio_app/app/viewmodels/auth_viewmodel.dart';
import 'package:kodio_app/app/views/auth/login_screen.dart';
import 'package:kodio_app/app/views/widgets/review_card.dart';
import 'package:kodio_app/app/views/widgets/reviews_statistics.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../core/models/review_model.dart';
import '../../viewmodels/reviews_viewmodel.dart';
import 'add_review_bottom_sheet.dart';

class ReviewsTab extends StatelessWidget {
  final int companyId;

  const ReviewsTab({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthViewModel>(context, listen: false);
    return ChangeNotifierProvider(
      create: (_) => ReviewsViewModel(companyId),
      child: Consumer<ReviewsViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.kElectricLime),
            );
          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 48.w),
                  SizedBox(height: 16.h),
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: vm.loadReviews,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: vm.loadReviews,
            color: AppTheme.kElectricLime,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الإحصائيات
                  ReviewsStatistics(viewModel: vm),

                  SizedBox(height: 20.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (auth.currentUser == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
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
                                      'يرجى تسجيل الدخول لإضافة تقييم',
                                      style: TextStyle(
                                        // fontFamily: 'Cairo', // Inherited
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 8.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).removeCurrentSnackBar();
                                    },
                                    child: Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        // fontFamily: 'Cairo', // Inherited
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
                                  color: AppTheme.kElectricLime.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                          return;
                        } else {
                          _showAddReviewBottomSheet(context, vm);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vm.hasUserReviewed
                            ? AppTheme.kElectricLime.withValues(alpha: 0.2)
                            : AppTheme.kElectricLime,
                        foregroundColor: vm.hasUserReviewed
                            ? AppTheme.kElectricLime
                            : AppTheme.kDarkBackground,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: Icon(vm.hasUserReviewed ? Icons.edit : Icons.add),
                      label: Text(
                        vm.hasUserReviewed ? 'تعديل تقييمك' : 'أضف تقييمك',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // عنوان التقييمات
                  if (vm.reviews.isNotEmpty) ...[
                    Row(
                      children: [
                        Text(
                          'التقييمات',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '(${vm.totalReviews})',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // قائمة التقييمات
                  if (vm.reviews.isEmpty)
                    Container(
                      padding: EdgeInsets.all(32.w),
                      decoration: BoxDecoration(
                        color: AppTheme.kLightBackground,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 64.w,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد تقييمات بعد',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'كن أول من يقيّم هذه الشركة',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vm.reviews.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final review = vm.reviews[index];
                        final isCurrentUser = vm.isUserReview(review);

                        return ReviewCard(
                          review: review,
                          isCurrentUser: isCurrentUser,
                          onEdit: isCurrentUser
                              ? () => _showEditDialog(context, vm, review)
                              : null,
                          onDelete: isCurrentUser
                              ? () => _showDeleteDialog(context, vm)
                              : null,
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    ReviewsViewModel vm,
    ReviewModel review,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReviewBottomSheet(
        viewModel: vm,
        initialRating: review.rating,
        initialComment: review.comment,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ReviewsViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.kLightBackground,
        title: const Text('حذف التقييم', style: TextStyle(color: Colors.white)),
        content: const Text(
          'هل أنت متأكد من حذف تقييمك؟',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await vm.deleteReview();
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف التقييم بنجاح')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewBottomSheet(BuildContext context, ReviewsViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReviewBottomSheet(
        viewModel: vm,
        initialRating: vm.userReview?.rating,
        initialComment: vm.userReview?.comment,
      ),
    );
  }
}
