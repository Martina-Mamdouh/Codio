import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/company_model.dart';
import '../../../core/theme/app_theme.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback? onTap;
  final bool isFollowed;
  final bool isFollowLoading;
  final VoidCallback onToggleFollow;

  const CompanyCard({
    super.key,
    required this.company,
    this.onTap,
    required this.isFollowed,
    required this.isFollowLoading,
    required this.onToggleFollow,
  });

  @override
  Widget build(BuildContext context) {
    final rating = company.rating ?? 0.0;
    final reviewsCount = company.reviewsCount ?? 0;
    final followers = company.followersCount ?? 0;
    final dealsCount = company.dealCount ?? 0;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الصورة مع اللوجو
            Stack(
              clipBehavior: Clip.none, // 👈 مهم عشان اللوجو يطلع بره
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12.r),
                  ),
                  child: AspectRatio(
                    aspectRatio: isLandscape ? 2.5 : (1280 / 700), // Requested 1280x700
                    child: (company.coverImageUrl?.isNotEmpty ?? false) || (company.logoUrl?.isNotEmpty ?? false)
                      ? CachedNetworkImage(
                          imageUrl: (company.coverImageUrl?.isNotEmpty ?? false)
                              ? company.coverImageUrl!
                              : company.logoUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF2A2A2A),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.kElectricLime,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF2A2A2A),
                            child: Icon(
                              Icons.store,
                              color: Colors.white24,
                              size: 40.w,
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF2A2A2A),
                          child: Icon(Icons.store, color: Colors.white24, size: 40.w),
                        ),
                  ),
                ),

                Positioned(
                  bottom: -20.h, // Slightly adjusted
                  left: 12.w,
                  child: Container(
                    width: isLandscape ? 40.w : 50.w, // Smaller logo in landscape
                    height: isLandscape ? 40.w : 50.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: (company.logoUrl?.isNotEmpty ?? false)
                          ? CachedNetworkImage(
                              imageUrl: company.logoUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.store, color: Colors.grey, size: 24.w),
                            )
                          : Icon(Icons.store, color: Colors.grey, size: 24.w),
                    ),
                  ),
                ),
              ],
            ),

            // المعلومات تحت الصورة
            Padding(
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: isLandscape ? 4.h : 6.h,
                  bottom: 4.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اسم الشركة
                    Padding(
                      padding: EdgeInsets.only(left: isLandscape ? 45.w : 60.w),
                      child: Text(
                        company.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLandscape ? 11.sp : 13.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),

                    SizedBox(height: isLandscape ? 6.h : 8.h), // Space after logo area

                    // الفئة
                    if (company.categoryName != null &&
                        company.categoryName!.isNotEmpty)
                      Text(
                        company.categoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: isLandscape ? 9.sp : 11.sp,
                        ),
                      ),

                    if (!isLandscape) SizedBox(height: 4.h),

                    // المتابعين والعروض (Compact row in landscape?)
                    if (isLandscape)
                       // In landscape, combine info to save space
                       Row(
                         children: [
                           Icon(Icons.people_outline, size: 12.w, color: Colors.white54),
                           SizedBox(width: 4.w),
                           Text('${followers}', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                           SizedBox(width: 8.w),
                           Icon(Icons.star, size: 12.w, color: Colors.amber),
                           SizedBox(width: 4.w),
                           Text('${rating.toStringAsFixed(1)}', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                         ],
                       )
                    else ...[
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14.w,
                            color: Colors.white54,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '$followers متابع',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, size: 14.w, color: Colors.amber),
                          SizedBox(width: 6.w),
                          Text(
                            '${rating.toStringAsFixed(1)} ($reviewsCount)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
