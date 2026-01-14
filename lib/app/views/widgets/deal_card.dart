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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () {
        debugPrint('🖱️ DealCard tapped: ${deal.id}');
        try {
          context.read<AnalyticsService>().trackDealCardClick(deal.id);
        } catch (e) {
          debugPrint('⚠️ Analytics Error in DealCard: $e');
        }

        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
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
          // mainAxisSize: MainAxisSize.min, // Removed to allow Expanded to work if parent constrains
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------- IMAGE SECTION --------------------
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: isLandscape ? 2.2 : (1280 / 700), // Requested 1280x700
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
                            errorWidget: (context, url, error) => Container(
                              color: AppTheme.kDarkBackground,
                              child: const Icon(Icons.broken_image, color: Colors.white24),
                            ),
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
                          fontSize: isLandscape ? 8.sp : 10.sp,
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
                        size: isLandscape ? 14.w : 18.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // -------------------- INFO SECTION --------------------
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Name
                  if (deal.companyName != null)
                    Text(
                      deal.companyName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isLandscape ? 9.sp : 10.sp,
                                                  // fontFamily: 'Cairo', // Inherited
                      ),
                    ),
                  
                  SizedBox(height: 2.h),

                  // Title
                  Text(
                    deal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.kLightText,
                      fontWeight: FontWeight.bold,
                      fontSize: isLandscape ? 11.sp : 13.sp,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: isLandscape ? 2.h : 4.h),

                  // Expiry
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: isLandscape ? 10.w : 12.w, color: Colors.redAccent),
                      SizedBox(width: 4.w),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: isLandscape ? 9.sp : 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                   
                  // Category (Only show if space helps, or keep it but ensure no overflow)
                  if (showCategory && deal.categoryName != null && deal.categoryName!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      deal.categoryName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.kElectricLime,
                        fontSize: isLandscape ? 9.sp : 10.sp,
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
                style: TextStyle(
                  // fontFamily: 'Cairo', // Inherited
                  color: Colors.white,
                ),
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
