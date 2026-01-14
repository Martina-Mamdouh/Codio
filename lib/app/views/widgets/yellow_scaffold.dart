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
                padding: EdgeInsets.only(
                  left: 16.w, 
                  right: 16.w, 
                  top: 12.h, 
                  bottom: 24.h // Add more bottom padding for the curve effect
                ),
                child: Row(
                  children: [
                    if (showBackButton)
                      GestureDetector(
                        onTap: onBackTap ?? () {
                           if (Navigator.canPop(context)) {
                             Navigator.pop(context);
                           } else {
                             Navigator.of(context).pop(); 
                           }
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    
                    if (showBackButton) SizedBox(width: 12.w),

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
