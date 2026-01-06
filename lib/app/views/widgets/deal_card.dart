import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/models/deal_model.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../../core/services/analytics_service.dart';
import '../auth/login_screen.dart';

class DealCard extends StatelessWidget {
  final DealModel deal;
  final VoidCallback? onTap;

  // ⭐ New fields
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const DealCard({
    super.key,
    required this.deal,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(deal.expiresAt);
    final AuthService authService = AuthService();

    return GestureDetector(
      onTap: () {
        debugPrint('🖱️ DealCard tapped: ${deal.id}');
        try {
          // Track card click (safe-guarded)
          context.read<AnalyticsService>().trackDealCardClick(deal.id);
        } catch (e) {
          debugPrint('⚠️ Analytics Error in DealCard: $e');
        }
        
        if (onTap != null) {
          debugPrint('➡️ Triggering navigation for: ${deal.title}');
          onTap!();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.kLightBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // -------------------- IMAGE --------------------
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: deal.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: deal.imageUrl,
                          height: 120.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          memCacheWidth: 500,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        )
                      : Container(
                          height: 120.h,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
                // -------------------- DISCOUNT BADGE --------------------
                if (deal.discountValue.isNotEmpty)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        deal.discountValue,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                // -------------------- FAVORITE BUTTON --------------------
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      if (authService.currentUser == null) {
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
                                    'يجب تسجيل الدخول لإضافة المفضلات',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
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
                                      borderRadius: BorderRadius.circular(8.r),
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
                                      fontFamily: 'Cairo',
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
                      }
                      // Toggle favorite status
                      if (onFavoriteToggle != null) {
                        onFavoriteToggle!();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 20.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            // -------------------- INFO SECTION --------------------
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 8.0.w,
                    left: 8.0.w,
                    top: 8.0.h,
                    bottom: 16.0.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.kLightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 14.w, color: Colors.redAccent),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'ينتهي في: $formattedDate',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
