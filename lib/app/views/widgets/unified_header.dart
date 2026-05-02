import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/theme/app_theme.dart';

class UnifiedHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onBackTap;
  final bool showBackButton;

  const UnifiedHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.searchHint,
    required this.onSearchChanged,
    this.onBackTap,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final bool isTablet = width >= 800;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final bool isCompactHeight = ResponsiveUtils.isCompactHeight(context);

    /// ✅ Bigger header ONLY on tablet
    final double backgroundHeight = isTablet
        ? (isLandscape ? 220.h : 200.h)
        : (isLandscape ? 140.h : 128.h);

    final double effectiveBackgroundHeight =
    isCompactHeight ? backgroundHeight * 0.92 : backgroundHeight;

    /// ✅ More controlled overlap
    final double searchOverlap = isTablet ? 60.h : 30.h;

    final double totalHeight = effectiveBackgroundHeight + searchOverlap;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// Yellow Background
          Container(
            width: double.infinity,
            height: effectiveBackgroundHeight,
            decoration: const BoxDecoration(
              color: Color(0xFFE5FF17),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
            ),
          ),

          /// Content (Title + Subtitle)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24.w : 16.w,
                  vertical: 10.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isTablet
                                  ? 26.sp
                                  : (isLandscape ? 20.sp : 24.sp),
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          /// ✅ Subtitle fully inside background
                          Text(
                            subtitle,
                            maxLines: isTablet ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.7),
                              fontSize: isTablet
                                  ? 15.sp
                                  : (isLandscape ? 11.sp : 13.sp),
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (showBackButton)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.black,
                          size: isTablet ? 32.sp : 28.sp,
                        ),
                        onPressed:
                        onBackTap ?? () => Navigator.pop(context),
                      ),
                  ],
                ),
              ),
            ),
          ),

          /// ✅ Search Bar (LOWERED on tablet)
          Positioned(
            top: isTablet
                ? effectiveBackgroundHeight - (searchOverlap * 0.45)
                : effectiveBackgroundHeight - (searchOverlap * 0.7),
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                  ResponsiveUtils.maxContentWidth(context) * 0.9,
                ),
                child: Container(
                  width: width * (isTablet ? 0.7 : 0.88),
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: isTablet ? 12.h : 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.kLightBackground,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppTheme.kElectricLime,
                        size: isTablet ? 22.sp : 24.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          onChanged: onSearchChanged,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 16.sp : 15.sp,
                          ),
                          decoration: InputDecoration(
                            hintText: searchHint,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: isTablet ? 16.sp : 15.sp,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}