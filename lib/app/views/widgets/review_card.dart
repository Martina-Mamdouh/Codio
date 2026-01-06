// lib/app/views/company_profile/widgets/review_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/review_model.dart';
import '../../../../core/theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final bool isCurrentUser;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.isCurrentUser = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: isCurrentUser
            ? Border.all(color: AppTheme.kElectricLime.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (معلومات المستخدم + التقييم)
          Row(
            children: [
              // صورة المستخدم
              CircleAvatar(
                radius: 20.w,
                backgroundColor: AppTheme.kElectricLime.withValues(alpha: 0.2),
                backgroundImage: review.userAvatar != null
                    ? NetworkImage(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Text(
                        _getInitials(review.userName ?? 'مستخدم'),
                        style: const TextStyle(
                          color: AppTheme.kElectricLime,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              SizedBox(width: 12.w),

              // الاسم والتاريخ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: []),
                    SizedBox(height: 4.h),

                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(color: Colors.white38, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 4.w),
              if (isCurrentUser)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.kElectricLime.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'تقييمك',
                    style: TextStyle(
                      color: AppTheme.kElectricLime,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              SizedBox(width: 16.w),

              // النجوم
              _buildStars(review.rating),

              // أيقونات التعديل والحذف
              if (isCurrentUser) ...[
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white54,
                    size: 20.w,
                  ),
                  color: AppTheme.kDarkBackground,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.white70, size: 18.w),
                          SizedBox(width: 8.w),
                          const Text(
                            'تعديل',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18.w),
                          SizedBox(width: 8.w),
                          const Text(
                            'حذف',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                ),
              ],
            ],
          ),

          // التعليق
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              review.comment!,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16.w,
        );
      }),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'م';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    }
  }
}
