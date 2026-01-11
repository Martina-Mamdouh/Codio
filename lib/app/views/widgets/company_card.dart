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

    print('📸 CompanyCard Logo URL: [${company.logoUrl}]');
    print('📸 CompanyCard Cover URL: [${company.coverImageUrl}]');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
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
                      aspectRatio: 16 / 9, // Using standard ratio
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
                            errorWidget: (context, url, error) {
                              print('❌ CompanyCard Cover Error: $error for URL: [$url]');
                              return Container(
                                color: const Color(0xFF2A2A2A),
                                child: Icon(
                                  Icons.store,
                                  color: Colors.white24,
                                  size: 40.w,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFF2A2A2A),
                            child: Icon(Icons.store, color: Colors.white24, size: 40.w),
                          ),
                    ),
                  ),

                  Positioned(
                    bottom: -25.h, // 👈 نصف اللوجو تحت الصورة
                    left: 16.w,
                    child: Container(
                      width: 56.w,
                      height: 56.w,
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
                                errorWidget: (context, url, error) {
                                  print('❌ CompanyCard Logo Error: $error for URL: [$url]');
                                  return Icon(Icons.store, color: Colors.grey, size: 28.w);
                                },
                              )
                            : Icon(Icons.store, color: Colors.grey, size: 28.w),
                      ),
                    ),
                  ),
                ],
              ),

              // المعلومات تحت الصورة
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 10.h, // Reduced top padding slightly
                      bottom: 4.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم الشركة
                        Text(
                          company.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        // الفئة
                        if (company.categoryName != null &&
                            company.categoryName!.isNotEmpty) ...[
                          Text(
                            company.categoryName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],

                        // المتابعين
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16.w,
                              color: Colors.white54,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '$followers متابع',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        // عدد العروض
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              size: 16.w,
                              color: Colors.white54,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '$dealsCount عرض',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        // التقييم
                        Row(
                          children: [
                            Icon(Icons.star, size: 16.w, color: Colors.amber),
                            SizedBox(width: 6.w),
                            Text(
                              '${rating.toStringAsFixed(1)} ($reviewsCount)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
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
      ),
    );
  }
}
