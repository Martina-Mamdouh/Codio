// lib/app/views/company_profile/widgets/reviews_statistics.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import '../../viewmodels/reviews_viewmodel.dart';

class ReviewsStatistics extends StatelessWidget {
  final ReviewsViewModel viewModel;

  const ReviewsStatistics({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // متوسط التقييم
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  viewModel.averageRating.toStringAsFixed(1),
                  style: TextStyle(
                    color: AppTheme.kElectricLime,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildStars(viewModel.averageRating),
                SizedBox(height: 8.h),
                Text(
                  '${viewModel.totalReviews} تقييم',
                  style: TextStyle(color: Colors.white54, fontSize: 14.sp),
                ),
              ],
            ),
          ),

          SizedBox(width: 20.w),

          // توزيع النجوم
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                return _buildRatingBar(
                  stars,
                  viewModel.getRatingPercentage(stars),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber, size: 20.w);
        } else if (index < rating) {
          return Icon(Icons.star_half, color: Colors.amber, size: 20.w);
        } else {
          return Icon(Icons.star_border, color: Colors.amber, size: 20.w);
        }
      }),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(color: Colors.white70, fontSize: 12.sp),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.star, color: Colors.amber, size: 14.w),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation(
                  AppTheme.kElectricLime,
                ),
                minHeight: 6.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 35.w,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(color: Colors.white54, fontSize: 11.sp),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
