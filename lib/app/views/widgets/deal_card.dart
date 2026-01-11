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
  final bool showCategory;

  const DealCard({
    super.key,
    required this.deal,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showCategory = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(deal.expiresAt);
    final AuthService authService = AuthService();
    print('📸 DealCard Image URL: [${deal.imageUrl}]');

    return GestureDetector(
      onTap: () {
        debugPrint('🖱️ DealCard tapped: ${deal.id}');
        try {
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
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- IMAGE SECTION --------------------
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.4, // Consistent ratio for Grid
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                    child: deal.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: deal.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.kDarkBackground.withOpacity(0.5),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.kElectricLime,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print('❌ DealCard Image Error: $error for URL: [$url]');
                              return Container(
                                color: AppTheme.kDarkBackground,
                                child: const Icon(Icons.broken_image, color: Colors.white24),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.image_not_supported, color: Colors.white24),
                          ),
                  ),
                ),
                // -------------------- DISCOUNT BADGE --------------------
                if (deal.discountValue.isNotEmpty)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        deal.discountValue,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.sp,
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
                        _showLoginSnackBar(context);
                        return;
                      }
                      if (onFavoriteToggle != null) {
                        onFavoriteToggle!();
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 18.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // -------------------- INFO SECTION --------------------
            Padding(
              padding: EdgeInsets.all(10.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Company Name (Natural state)
                  if (deal.companyName != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        deal.companyName!,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.sp,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                   // Title (2 lines)
                  Text(
                    deal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.kLightText,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Expiry
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12.w, color: Colors.redAccent),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (showCategory && deal.categoryName != null && deal.categoryName!.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Text(
                      deal.categoryName!,
                      style: TextStyle(
                        color: AppTheme.kElectricLime,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLoginSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 24.w),
            SizedBox(width: 8.w),
            const Expanded(
              child: Text(
                'يجب تسجيل الدخول لإضافة المفضلات',
                style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'تسجيل الدخول',
          textColor: AppTheme.kElectricLime,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        backgroundColor: AppTheme.kDarkBackground.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }
}
