import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    // Total height calculation:
    // Yellow background: 140.h
    // Search bar is positioned at top: 110.h (overlapping the edge)
    // Search bar height approx: 45.h + padding
    // We need to ensure the container below respects this overlap.
    
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final double backgroundHeight = isLandscape ? 160.h : 130.h;
    final double totalHeight = backgroundHeight + 30.h; // Account for search bar straddle

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Yellow Background
          Container(
            width: double.infinity,
            height: backgroundHeight,
            decoration: const BoxDecoration(
              color: Color(0xFFE5FF17),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
            ),
          ),

          // Content (Title, Subtitle, Back Button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isLandscape ? 20.sp : 24.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: isLandscape ? 11.sp : 13.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showBackButton)
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded, 
                          color: Colors.black, 
                          size: isLandscape ? 20.sp : 24.sp,
                          weight: 700,
                        ),
                        onPressed: onBackTap ?? () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withOpacity(0.05),
                          padding: EdgeInsets.all(8.w),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          Positioned(
            top: backgroundHeight - (isLandscape ? 20.h : 25.h), // Positioned to straddle
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * (isLandscape ? 0.92 : 0.88),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: isLandscape ? 6.h : 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.kLightBackground,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
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
                      size: isLandscape ? 20.sp : 24.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        onChanged: onSearchChanged,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isLandscape ? 14.sp : 15.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: searchHint,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: isLandscape ? 14.sp : 15.sp,
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
        ],
      ),
    );
  }
}
