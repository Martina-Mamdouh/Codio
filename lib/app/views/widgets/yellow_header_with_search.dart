import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class YellowHeaderWithSearch extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final String searchHint;
  final VoidCallback? onSearchTap;
  final Widget? child;

  const YellowHeaderWithSearch({
    super.key,
    required this.title,
    required this.subtitle,
    this.onBack,
    required this.searchHint,
    this.onSearchTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                  if (onBack != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 28),
                      onPressed: onBack,
                    ),
                  if (onBack == null) const SizedBox(width: 44),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 100.h,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: onSearchTap,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.88,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    const Icon(Icons.search, color: Color(0xFFE5FF17)),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        searchHint,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 15.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (child != null)
          Padding(
            padding: EdgeInsets.only(top: 160.h),
            child: child,
          ),
      ],
    );
  }
}
