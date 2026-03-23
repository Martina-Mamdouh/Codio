import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_theme.dart';
import 'professional_buttons.dart';

/// Professional empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: AppTheme.durationSlow,
              curve: AppTheme.curveEmphasized,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing24),
                decoration: BoxDecoration(
                  color: AppTheme.kLightBackground,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.kCardBorder,
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: AppTheme.iconXl,
                  color: AppTheme.kSubtleText,
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacing24),
            // Title
            Text(
              title,
              style: TextStyle(
                color: AppTheme.kLightText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppTheme.spacing8),
              Text(
                subtitle!,
                style: TextStyle(
                  color: AppTheme.kSubtleText,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppTheme.spacing24),
              ProfessionalButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Professional error state widget
class ErrorState extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.actionLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon with shake animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: AppTheme.durationSlower,
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value < 0.5
                      ? (value * 0.1) - 0.025
                      : ((1 - value) * 0.1) - 0.025,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacing20),
                decoration: BoxDecoration(
                  color: AppTheme.kError.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.kError.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: AppTheme.iconXl,
                  color: AppTheme.kError,
                ),
              ),
            ),
            SizedBox(height: AppTheme.spacing24),
            Text(
              'حدث خطأ',
              style: TextStyle(
                color: AppTheme.kLightText,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppTheme.spacing8),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.kSubtleText,
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppTheme.spacing24),
              ProfessionalButton(
                label: actionLabel ?? 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Professional loading state with pulsing animation
class LoadingState extends StatefulWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing loader
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.kElectricLime
                          .withValues(alpha: 0.3 * _controller.value),
                      blurRadius: 20 + (10 * _controller.value),
                      spreadRadius: 5 * _controller.value,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  color: AppTheme.kElectricLime,
                  strokeWidth: 3,
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            SizedBox(height: AppTheme.spacing20),
            Text(
              widget.message!,
              style: TextStyle(
                color: AppTheme.kSubtleText,
                fontSize: 14.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated fade-in wrapper
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;

  const FadeInWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppTheme.durationNormal,
    this.slideOffset = const Offset(0, 20),
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.curveDefault),
    );
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.curveDefault),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Staggered animation list wrapper
class StaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration itemDelay;
  final EdgeInsets? padding;

  const StaggeredList({
    super.key,
    required this.children,
    this.baseDelay = Duration.zero,
    this.itemDelay = const Duration(milliseconds: 50),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return FadeInWidget(
          delay: baseDelay + (itemDelay * index),
          child: children[index],
        );
      },
    );
  }
}
