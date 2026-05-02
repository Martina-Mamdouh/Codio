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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
                    aspectRatio: isLandscape
                        ? 2.5
                        : (1280 / 700), // Requested 1280x700
                    child:
                        (company.coverImageUrl?.isNotEmpty ?? false) ||
                            (company.logoUrl?.isNotEmpty ?? false)
                        ? CachedNetworkImage(
                            imageUrl:
                                (company.coverImageUrl?.isNotEmpty ?? false)
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
                            child: Icon(
                              Icons.store,
                              color: Colors.white24,
                              size: 40.w,
                            ),
                          ),
                  ),
                ),

                PositionedDirectional(
                  bottom: -20.h, // Slightly adjusted
                  end: 12.w,
                  child: Container(
                    width: isLandscape
                        ? 40.w
                        : 50.w, // Smaller logo in landscape
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
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.store,
                                color: Colors.grey,
                                size: 24.w,
                              ),
                            )
                          : Icon(Icons.store, color: Colors.grey, size: 24.w),
                    ),
                  ),
                ),
              ],
            ),

            // المعلومات تحت الصورة
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 10.w,
                  right: 10.w,
                  top: isLandscape ? 4.h : 6.h,
                  bottom: 6.h, // قللنا المسافة اللي تحت عشان الـ Overflow
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // تتوزع المسافات بالتساوي بدل المساحات الفاضية الكبيرة
                  children: [
                    // الجزء العلوي: اسم الشركة والفئة
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: isLandscape ? 45.w : 55.w,
                      ),
                      child: Text(
                        company.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLandscape ? 11.sp : 13.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (company.categoryName != null &&
                        company.categoryName!.isNotEmpty)
                      Text(
                        company.categoryName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: isLandscape ? 9.sp : 11.sp,
                          height: 1.1,
                        ),
                      ),

                    // الجزء السفلي: الإحصائيات
                    if (isLandscape)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Icon(Icons.people_outline, size: 12.w, color: Colors.white54),
                            SizedBox(width: 4.w),
                            Text('$followers', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                            SizedBox(width: 8.w),
                            Icon(Icons.local_offer_outlined, size: 12.w, color: Colors.white54),
                            SizedBox(width: 4.w),
                            Text('${company.dealCount ?? 0}', style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                            SizedBox(width: 8.w),
                            Icon(Icons.star, size: 12.w, color: Colors.amber),
                            SizedBox(width: 4.w),
                            Text(rating.toStringAsFixed(1), style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
                          ],
                        ),
                      )
                    else 
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people_outline, size: 13.w, color: Colors.white54),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    '$followers متابع',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.local_offer_outlined, size: 13.w, color: Colors.white54),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    '${company.dealCount ?? 0} عرض',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, size: 13.w, color: Colors.amber),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    '${rating.toStringAsFixed(1)} ($reviewsCount)',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white70, fontSize: 11.sp),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
