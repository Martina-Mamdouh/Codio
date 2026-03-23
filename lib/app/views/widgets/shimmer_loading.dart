import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';

/// Professional shimmer effect for loading states
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Duration duration;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.kLightBackground,
                AppTheme.kElevatedBackground,
                AppTheme.kLightBackground,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Shimmer placeholder box
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.kLightBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusSm),
      ),
    );
  }
}

/// Pre-built shimmer for card loading
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          color: AppTheme.kLightBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ShimmerBox(
              width: double.infinity,
              height: 120.h,
              borderRadius: AppTheme.radiusMd,
            ),
            SizedBox(height: AppTheme.spacing12),
            // Title placeholder
            ShimmerBox(
              width: 200.w,
              height: 16.h,
            ),
            SizedBox(height: AppTheme.spacing8),
            // Subtitle placeholder
            ShimmerBox(
              width: 140.w,
              height: 12.h,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built shimmer for list items
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        child: Row(
          children: [
            // Avatar placeholder
            ShimmerBox(
              width: 48.w,
              height: 48.w,
              borderRadius: AppTheme.radiusFull,
            ),
            SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: 150.w,
                    height: 14.h,
                  ),
                  SizedBox(height: AppTheme.spacing6),
                  ShimmerBox(
                    width: 100.w,
                    height: 10.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built shimmer for deal cards
class ShimmerDealCard extends StatelessWidget {
  const ShimmerDealCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: 160.w,
        padding: EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: AppTheme.kLightBackground,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal image
            ShimmerBox(
              width: double.infinity,
              height: 100.h,
              borderRadius: AppTheme.radiusMd,
            ),
            SizedBox(height: AppTheme.spacing10),
            // Company logo and name
            Row(
              children: [
                ShimmerBox(
                  width: 24.w,
                  height: 24.w,
                  borderRadius: AppTheme.radiusSm,
                ),
                SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: ShimmerBox(
                    height: 12.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppTheme.spacing8),
            // Deal title
            ShimmerBox(
              width: double.infinity,
              height: 14.h,
            ),
            SizedBox(height: AppTheme.spacing6),
            // Price
            ShimmerBox(
              width: 60.w,
              height: 16.h,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built shimmer for company profile header
class ShimmerCompanyProfile extends StatelessWidget {
  const ShimmerCompanyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          // Cover image
          ShimmerBox(
            width: double.infinity,
            height: 200.h,
          ),
          Padding(
            padding: EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                // Logo
                ShimmerBox(
                  width: 60.w,
                  height: 60.w,
                  borderRadius: AppTheme.radiusMd,
                ),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                        width: 140.w,
                        height: 18.h,
                      ),
                      SizedBox(height: AppTheme.spacing6),
                      ShimmerBox(
                        width: 80.w,
                        height: 12.h,
                      ),
                    ],
                  ),
                ),
                // Follow button
                ShimmerBox(
                  width: 90.w,
                  height: 36.h,
                  borderRadius: AppTheme.radiusFull,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
