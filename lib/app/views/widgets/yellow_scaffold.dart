import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';

class YellowScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;

  const YellowScaffold({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = true,
    this.onBackTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground, // Global Dark Background
      body: Column(
        children: [
          // Yellow Header Container (Curved Bottom)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE5FF17),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30.r),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          height: 1.1,
                        ),
                      ),
                    ),

                    if (actions != null) ...actions!,

                    if (showBackButton) ...[
                      SizedBox(width: 8.w), // Spacing before back text/icon if needed
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 28.sp),
                        onPressed: onBackTap ?? () {
                           if (Navigator.canPop(context)) {
                             Navigator.pop(context);
                           } else {
                             Navigator.of(context).pop(); 
                           }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Body Content (Directly on Dark Background)
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}
