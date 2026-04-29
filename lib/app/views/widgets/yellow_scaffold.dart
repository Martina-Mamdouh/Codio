import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/theme/app_theme.dart';

class YellowScaffold extends StatelessWidget {
  final String title;
  final Widget? titleWidget;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final List<Widget>? actions;

  const YellowScaffold({
    super.key,
    required this.title,
    this.titleWidget,
    required this.body,
    this.showBackButton = true,
    this.onBackTap,
    this.actions,
  });

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final isCompactHeight = ResponsiveUtils.isCompactHeight(context);

    final isTablet = _isTablet(context);

    final baseHeight = isLandscape ? 140.h : 128.h;

    // 👇 ONLY CHANGE: bigger header on tablet
    final headerHeight = isTablet
        ? baseHeight * 1.35
        : (isCompactHeight ? baseHeight * 0.92 : baseHeight);

    return Scaffold(
      backgroundColor: AppTheme.kDarkBackground,
      body: Column(
        children: [
          SizedBox(
            height: headerHeight,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
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
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: isTablet ? 16.h : 8.h, // nicer spacing on tablet
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: titleWidget ??
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: isTablet ? 30.sp : 24.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    height: 1.1,
                                  ),
                                ),
                          ),

                          if (actions != null) ...actions!,

                          if (showBackButton) ...[
                            SizedBox(width: 8.w),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.black,
                                size: isTablet ? 32.sp : 28.sp,
                              ),
                              onPressed: onBackTap ??
                                      () {
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
              ],
            ),
          ),

          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.maxContentWidth(context),
                ),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}