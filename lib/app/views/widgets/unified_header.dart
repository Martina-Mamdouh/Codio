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
    
    return SizedBox(
      height: 165.h, // Sufficient height to cover background + search bar half out
      child: Stack(
        children: [
          // Yellow Background
          Container(
            width: double.infinity,
            height: 140.h,
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
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 13.sp,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showBackButton)
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 28.sp),
                        onPressed: onBackTap ?? () => Navigator.pop(context),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          Positioned(
            top: 110.h,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.kLightBackground,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppTheme.kElectricLime,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TextField(
                        onChanged: onSearchChanged,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                        ),
                        decoration: InputDecoration(
                          hintText: searchHint,
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15.sp,
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
